import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartlink/api.dart';
import 'package:smartlink/chat.dart';
import 'package:smartlink/dialogs/attach.dart';
import 'package:smartlink/dialogs/comment.dart';
import 'package:smartlink/dialogs/ont.dart';
import 'package:smartlink/dialogs/task.dart';
import 'package:smartlink/main.dart';
import 'package:url_launcher/url_launcher.dart';



/// A reusable UI widget that displays a key-value pair as a row.
///
/// Typically used to show a labeled value, such as customer info or metadata.
/// The title appears on the left, and the value on the right with optional color.
///
/// Example:
/// ```dart
/// InfoTile(
///   title: 'Баланс',
///   value: '1200 сом',
///   valueColor: AppColors.success,
/// )
/// ```
class InfoTile extends StatelessWidget {

  /// Creates an [InfoTile] with a title, value, and optional value color.
  const InfoTile({
    required this.title,
    required this.value,
    this.valueColor,
    super.key
  });
  /// The label displayed on the left.
  final String title;
  /// The value displayed on the right.
  final String value;
  /// Optional color of the value text. Defaults to [AppColors.main].
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: AppColors.secondary)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(color: valueColor ?? AppColors.main)
            )
          )
        ]
      )
    );
  }
}

/// A stylized card component with a vertical color stripe, icon, and title.
///
/// Used for grouping related widgets in a visually distinct card.
/// For example, to display customer or box information in the UI.
///
/// The card has a fixed width based on screen size and a right margin for spacing.
///
/// Example:
/// ```dart
/// BoxCard(
///   lineColor: Colors.green,
///   icon: Icons.person,
///   title: 'Информация по абоненту',
///   child: Column(
///     children: [InfoTile(...), InfoTile(...)],
///   ),
/// )
/// ```
class BoxCard extends StatelessWidget {

  /// Creates a [BoxCard] with a title, icon, line color, and content widget.
  const BoxCard({required this.lineColor, required this.icon, required this.title, required this.child, this.last = false, super.key});
  /// The vertical stripe color shown on the left of the card.
  final Color lineColor;
  /// The icon shown next to the title.
  final IconData icon;
  /// The title text displayed at the top of the card.
  final String title;
  /// The widget content inside the card below the title.
  final Widget child;
  /// Optional fixed height of the entire card.
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        margin: !last? const EdgeInsets.only(bottom: 16, right: 16) : const EdgeInsets.only(bottom: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              Container(
                width: 6,
                color: lineColor
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(icon, color: AppColors.neo),
                          const SizedBox(width: 8),
                          Text(title, style: const TextStyle(color: AppColors.main, fontSize: 18, fontWeight: FontWeight.bold))
                        ]
                      ),
                      const Divider(),
                      const SizedBox(height: 4),
                      Expanded(child: child)
                    ]
                  )
                )
              )
            ]
          )
        )
      )
    );
  }
}

/// The main screen of the SmartLink application.
///
/// Displays a search input to find a customer by full name or agreement number.
/// Upon successful search, shows detailed customer information, and if the customer
/// is inactive or disconnected, displays related box data including neighbors.
class HomePage extends StatefulWidget {
  /// Creates the [HomePage] widget.
  const HomePage({super.key, this.customerId, this.initialChatId, this.initialOpenChat = false});
  /// Default customer id
  final int? customerId;
  // chatGPT code begin
  final String? initialChatId;
  final bool initialOpenChat;
  // chatGPT code end

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? id;
  List<Map> customers = [];
  bool load = false;
  bool search = true;
  bool showBox = false;
  bool noBox = false;

  Map? customerData;
  Map? boxData;
  Map? ontData;
  Map? attachData;
  List<Map>? taskData;

  TextEditingController searchController = TextEditingController();
  Timer? _debounce;
  bool customerNotFound = false;

  int debounce = 300;
  String loadNeighbours = 'onWrong';
  int searchVersion = 0;


