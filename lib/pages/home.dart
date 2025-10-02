import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartlink/api.dart';
import 'package:smartlink/dialogs/attach.dart';
import 'package:smartlink/dialogs/newtask.dart';
import 'package:smartlink/dialogs/ont.dart';
import 'package:smartlink/dialogs/task.dart';
import 'package:smartlink/dialogs/tasks.dart';
import 'package:smartlink/main.dart';
import 'package:url_launcher/url_launcher.dart';


class InfoTile extends StatelessWidget {

  const InfoTile({
    required this.title,
    required this.value,
    this.valueColor,
    this.underlineColor = AppColors.neo,
    this.onTap,
    super.key
  });
  final String title;
  final String value;
  final Color underlineColor;
  final VoidCallback? onTap;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: AppColors.secondary)),
          if (onTap != null)
          InkWell(
            onTap: onTap,
            child: Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(color: valueColor ?? AppColors.main, decoration: TextDecoration.underline, decorationColor: underlineColor)
              )
            )
          )
          else
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


class BoxCard extends StatelessWidget {

  const BoxCard({
    required this.lineColor,
    required this.title,
    required this.child,
    this.icon,
    this.last = false,
    this.flex = 1,
    this.miniButtons = const [],
    super.key
  });
  final Color lineColor;
  final IconData? icon;
  final String title;
  final Widget child;
  final bool last;
  final int flex;
  final List<Widget> miniButtons;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Card(
        margin: !last? const EdgeInsets.only(bottom: 16, right: 16) : const EdgeInsets.only(bottom: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Row(
            spacing: 8,
            children: [
              Container(
                width: 6,
                color: lineColor
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            spacing: 8,
                            children: [
                              if (icon != null)
                              Icon(icon, color: AppColors.neo),
                              Text(title, style: const TextStyle(color: AppColors.main, fontSize: 18, fontWeight: FontWeight.bold))
                            ]
                          ),
                          Row(
                            spacing: 2,
                            children: miniButtons
                          )
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


class HomePage extends StatefulWidget {
  const HomePage({super.key, this.customerId, this.initialChatId, this.initialOpenChat = false});
  final int? customerId;
  // chatGPT code begin
  final String? initialChatId;
  final bool initialOpenChat;
  // chatGPT code end

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // TODO: remove unused variables and refactor loading (make Enum class)
  bool load = false;
  // search
  bool search = true;
  bool searching = false;
  List<Map> customers = [];
  TextEditingController searchController = TextEditingController();
  Timer? _debounce;
  bool customerNotFound = false;
  int searchVersion = 0;
  int debounce = 300;
  String loadNeighbours = 'onWrong';

  // customer
  int? id;
  Map? customerData;

  // box
  bool showBox = false;
  bool noBox = false;
  Map? boxData;

  // attach
  Map? attachData;

  // task
  List<Map>? taskData;


  // utils
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

  String _convertSignal(double? signal) {
    if (signal != null) {
      return (-signal).toStringAsFixed(1);
    }
    return '-';
  }

  // color getters
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


  // API calls
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
        boxData = await getBox(customerData!['box_id']);
        if (boxData!['status'] == 'fail'){
          l.w('box not found');
          setState(() {
            noBox = true;
          });
        }
        // remove search customer from neighbours
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
      searchController.clear();
      if (!load) {
        setState(() {
          load = true;
          customerData = null;
          taskData = null;
          attachData = null;
          boxData = null;
          showBox = false;
          search = false;
          searching = false;
        });
        customerData = await getCustomer(e['id']);
        taskData = List<Map>.from(customerData!['tasks']);
        setState(() {
          load = false;
          customers.clear();
        });
        // if (loadNeighbours != 'never'){
        //   if (customerData!['status'] == 'Отключен' || _getActivityColor(customerData!['last_activity']) == AppColors.error || loadNeighbours == 'always'){
        //     l.i('something wrong with customer or loadNeighbours is "always", automatically load box');
            await _loadBoxData();
        //   }
        // } else {
        //   l.i('neighbours not load becuase loadNeigbours is "never"');
        // }
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

  Future<void> _onSearchSubmit(String v) async {
    l.i('search submitted - value: $v');
    if (searching) return;
    if (customers.isNotEmpty) {
      await _loadCustomerData(customers.first);
    } else {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Абонент не выбран', style: TextStyle(color: AppColors.warning)))
      );
    }
  }

  void _onSearchChange(String v) {
  l.i('search changed - value: $v');
  _debounce?.cancel();

  if (v.trim().isEmpty) {
    setState(() {
      customers.clear();
      customerNotFound = false;
      search = true;
      searching = false;
      load = false;
    });
    return;
  }

  final int mySeq = ++searchVersion;
  _debounce = Timer(Duration(milliseconds: debounce), () async {
    setState(() {
      searching = true;
      customerNotFound = false;
      search = true;
      load = false;
    });

    try {
      final List<Map> res = await find(v);

      if (mySeq != searchVersion) {
        l.w('ignored outdated search response');
        return;
      }

      setState(() {
        customers = res;
        customerNotFound = res.isEmpty;
        searching = false;
      });

      l.i('found ${res.length} customers');
    } catch (e) {
      if (mySeq != searchVersion) return;
      l.e('error getting customers: $e');
      setState(() {
        customerNotFound = true;
        searching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка получения абонентов', style: TextStyle(color: AppColors.error)))
        );
      }
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


  // button callbacks
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
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Ошибка получения вложений', style: TextStyle(color: AppColors.error))
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

  void _openNewTask() {
    if (customerData != null){
      l.i('show newtask dialog');
      showDialog(context: context, builder: (context){
        return NewTaskDialog(
          customerId: customerData!['id'],
          boxId: customerData!['box_id'],
          phones: customerData!['phones']
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Абонент не загружен', style: TextStyle(color: AppColors.warning))
      ));
    }
  }

  void _openCustomerInUS(int id) async {
    await _openUrl('https://us.neotelecom.kg/customer/$id');
  }

  void _copyCustomerLink(int id) async {
    await Clipboard.setData(ClipboardData(text: 'https://us.neotelecom.kg/customer/$id'));
    if (mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ссылка скопирована', style: TextStyle(color: AppColors.success)))
      );
    }
  }

  void _openTask(int id){
    showDialog(
      context: context,
      builder: (context){
        return TaskDialog(taskId: id);
      }
    );
  }

  void _openTasks(List<int> ids){
    showDialog(
      context: context,
      builder: (context){
        return TasksDialog(tasks: ids);
      }
    );
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
      // TODO: refactor to make button smaller
      // floatingActionButton: Padding(
      //   padding: const EdgeInsets.only(right: 16, bottom: 32),
      //   child: SizedBox(
      //     width: MediaQuery.of(context).size.width / 3.5,
      //     child: id==null? const Text('Чат не доступен в debug режиме', style: TextStyle(color: AppColors.secondary), textAlign: TextAlign.right) : ChatWidget(
      //       employeeId: id!,
      //       initialChatId: widget.initialChatId,
      //       initialOpenChat: widget.initialOpenChat
      //     )
      //   )
      // ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded( // simulate card
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
                    const Expanded( // simulate another card
                      child: SizedBox()
                    )
                  ]
                ),
                const SizedBox(height: 10),
                if (search == true && customers.isNotEmpty)
                // search results
                const SizedBox(height: 10),
                if (search == true)
                SizedBox(
                  width: 450,
                  height: 250,
                  child: searching? const Center(child: AngularProgressBar()) : (customers.isEmpty? const Center(
                    child: Text('Нет результатов', style: TextStyle(color: AppColors.secondary))) : ListView.builder(
                      itemCount: customers.length,
                      itemBuilder: (context, index) {
                        final e = customers[index];
                        return InkWell(
                          onTap: () async => await _loadCustomerData(e),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(e['agreement'] == null? e['name'] : '${e['agreement']}: ${e['name']}', style: const TextStyle(fontSize: 15))
                          )
                        );
                      }
                    ))
                ),
                const SizedBox(height: 10),
                if (search == false)
                Expanded(
                  child: Row(
                    children: [
                      BoxCard(
                        lineColor: _getBoxBorderColor(boxData?['customers']),
                        icon: Icons.dns,
                        title: 'Коробка',
                        miniButtons: [
                          Tooltip(
                            message: 'Создать задание (Магистральный ремонт)',
                            child: IconButton(
                              onPressed: boxData != null? (){
                                showDialog(context: context, builder: (context){
                                  return NewTaskDialog(
                                    customerId: customerData!['id'],
                                    boxId: customerData!['box_id'],
                                    phones: customerData!['phones'],
                                    box: true
                                  );
                                });
                              } : null,
                              icon: Icon(Icons.assignment_add, color: boxData == null? AppColors.secondary : AppColors.neo, size: 18)
                            )
                          ),
                          // Tooltip(
                          //   message: 'Загрузить данные коробки',
                          //   child: IconButton(
                          //     onPressed: boxData == null ? _loadBoxData : null,
                          //     icon: Icon(Icons.download, size: 18, color: boxData != null? AppColors.secondary : AppColors.neo)
                          //   )
                          // )
                        ],
                        child: boxData == null? const Center(child: AngularProgressBar()) : Column(
                          children: [
                            if (noBox)
                            const Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 5,
                              children: [
                                Icon(Icons.warning_amber_outlined, color: AppColors.error),
                                Text('Коробка не найдена', style: TextStyle(color: AppColors.error))
                              ]
                            )
                            else ...[
                              InfoTile(
                                title: 'Название коробки',
                                value: boxData?['name'] ?? '-'
                              ),
                              InfoTile(
                                title: 'Открытые задания',
                                value: boxData?['box_tasks']?.length.toString() ?? '-',
                                valueColor: boxData?['box_tasks'] == null? AppColors.main :
                                  boxData!['box_tasks'].length == 0? AppColors.success : AppColors.error,
                                onTap: boxData?['box_tasks'] == null? null : boxData!['box_tasks'].length == 0? null : (){
                                  if (boxData!['box_tasks'].length == 1){
                                    _openTask(boxData!['box_tasks'].first);
                                  } else {
                                    _openTasks(boxData!['box_tasks']);
                                  }
                                },
                                underlineColor: AppColors.error
                              ),
                              const SizedBox(height: 6),
                              const Row(
                                children: [
                                  Icon(Icons.group, color: AppColors.neo),
                                  SizedBox(width: 8),
                                  Text('Соседи', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))
                                ]
                              ),
                              const Divider(),
                              const SizedBox(height: 8),
                              const Row(
                                children: [
                                  Expanded(
                                    flex: 7,
                                    child: Text('Имя', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold))
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text('Задания', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))
                                  ),
                                  Expanded(
                                    flex: 6,
                                    child: Text('Активность', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Text('Статус', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text('rx', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))
                                  )
                                ]
                              ),
                              const SizedBox(height: 8),
                              if (boxData?['customers']?.isNotEmpty ?? false)
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
                                            flex: 7,
                                            child: Text(neighbour['name'], softWrap: true, textAlign: TextAlign.left)
                                          ),
                                          InkWell(
                                            onTap: () {
                                              if (neighbour['tasks'].length == 1){
                                                _openTask(neighbour['tasks'].first);
                                              } else {
                                                _openTasks(neighbour!['tasks']);
                                              }
                                            },
                                            child: Expanded(
                                              flex: 3,
                                              child: Text(
                                                neighbour['tasks']?.length.toString() ?? '-',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: neighbour['tasks'].length == 0? AppColors.success : AppColors.error
                                                )
                                              )
                                            )
                                          ),
                                          Expanded(
                                            flex: 6,
                                            child: Text(formatDate(neighbour['last_activity']), textAlign: TextAlign.center,
                                              style: TextStyle(color: _getActivityColor(neighbour['last_activity']), fontSize: 13)
                                            )
                                          ),
                                          Expanded(
                                            flex: 4,
                                            child: Text(
                                              neighbour['status'], textAlign: TextAlign.center,
                                              style: TextStyle(color: _getStatusColor(neighbour['status']))
                                            )
                                          ),
                                          Expanded(
                                            flex: 2,
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
                              else
                              const Text('У абонента нет соседей', style: TextStyle(color: AppColors.secondary))
                            ]
                          ]
                        )
                      ),
                      BoxCard(
                        lineColor: _getCustomerBorderColor(customerData),
                        icon: Icons.person,
                        title: 'Абонент',
                        miniButtons: [
                          Tooltip(
                            message: 'Открыть вложения абонент и его заданий',
                            child: IconButton(
                              onPressed: _openAttachs,
                              icon: const Icon(Icons.attach_file, size: 18, color: AppColors.neo),
                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36)
                            )
                          ),
                          Tooltip(
                            message: 'Создать задание (Выезд на ремонт)',
                            child: IconButton(
                              onPressed: _openNewTask,
                              icon: const Icon(Icons.assignment_add, size: 18, color: AppColors.neo),
                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36)
                            )
                          ),
                          Tooltip(
                            message: 'Открыть данные по ONT',
                            child: IconButton(
                              onPressed: _openONT,
                              icon: const Icon(Icons.router_outlined, size: 18, color: AppColors.neo),
                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36)
                            )
                          ),
                          Tooltip(
                            message: 'Открыть абонента в UserSide',
                            child: IconButton(
                              onPressed: () => _openCustomerInUS(customerData!['id']),
                              icon: const Icon(Icons.open_in_browser, size: 18, color: AppColors.neo),
                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36)
                            )
                          ),
                          Tooltip(
                            message: 'Копировать ссылку на абонента в UserSide',
                            child: IconButton(
                              onPressed: () => _copyCustomerLink(customerData!['id']),
                              icon: const Icon(Icons.copy, size: 18, color: AppColors.neo),
                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36)
                            )
                          )
                        ],
                        child: customerData == null? const Center(child: AngularProgressBar()) :
                        Column(
                          children: [
                            if (customerData!['olt_id'] == null)
                            const Row(
                              spacing: 5,
                              children: [
                                Icon(Icons.warning_amber, color: AppColors.warning, size: 18),
                                Text('Абонент не коммутирован', style: TextStyle(color: AppColors.warning))
                              ]
                            ),
                            if ((customerData!['onu_level'] ?? 0) < -25)
                            Row(
                              spacing: 5,
                              children: [
                                const Icon(Icons.network_check, color: AppColors.error, size: 18),
                                Text('Низкий уровень сигнала', style: TextStyle(color: _getSignalColor(customerData!['onu_level'])))
                              ]
                            ),

                            if (customerData!['status'] == 'Отключен')
                            const Row(
                              spacing: 5,
                              children: [
                                Icon(Icons.power_settings_new, color: AppColors.error, size: 18),
                                Text('Абонент отключен', style: TextStyle(color: AppColors.error))
                              ]
                            ),

                            if (customerData!['status'] == 'Пауза')
                            const Row(
                              spacing: 5,
                              children: [
                                Icon(Icons.pause_circle_filled, color: AppColors.warning, size: 18),
                                Text('Абонент на паузе', style: TextStyle(color: AppColors.warning))
                              ]
                            ),

                            if (_getActivityColor(customerData!['last_activity']) == AppColors.error)
                            const Row(
                              spacing: 5,
                              children: [
                                Icon(Icons.access_time, color: AppColors.error, size: 18),
                                Text('Последняя активность > 10 минут назад', style: TextStyle(color: AppColors.error))
                              ]
                            ),

                            if (_getBoxBorderColor(boxData?['customers']) == AppColors.error)
                            const Row(
                              spacing: 5,
                              children: [
                                Icon(Icons.build_circle, color: AppColors.error, size: 18),
                                Text('Проблемы в коробке', style: TextStyle(color: AppColors.error))
                              ]
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
                            const SizedBox(height: 5),
                            const Row(
                              children: [
                                Icon(Icons.device_hub, color: AppColors.neo),
                                SizedBox(width: 8),
                                Text('Оборудование', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))
                              ]
                            ),
                            const Divider(),
                            if (customerData!['inventory'].isEmpty)
                            const Center(
                              child: Text('У абонента нет оборудования', style: TextStyle(color: AppColors.secondary))
                            ),
                            if (customerData!['inventory'].isNotEmpty)
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
                            if (customerData!['inventory'].isNotEmpty)
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
                                              decoration: TextDecoration.underline)
                                            )
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
                      Expanded(
                        child: Column(
                          children: [
                            BoxCard(
                              lineColor: _getTaskBorderColor(taskData),
                              icon: Icons.assignment,
                              title: 'Задания абонента',
                              last: true,
                              child: customerData == null? const Center(child: AngularProgressBar()) :
                              Column(
                                children: [
                                  if (taskData!.isEmpty)
                                  const Center(
                                    child: Text('У абонента нет заданий', style: TextStyle(color: AppColors.secondary))
                                  )
                                  else
                                  const Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text('ID', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold))
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Text('Тип задания', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Text('Дата создания', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text('Статус', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))
                                      ),
                                      Expanded(child: SizedBox()) // space for open button
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
                                                flex: 2,
                                                child: Text(task['id'].toString(), style: const TextStyle(fontSize: 12)) //
                                              ),
                                              Expanded(
                                                flex: 5,
                                                child: Text(task['name'] ?? '-', softWrap: true, textAlign: TextAlign.left)
                                              ),
                                              Expanded(
                                                flex: 5,
                                                child: Text(formatDate(task['dates']['create']), softWrap: true, textAlign: TextAlign.center,
                                                  style: TextStyle(color: _getTaskDateColor(task['dates']['create'], task['status']['id']))
                                                )
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Text(task['status']['name'], softWrap: true, textAlign: TextAlign.center,
                                                  style: TextStyle(color: getTaskStatusColor(task['status']['id'] ?? 0))
                                                )
                                              ),
                                              Expanded(
                                                child: IconButton(
                                                  onPressed: () => _openTask(task['id']),
                                                  icon: const Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.neo)
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
                            ),
                            const BoxCard(
                              lineColor: AppColors.neo,
                              title: '',
                              last: true,
                              child: Center(child: Text('coming soon', style: TextStyle(color: AppColors.secondary, fontSize: 12)))
                            )
                          ]
                        )
                      )
                      // Expanded(
                      //   child: Row(
                      //     children: [
                      //       BoxCard(
                      //         lineColor: AppColors.main,
                      //         icon: Icons.menu,
                      //         title: 'Меню действий',
                      //         last: !showBox,
                      //         child: Align(
                      //           alignment: Alignment.topCenter,
                      //           child: Column(
                      //             spacing: 5,
                      //             mainAxisSize: MainAxisSize.min,
                      //             children: [
                      //               SizedBox(
                      //                 width: 270,
                      //                 child: ElevatedButton.icon(
                      //                   onPressed: _openAttachs,
                      //                   icon: const Icon(Icons.attach_file),
                      //                   label: const Text('Открыть вложения')
                      //                 )
                      //               ),
                      //               SizedBox(
                      //                 width: 270,
                      //                 child: ElevatedButton.icon(
                      //                   onPressed: !showBox ? _loadBoxData : null,
                      //                   icon: const Icon(Icons.group),
                      //                   label: Text(!showBox ? 'Загрузить соседей' : 'Соседи загружены')
                      //                 )
                      //               ),
                      //               SizedBox(
                      //                 width: 270,
                      //                 child: ElevatedButton.icon(
                      //                   onPressed: _openNewTask,
                      //                   icon: const Icon(Icons.assignment_add),
                      //                   label: const Text('Создать задание')
                      //                 )
                      //               ),
                      //               SizedBox(
                      //                 width: 270,
                      //                 child: ElevatedButton.icon(
                      //                   onPressed: _openONT,
                      //                   icon: const Icon(Icons.router_outlined),
                      //                   label: const Text('Загрузить данные по модему')
                      //                 )
                      //               ),
                      //               SizedBox(
                      //                 width: 270,
                      //                 child: ElevatedButton.icon(
                      //                   onPressed: () => _openCustomerInUS(customerData!['id']),
                      //                   icon: const Icon(Icons.open_in_browser),
                      //                   label: const Text('Открыть абонента в UserSide')
                      //                 )
                      //               ),
                      //               SizedBox(
                      //                 width: 270,
                      //                 child: ElevatedButton.icon(
                      //                   onPressed: () => _copyCustomerLink(customerData!['id']),
                      //                   icon: const Icon(Icons.copy),
                      //                   label: const Text('Скопировать ссылку')
                      //                 )
                      //               )
                      //             ]
                      //           )
                      //         )
                      //       ),
                      //                                       ]
                      //   )
                      // ),
                      // BoxCard(
                      //   lineColor: AppColors.main,
                      //   icon: Icons.device_hub,
                      //   title: 'Оборудование',
                      //   last: true,
                      //   child: customerData == null? const Center(child: AngularProgressBar()) :
                      //   Column(
                      //     children: [
                      //       if (customerData!['inventory'].isEmpty)
                      //       const Center(
                      //         child: Text('У абонента нет оборудования', style: TextStyle(color: AppColors.secondary))
                      //       ),
                      //       if (customerData!['inventory'].isNotEmpty)
                      //       const Row(
                      //         children: [
                      //           Expanded(
                      //             flex: 5,
                      //             child: Text('Название', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold))
                      //           ),
                      //           Expanded(
                      //             flex: 6,
                      //             child: Text('SN', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))
                      //           ),
                      //           Expanded(
                      //             flex: 2,
                      //             child: Text('Кол-во', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))
                      //           )
                      //         ]
                      //       ),
                      //       if (customerData!['inventory'].isNotEmpty)
                      //       Expanded(
                      //         child: ListView.builder(
                      //           itemCount: customerData!['inventory'].length,
                      //           itemBuilder: (c, i){
                      //             final equipment = customerData!['inventory'][i];
                      //             return Padding(
                      //               padding: const EdgeInsets.only(bottom: 6),
                      //               child: Row(
                      //                 children: [
                      //                   Expanded(
                      //                     flex: 5,
                      //                     child: Text(equipment['name'] ?? '-', softWrap: true, textAlign: TextAlign.left)
                      //                   ),
                      //                   Expanded(
                      //                     flex: 6,
                      //                     child: equipment['sn'] == null?
                      //                       const Text('-', softWrap: true, textAlign: TextAlign.center)
                      //                       : InkWell(
                      //                       onTap: _openONT,
                      //                       child: Text(equipment['sn'], softWrap: true, textAlign: TextAlign.center,
                      //                         style: const TextStyle(color: AppColors.neo,
                      //                         decorationColor: AppColors.neo,
                      //                         decoration: TextDecoration.underline))
                      //                     )
                      //                   ),
                      //                   Expanded(
                      //                     flex: 2,
                      //                     child: Text(equipment['amount'].toString(), softWrap: true, textAlign: TextAlign.right)
                      //                   )
                      //                 ]
                      //               )
                      //             );
                      //           }
                      //         )
                      //       )
                      //     ]
                      //   )
                      // )
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