  Future<void> _openUrl(link) async {
    final url = Uri.parse(link);
    if (await canLaunchUrl(url)) {
      l.i('open link: $link');
      await launchUrl(url, mode: kIsWeb? LaunchMode.platformDefault : LaunchMode.externalApplication);
    } else {
      l.e('unclickable link: $link');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка открытия ссылки: Ссылка некликабельна', style: TextStyle(color: AppColors.error)))
        );
      }
    }
  }

  Future<void> _openAttachs() async {
    l.i('get attachments for customer ${customerData!['id']}');
    if (context.mounted) {
      l.i('show attach dialog, reason: open attachments');
      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setStateDialog) {
              if (attachData == null) {
                try {
                  getAttach(customerData!['id']).then((res) {
                    setState(() {
                      attachData = res;
                    });
                    setStateDialog(() {});
                  });
                } catch (e) {
                  l.e('error getting attachments $e');
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Ошибка получения вложений: $e', style: const TextStyle(color: AppColors.error))
                    )
                  );
                  Navigator.pop(context);
                }
              }
              return AttachDialog(
                data: attachData,
                load: attachData == null
              );
            }
          );
        }
      );
    }
  }

  Color _getActivityColor(String lastActivity) {
    try {
      final parsed = DateTime.parse(lastActivity);
      final difference = DateTime.now().difference(parsed).inMinutes;
      return difference <= 15 ? AppColors.success : AppColors.error;
    } catch (e) {
      return AppColors.secondary;
    }
  }

  Color _getStatusColor(String status) {
    if (status == 'Активен') {
      return AppColors.success;
    }
    if (status == 'Пауза') {
      return AppColors.warning;
    }
    if (status == 'Отключен') {
      return AppColors.error;
    }
    return AppColors.secondary;
  }

  Color _getSignalColor(double? signal) {
    if (signal != null) {
      if (signal > -25) {
        return AppColors.success;
      }
      if (signal > -27) {
        return AppColors.warning;
      }
      return AppColors.error;
    }
    return AppColors.main;
  }

  Color _getCustomerBorderColor(Map? customer) {
    if (customer != null) {
      if (customer['status'] == 'Отключен' || _getActivityColor(customer['last_activity']) == AppColors.error) {
        return AppColors.error;
      }
      if (customer['status'] == 'Пауза') {
        return AppColors.warning;
      }
      return AppColors.success;
    }
    return AppColors.main;
  }

  Color _getBoxBorderColor(List<dynamic>? neighbours) {
    if (neighbours != null) {
      final allInactive = neighbours.every(
        (n) => _getActivityColor(n['last_activity']) == AppColors.error
      );
      return allInactive ? AppColors.error : AppColors.success;
    }
    return AppColors.main;
  }

  Color _getTaskBorderColor(List<Map>? tasks) {
    if (tasks != null){
      for (var task in tasks){
        if (task['dates']['create'] == null || task['status']['id'] == 12 || task['status']['id'] == 10){
          continue;
        }
        final DateTime parsed = DateTime.parse(task['dates']['create']);
        final int difference = DateTime.now().difference(parsed).inDays;
        if (difference > 2){
          return AppColors.error;
        }
      }
      return AppColors.success;
    }
    return AppColors.main;
  }

  Color _getTaskStatusColor(int status) {
    return switch (status) {
      18 => const Color(0xFFfff100),
      12 || 20 => const Color(0xFF00a650),
      3 || 17 => const Color(0xFF438ccb),
      15 => const Color(0xFFee1d24),
      14 || 11 => AppColors.secondary,
      1 => const Color(0xFFf7941d),
      10 => const Color(0xFFef6ea8),
      16 => const Color(0xFF00aeef),
      9 => const Color(0xFF00f000),

      _ => AppColors.main
    };
  }

  Color _getTaskDateColor(String date, int taskStatus){
    if (taskStatus == 12 || taskStatus == 10){
      return AppColors.success;
    }
    final DateTime parsed = DateTime.parse(date);
    final int difference = DateTime.now().difference(parsed).inDays;
    if (difference > 2){
      return AppColors.error;
    }
    return AppColors.success;
  }

  Color _getBalanceColor(double balance) {
    if (balance > 0) {
      return AppColors.success;
    }
    if (balance < 0) {
      return AppColors.error;
    }
    return AppColors.main;
  }

  String _convertSignal(double? signal) {
    if (signal != null) {
      return (-signal).toStringAsFixed(1);
    }
    return '-';
  }

  Future<void> _loadBoxData() async {
    try{
      if (!load){
        l.i('load box data');
        setState(() {
          load = true;
          boxData = null;
          showBox = true;
          noBox = false;
        });
        boxData = await getBox(customerData!['house_id']);
        if (boxData!['status'] == 'fail'){
          l.w('box not found');
          setState(() {
            noBox = true;
          });
        }
        // remove searching customer from neighbours
        boxData!['customers']?.removeWhere(
          (n) => n['id'] == customerData!['id']
        );
        setState(() {
          load = false;
        });
      } else {
        l.i('load box request ignored because load = true');
      }
    } catch (err) {
      l.e('error loading box data: $err');
      if (mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка получения данных абонента: $err', style: const TextStyle(color: AppColors.error)))
        );
      }
    }
  }

  Future<void> _loadCustomerData(Map e) async {
    try {
      l.i('load customer ${e['id']}');
      searchController.text = e['name'];
      if (!load) {
        setState(() {
          load = true;
          customerData = null;
          search = false;
        });
        customerData = await getCustomer(e['id']);
        taskData = List<Map>.from(customerData!['tasks']);
        setState(() {
          load = false;
        });
        if (loadNeighbours != 'never'){
          if (customerData!['status'] == 'Отключен' || _getActivityColor(customerData!['last_activity']) == AppColors.error || loadNeighbours == 'always'){
            l.i('something wrong with customer or loadNeighbours is "always", automatically load box');
            await _loadBoxData();
          }
        } else {
          l.i('neighbours not load becuase loadNeigbours is "never"');
        }
      } else {
        l.i('load customer request ignored because load = true');
      }
    } catch (err) {
      l.e('error getting customer data: $err');
      if (mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка получения данных абонента: $err', style: const TextStyle(color: AppColors.error)))
        );
      }
    }
  }

  Future<void> _onSearchSubmit(v) async {
    l.i('search submitted - value: $v');
    if (customers.isNotEmpty) {
      await _loadCustomerData(customers.first);
    } else {
      l.w('no customer selected');
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Абонент не выбран', style: TextStyle(color: AppColors.warning)))
      );
    }
  }

  void _onSearchChange(v) {
    l.i('search changed - value: $v');
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    final int currentVersion = ++searchVersion;
    _debounce = Timer(Duration(milliseconds: debounce), () async { //debouncing for {debounce}ms to prevent too many requests at once
      final int requestVersion = currentVersion;
      //clearing fields
      setState(() {
        customerNotFound = false;
        customerData = null;
        boxData = null;
        ontData = null;
        search = true;
        attachData = null;
        showBox = false;
      });
      if (v.isNotEmpty) {
        try {
          customers = await find(v);

          if (searchVersion != requestVersion) {
            l.w('search response ignored due to newer request');
            return;
          }

          setState(() {});
          if (customers.isEmpty && mounted) {
            l.w('no customers found');
            setState(() {
              customerNotFound = true;
            });
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Абонент не найден', style: TextStyle(color: AppColors.warning)))
            );
          } else {
            l.i('found ${customers.length} customers');
          }
        } catch (e) {
          l.e('error getting customers: $e');
          setState(() {
            customerNotFound = true;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ошибка получения абонентов: $e', style: const TextStyle(color: AppColors.error)))
            );
          }
        }
      } else {
        setState(() {
          customers.clear();
        });
      }
    });
  }

  void _getSettings() async {
    l.i('get settings data');
    final prefs = await SharedPreferences.getInstance();
    debounce = prefs.getInt('debounce') ?? 300;
    loadNeighbours = prefs.getString('loadNeighbours') ?? 'onWrong';
    id = prefs.getInt('userId');
    if (id == null){
      l.w('user id not found');
      if (mounted){
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка: USER ID не найден', style: TextStyle(color: AppColors.error))));
      }
    }
    setState(() {});
  }

  void _openONT() {
    if (customerData == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Дождитесь загрузки абонента', style: TextStyle(color: AppColors.warning))));
      return;
    }
    if (customerData!['sn'] == null){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('У абонента нет ТМЦ с SN', style: TextStyle(color: AppColors.warning))));
      return;
    }
    if (customerData!['olt_id'] == null){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OLT не найден', style: TextStyle(color: AppColors.error))));
      return;
    }
    showDialog(context: context, builder: (context){
      return OntDialog(oltId: customerData!['olt_id'], sn: customerData!['sn']);
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.customerId != null){
      _loadCustomerData({'id': widget.customerId, 'name': ''});
    }
    _getSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 16, bottom: 32),
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 3.5,
          child: id==null? const Text('Чат не доступен в debug режиме', style: TextStyle(color: AppColors.secondary), textAlign: TextAlign.right) : ChatWidget(
            employeeId: id!,
            initialChatId: widget.initialChatId,
            initialOpenChat: widget.initialOpenChat,
          )
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: 16)
                      )
                    ),
                    Expanded(
                      child: Padding(
                        // margin: EdgeInsets.only(left: (MediaQuery.of(context).size.width - 80) / 3 + 16),
                        // width: (MediaQuery.of(context).size.width - 80) / 3 - 16,
                        padding: const EdgeInsets.only(right: 16),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'ФИО или ЛС абонента',
                            errorText: customerNotFound? ' ' : null,
                            helperText: customerNotFound? ' ' : null
                          ),
                          controller: searchController,
                          onSubmitted: _onSearchSubmit,
                          onChanged: _onSearchChange
                        )
                      )
                    ),
                    const Expanded(
                      child: SizedBox()
                    )
                  ]
                ),
                const SizedBox(height: 10),
                if (search == true && customers.isNotEmpty)
                // search results
                SizedBox(
                  width: 450,
                  height: 250,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final e = customers[index];
                      return InkWell(
                        onTap: () async {
                          await _loadCustomerData(e);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text('${e['agreement']}: ${e['name']}', style: const TextStyle(fontSize: 15))
                        )
                      );
                    }
                  )
                ),
                const SizedBox(height: 10),
                // if (customer != null && customerData == null)
                // Expanded(
                //   child: Center(
                //     child: CircularProgressIndicator()
                //   ),
                // ),
                if (search == false)
                Expanded(
                  child: Row(
                    children: [
                      BoxCard(
                        lineColor: _getCustomerBorderColor(customerData),
                        icon: Icons.person,
                        title: 'Информация по абоненту',
                        child: customerData == null? const Center(child: AngularProgressBar()) :
                        Column(
                          children: [
                            if (customerData!['olt_id'] == null)
                            const Row(
                              spacing: 5,
                              children: [
                                Icon(Icons.warning_amber, color: AppColors.warning),
                                Text('Абонент не коммутирован', style: TextStyle(color: AppColors.warning))
                              ],
                            ),
                            InfoTile(
                              title: 'ФИО',
                              value: customerData!['name']
                            ),
                            InfoTile(
                              title: 'Лицевой счёт',
                              value: customerData!['agreement'].toString()
                            ),
                            InfoTile(
                              title: 'Баланс',
                              value: '${customerData!['balance']} сом',
                              valueColor: _getBalanceColor(customerData!['balance'])
                            ),
                            InfoTile(
                              title: 'Статус',
                              value: customerData!['status'],
                              valueColor: _getStatusColor(customerData!['status'])
                            ),
                            InfoTile(
                              title: 'Группа',
                              value: customerData!['group']?['name'] ?? '-'
                            ),
                            InfoTile(
                              title: 'Последняя активность',
                              value: formatDate(customerData!['last_activity']),
                              valueColor: _getActivityColor(customerData!['last_activity'])
                            ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     Text('Уровень сигнала:'),
                            //     Text((customerData!['onu_level'] ?? '-').toString(), style: TextStyle(color: _getSignalColor(customerData!['onu_level'])))
                            //   ]
                            // ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Номер телефона', style: TextStyle(color: AppColors.secondary)),
                                Column(
                                  children: customerData!['phones'].map<Widget>((phone) {
                                    return Row(
                                      children: [
                                        const Icon(Icons.phone, size: 18, color: AppColors.neo),
                                        const SizedBox(width: 8),
                                        Text(phone)
                                      ]
                                    );
                                  }).toList()
                                )
                              ]
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Тариф', style: TextStyle(color: AppColors.secondary)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: customerData!['tariffs'].map<Widget>((tariff) {
                                      return Text(tariff['name'], softWrap: true, textAlign: TextAlign.right);
                                    }).toList()
                                  )
                                )
                              ]
                            ),
                            const SizedBox(height: 5),
                            const Row(
                              children: [
                                Icon(Icons.public, color: AppColors.neo),
                                SizedBox(width: 8),
                                Text('Геоданные', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))
                              ]
                            ),
                            const Divider(),
                            if (customerData!['geodata']?['coord'] != null)
                            InfoTile(title: 'Координаты', value: customerData!['geodata']['coord'].join(', ')),
                            if (customerData!['geodata']?['address'] != null)
                            InfoTile(title: 'Адрес', value: customerData!['geodata']['address']),
                            if (customerData!['geodata']?['2gis_link'] != null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Ссылка 2GIS', style: TextStyle(color: AppColors.secondary)),
                                InkWell(
                                  onTap: () async => await _openUrl(customerData!['geodata']['2gis_link']),
                                  child: const Icon(Icons.public, size: 18, color: AppColors.neo)
                                )
                              ]
                            ),
                            if (customerData!['geodata']?['neo_link'] != null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Ссылка Neotelecom', style: TextStyle(color: AppColors.secondary)),
                                InkWell(
                                  onTap: () async => await _openUrl(customerData!['geodata']['neo_link']),
                                  child: const Icon(Icons.public, size: 18, color: AppColors.neo)
                                )
                              ]
                            ),
                            if (customerData!['geodata'] == null)
                            const Text('Нет данных', style: TextStyle(color: AppColors.secondary)),
                            const SizedBox(height: 10),
                            const Row(
                              children: [
                                Icon(Icons.warning_amber_outlined, color: AppColors.neo),
                                SizedBox(width: 8),
                                Text('Возможные причины проблем', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))
                              ]
                            ),
                            const Divider(),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if ((customerData!['onu_level'] ?? 0) < -25)
                                  Text('• Низкий уровень сигнала', style: TextStyle(color: _getSignalColor(customerData!['onu_level']))),
                                  if (customerData!['status'] == 'Отключен')
                                  const Text('• Абонент отключен', style: TextStyle(color: AppColors.error)),
                                  if (customerData!['status'] == 'Пауза')
                                  const Text('• Абонент на паузе', style: TextStyle(color: AppColors.warning)),
                                  if (_getActivityColor(customerData!['last_activity']) == AppColors.error)
                                  const Text('• Последняя активность > 10 минут назад', style: TextStyle(color: AppColors.error)),
                                  if (_getBoxBorderColor(boxData?['customers']) == AppColors.error)
                                  const Text('• Проблемы в коробке', style: TextStyle(color: AppColors.error))
                                ],
                              ),
                            )
                          ]
                        )
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  BoxCard(
                                    lineColor: AppColors.main,
                                    icon: Icons.menu,
                                    title: 'Меню действий',
                                    last: !showBox,
                                    child: Align(
                                      alignment: Alignment.topCenter,
                                      child: Column(
                                        spacing: 5,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 270,
                                            child: ElevatedButton.icon(
                                              onPressed: _openAttachs,
                                              icon: const Icon(Icons.attach_file),
                                              label: const Text('Открыть вложения')
                                            )
                                          ),
                                          SizedBox(
                                            width: 270,
                                            child: ElevatedButton.icon(
                                              onPressed: !showBox ? _loadBoxData : null,
                                              icon: const Icon(Icons.group),
                                              label: Text(!showBox ? 'Загрузить соседей' : 'Соседи загружены')
                                            )
                                          ),
                                          SizedBox(
                                            width: 270,
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                if (customerData != null){
                                                  l.i('show task dialog, reason: create task');
                                                  showDialog(context: context, builder: (context){
                                                    return TaskDialog(
                                                      customerId: customerData!['id'],
                                                      boxId: customerData!['house_id'],
                                                      phones: customerData!['phones']
                                                    );
                                                  });
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                    content: Text('Дождитесь загрузки абонента', style: TextStyle(color: AppColors.warning))
                                                  ));
                                                }
                                              },
                                              icon: const Icon(Icons.assignment_add),
                                              label: const Text('Создать задание')
                                            )
                                          ),
                                          SizedBox(
                                            width: 270,
                                            child: ElevatedButton.icon(
                                              onPressed: _openONT,
                                              icon: const Icon(Icons.router_outlined),
                                              label: const Text('Загрузить данные по модему')
                                            )
                                          ),
                                          SizedBox(
                                            width: 270,
                                            child: ElevatedButton.icon(
                                              onPressed: () async => await _openUrl('https://us.neotelecom.kg/customer/${customerData!['id']}'),
                                              icon: const Icon(Icons.open_in_browser),
                                              label: const Text('Открыть абонента в UserSide')
                                            )
                                          )
                                        ]
                                      )
                                    )
                                  ),
                                  if (showBox)
                                  BoxCard(
                                    lineColor: _getBoxBorderColor(boxData?['customers']),
                                    icon: Icons.dns,
                                    title: 'Информация по коробке',
                                    last: true,
                                    child: boxData == null? const Center(child: AngularProgressBar()) :
                                      Column(
                                        children: [
                                          if (noBox)
                                          const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            spacing: 5,
                                            children: [
                                              Icon(Icons.warning_amber_outlined, color: AppColors.error),
                                              Text('Коробка не найдена', style: TextStyle(color: AppColors.error)),
                                            ],
                                          )
                                          else
                                          InfoTile(
                                            title: 'Название коробки',
                                            value: boxData?['name'] ?? '-'
                                          ),
                                          const SizedBox(height: 6),
                                          if (!noBox)
                                          const Row(
                                            children: [
                                              Icon(Icons.group, color: AppColors.neo),
                                              SizedBox(width: 8),
                                              Text('Соседи', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))
                                            ]
                                          ),
                                          if (!noBox)
                                          const Divider(),
                                          const SizedBox(height: 8),
                                          if (!noBox)
                                          const Row(
                                            children: [
                                              Expanded(
                                                flex: 12,
                                                child: Text('Имя', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold))
                                              ),
                                              Expanded(
                                                flex: 8,
                                                child: Text('Активность', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))
                                              ),
                                              Expanded(
                                                flex: 7,
                                                child: Text('Статус', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))
                                              ),
                                              Expanded(
                                                flex: 4,
                                                child: Text('rx', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))
                                              )
                                            ]
                                          ),
                                          const SizedBox(height: 8),
                                          Expanded(
                                            child: ListView.builder(
                                              itemCount: boxData?['customers']?.length ?? 0,
                                              itemBuilder: (c, i) {
                                                final neighbour = boxData!['customers'][i];
                                                return Padding(
                                                  padding: const EdgeInsets.only(bottom: 6),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 12,
                                                        child: Text(neighbour['name'], softWrap: true, textAlign: TextAlign.left)
                                                      ),
                                                      Expanded(
                                                        flex: 8,
                                                        child: Text(formatDate(neighbour['last_activity']), textAlign: TextAlign.center,
                                                          style: TextStyle(color: _getActivityColor(neighbour['last_activity']))
                                                        )
                                                      ),
                                                      Expanded(
                                                        flex: 7,
                                                        child: Text(
                                                          neighbour['status'], textAlign: TextAlign.center,
                                                          style: TextStyle(color: _getStatusColor(neighbour['status']))
                                                        )
                                                      ),
                                                      Expanded(
                                                        flex: 4,
                                                        child: Text(
                                                          _convertSignal(neighbour['onu_level']), textAlign: TextAlign.end,
                                                          style: TextStyle(color: _getSignalColor(neighbour['onu_level']))
                                                        )
                                                      )
                                                    ]
                                                  )
                                                );
                                              }
                                            )
                                          )
                                        ]
                                      )
                                  )
                                ]
                              )
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  BoxCard(
                                    lineColor: AppColors.main,
                                    icon: Icons.device_hub,
                                    title: 'Оборудование',
                                    child: customerData == null? const Center(child: AngularProgressBar()) :
                                    Column(
                                      children: [
                                        const Row(
                                          children: [
                                            Expanded(
                                              flex: 5,
                                              child: Text('Название', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold))
                                            ),
                                            Expanded(
                                              flex: 6,
                                              child: Text('SN', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text('Кол-во', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))
                                            )
                                          ]
                                        ),
                                        Expanded(
                                          child: ListView.builder(
                                            itemCount: customerData!['inventory'].length,
                                            itemBuilder: (c, i){
                                              final equipment = customerData!['inventory'][i];
                                              return Padding(
                                                padding: const EdgeInsets.only(bottom: 6),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 5,
                                                      child: Text(equipment['name'] ?? '-', softWrap: true, textAlign: TextAlign.left)
                                                    ),
                                                    Expanded(
                                                      flex: 6,
                                                      child: equipment['sn'] == null?
                                                        const Text('-', softWrap: true, textAlign: TextAlign.center)
                                                        : InkWell(
                                                        onTap: _openONT,
                                                        child: Text(equipment['sn'], softWrap: true, textAlign: TextAlign.center,
                                                          style: const TextStyle(color: AppColors.neo,
                                                          decorationColor: AppColors.neo,
                                                          decoration: TextDecoration.underline)),
                                                      )
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text(equipment['amount'].toString(), softWrap: true, textAlign: TextAlign.right)
                                                    )
                                                  ]
                                                )
                                              );
                                            }
                                          )
                                        )
                                      ]
                                    )
                                  ),
                                  BoxCard(
                                    lineColor: _getTaskBorderColor(taskData),
                                    icon: Icons.assignment,
                                    title: 'Задания абонента',
                                    last: true,
                                    child: customerData == null? const Center(child: AngularProgressBar()) :
                                    Column(
                                      children: [
                                        if (taskData!.isEmpty)
                                        const Text('У абонента нет заданий', style: TextStyle(color: AppColors.secondary))
                                        else
                                        const Row(
                                          children: [
                                            Expanded(
                                              flex: 5,
                                              child: Text('Тип задания', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold))
                                            ),
                                            Expanded(
                                              flex: 4,
                                              child: Text('Дата создания', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))
                                            ),
                                            Expanded(
                                              flex: 4,
                                              child: Text('Статус', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))
                                            ),
                                            Expanded(
                                              child: Text('', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))
                                            )
                                          ]
                                        ),
                                        if (taskData!.isNotEmpty)
                                        Expanded(
                                          child: ListView.builder(
                                            itemCount: taskData!.length,
                                            itemBuilder: (c, i){
                                              final task = taskData![i];
                                              return Padding(
                                                padding: const EdgeInsets.only(bottom: 6),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 5,
                                                      child: Text(task['name'] ?? '-', softWrap: true, textAlign: TextAlign.left)
                                                    ),
                                                    Expanded(
                                                      flex: 4,
                                                      child: Text(formatDate(task['dates']['create']), softWrap: true, textAlign: TextAlign.center,
                                                        style: TextStyle(color: _getTaskDateColor(task['dates']['create'], task['status']['id'])))
                                                    ),
                                                    Expanded(
                                                      flex: 4,
                                                      child: Text(task['status']['name'], softWrap: true, textAlign: TextAlign.center,
                                                        style: TextStyle(color: _getTaskStatusColor(task['status']['id'] ?? 0)))
                                                    ),
                                                    Expanded(
                                                      child: IconButton(
                                                        onPressed: (){
                                                          l.i('show comment dialog, reason: open comments');
                                                          showDialog(context: context, builder: (context){
                                                            return CommentDialog(taskId: task['id']);
                                                          });
                                                        },
                                                        icon: const Icon(Icons.message_outlined, size: 16, color: AppColors.neo)
                                                      )
                                                    )
                                                  ]
                                                )
                                              );
                                            }
                                          )
                                        )
                                      ]
                                    )
                                  )
                                ]
                              )
                            )
                          ]
                        )
                      )
                    ]
                  )
                )
              ]
            )
          )
        )
      )
    );
  }
}
