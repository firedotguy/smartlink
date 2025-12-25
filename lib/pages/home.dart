import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartlink/api.dart';
// import 'package:smartlink/dialogs/attach.dart';
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
    // this.underlineColor = AppColors.neo,
    this.onTap,
    super.key
  });
  final String title;
  final String? value;
  // final Color underlineColor;
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
          Flexible(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: SelectionContainer.disabled(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTap,
                  child: Text(
                    value ?? '-',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: valueColor ?? AppColors.main) //, decoration: TextDecoration.underline, decorationColor: underlineColor)
                  )
                ),
              ),
            )
          )
          else
          Flexible(
            child: Text(
              value ?? '-',
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
          child: SelectionArea(
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
            ),
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
  // TODO: refactor loading (make Enum class)
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
  Map? customer;

  // box
  bool noBox = false;
  Map? box;

  // attach
  Map? attachs;

  // task
  List<Map>? tasks;
  int taskSkip = 0;
  bool taskLimited = false;
  int taskTotal = 0;

  // inventory
  List<Map>? inventory;


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

  String _convertSignal(num? signal) {
    if (signal != null) {
      return (-signal.toDouble()).toStringAsFixed(1);
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

  Color _getSignalColor(num? signal) {
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
      if (customer['status'] == 'Отключен' || _getActivityColor(customer['timestamps']['last_active_at']) == AppColors.error) {
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
      if (neighbours.isEmpty){
        return AppColors.success;
      }
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
        if (task['timestamps']['created_at'] == null || task['status']['id'] == 12 || task['status']['id'] == 10){
          continue;
        }
        final DateTime parsed = DateTime.parse(task['timestamps']['created_at']);
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

  Color _getBalanceColor(num balance) {
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
      l.i('load box data');
      setState(() {
        box = null;
        noBox = false;
      });
      if (customer?['box_id'] == null){
        l.w('no box');
        setState(() {
          noBox = true;
        });
        return;
      }
      box = await getBox(customer!['box_id']);
      if (box!['status'] == 'fail'){
        l.w('box not found');
        setState(() {
          noBox = true;
        });
      }
      // remove search customer from neighbours
      box!['customers']?.removeWhere(
        (n) => n['id'] == customer!['id']
      );
      setState(() {
        load = false;
      });
    } catch (e) {
      l.e('error loading box data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка получения данных коробки: $e', style: const TextStyle(color: AppColors.error)))
        );
      }
    }
  }

  Future<void> _loadTasksData() async {
    try{
      l.i('load tasks');
      final tasksOld = tasks;
      setState(() {
        tasks = null;
      });
      final tasksRes = await getCustomerTasks(customer!['id'], skip: taskSkip);
      l.d('loaded ${tasksRes[0].length + (tasksOld?.length ?? 0)}/${tasksRes[2]} tasks (was ${tasksOld?.length ?? 0})');
      if (tasksOld != null) {
        tasksOld.addAll(tasksRes[0]);
        tasks = tasksOld;
      } else {
        tasks = tasksRes[0];
      }
      taskSkip += 5; // TODO: check #45
      taskLimited = tasksRes[1];
      taskTotal = tasksRes[2];
      setState(() {});
    } catch (e) {
      l.e('error loading tasks: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка получения данных задания: $e', style: const TextStyle(color: AppColors.error)))
        );
      }
    }
  }

  Future<void> _loadInventoryData() async {
    try{
      l.i('load inventory');
      setState(() {
        inventory = null;
      });
      inventory = await getCustomerInventory(customer!['id']);
      setState(() {});
    } catch (e) {
      l.e('error loading inventory: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка получения данных оборудования: $e', style: const TextStyle(color: AppColors.error)))
        );
      }
    }
  }

  void _loadCustomerData(int id, {bool loadAll = true}) {
    try {
      l.i('load customer $id');
      searchController.clear();
      if (!load) {
        setState(() {
          load = true;
          customer = null;
          attachs = null;
          if (loadAll){
            noBox = false;
            inventory = null;
            box = null;
            tasks = null;
            taskSkip = 0;
            taskLimited = false;
            taskTotal = 0;
          }
          search = false;
          searching = false;
        });
        getCustomer(id).then((v){
          customer = v['data'];
          setState(() {
            load = false;
            customers.clear();
          });
          if (loadAll){
            _loadTasksData();
            _loadBoxData();
            _loadInventoryData();
          }
        });
        // if (loadNeighbours != 'never'){
        //   if (customer!['status'] == 'Отключен' || _getActivityColor(customer!['last_activity']) == AppColors.error || loadNeighbours == 'always'){
        //     l.i('something wrong with customer or loadNeighbours is "always", automatically load box');
        //   }
        // } else {
        //   l.i('neighbours not load becuase loadNeigbours is "never"');
        // }
      } else {
        l.i('load customer request ignored because load = true');
      }
    } catch (e) {
      l.e('error getting customer data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка получения данных абонента: $e', style: const TextStyle(color: AppColors.error)))
        );
      }
    }
  }

  Future<void> _onSearchSubmit(String v) async {
    l.i('search submitted - value: $v');
    if (searching) return;
    if (customers.isNotEmpty) {
      _loadCustomerData(customers.first['id']);
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
  // Future<void> _openAttachs() async {
  //   l.i('get attachments for customer ${customer!['id']}');
  //   if (context.mounted) {
  //     l.i('show attach dialog, reason: open attachments');
  //     showDialog(
  //       context: context,
  //       builder: (context) {
  //         return StatefulBuilder(
  //           builder: (context, setStateDialog) {
  //             if (attachs == null) {
  //               try {
  //                 getAttach(customer!['id']).then((res) {
  //                   setState(() {
  //                     attachs = res;
  //                   });
  //                   setStateDialog(() {});
  //                 });
  //               } catch (e) {
  //                 l.e('error getting attachments $e');
  //                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //                     content: Text('Ошибка получения вложений', style: TextStyle(color: AppColors.error))
  //                   )
  //                 );
  //                 Navigator.pop(context);
  //               }
  //             }
  //             return AttachDialog(
  //               data: attachs,
  //               load: attachs == null
  //             );
  //           }
  //         );
  //       }
  //     );
  //   }
  // }

  void _openONT() {
    if (customer == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Дождитесь загрузки абонента', style: TextStyle(color: AppColors.warning))));
      return;
    }
    if (customer!['sn'] == null){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('У абонента нет ТМЦ с SN', style: TextStyle(color: AppColors.warning))));
      return;
    }
    if (customer!['olt_id'] == null){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OLT не найден', style: TextStyle(color: AppColors.error))));
      return;
    }
    showDialog(context: context, builder: (context){
      return OntDialog(oltId: customer!['olt_id'], sn: customer!['sn'], ls: customer!['agreement'], customerId: customer!['id'], isCustomerActive: customer!['status'] == 'Активен');
    });
  }

  void _openNewTask({bool boxTask = false}) async {
    if (customer != null){
      l.i('show newtask dialog');
      final Map? res = await showDialog(context: context, builder: (context){
        return NewTaskDialog(
          customerId: customer!['id'],
          addressId: box?['address_id'],
          phones: customer!['phones'],
          box: boxTask
        );
      });
      if (res == null) return;
      if (!res['box']){
        tasks?.add(res);
      } else {
        box?['tasks']?.add(res['id']);
      }
      setState(() {});
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

  void _openTask({Map<String, dynamic>? data, int? id}){
    showDialog(
      context: context,
      builder: (context){
        return TaskDialog(task: data?['new'] == true? null: data, id: id ?? data?['id']);
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
      _loadCustomerData(widget.customerId!);
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
                            hintText: 'ФИО, ЛС, SN или тел. абонента',
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
                        return MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: SelectionContainer.disabled(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => _loadCustomerData(e['id']),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Text(e['agreement'] == null? e['name'] : '${e['agreement']}: ${e['name']}', style: const TextStyle(fontSize: 15))
                              )
                            ),
                          ),
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
                        lineColor: _getBoxBorderColor(box?['customers']),
                        icon: Icons.dns,
                        title: 'Коробка',
                        miniButtons: [
                          Tooltip(
                            message: 'Создать задание (Магистральный ремонт)',
                            child: IconButton(
                              onPressed: box != null? () => _openNewTask(boxTask: true) : null,
                              icon: Icon(Icons.assignment_add, color: box == null? AppColors.secondary : AppColors.neo, size: 18)
                            )
                          ),
                          Tooltip(
                            message: 'Обновить данные',
                            child: IconButton(
                              onPressed: box != null? _loadBoxData : null,
                              icon: Icon(Icons.refresh, size: 18, color: box == null? AppColors.secondary : AppColors.neo)
                            )
                          )
                        ],
                        child: box == null && !noBox? const Center(child: AngularProgressBar()) : Column(
                          children: [
                            if (noBox)
                            const Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                spacing: 5,
                                children: [
                                  Icon(Icons.warning_amber_outlined, color: AppColors.error),
                                  Text('Коробка не найдена', style: TextStyle(color: AppColors.error))
                                ]
                              ),
                            )
                            else ...[
                              InfoTile(
                                title: 'Название коробки',
                                value: box?['name'] ?? '-'
                              ),
                              InfoTile(
                                title: 'Открытые задания',
                                value: box?['tasks']?.length.toString() ?? '-',
                                valueColor: box?['tasks'] == null? AppColors.main :
                                  box!['tasks'].length == 0? AppColors.success : AppColors.error,
                                onTap: box?['tasks'] == null? null : box!['tasks'].length == 0? null : (){
                                  if (box!['tasks'].length == 1){
                                    _openTask(id: box!['tasks'].first);
                                  } else {
                                    _openTasks(List<int>.from(box!['tasks']));
                                  }
                                }
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
                                    flex: 8,
                                    child: Text('Имя', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold))
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Text('Задания', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))
                                  ),
                                  Expanded(
                                    flex: 7,
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
                              if (box?['customers']?.isNotEmpty ?? false)
                              Expanded(
                                child: ListView.builder(
                                  itemCount: box?['customers']?.length ?? 0,
                                  itemBuilder: (c, i) {
                                    final neighbour = box!['customers'][i];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 8,
                                            child: Text(neighbour['name'], softWrap: true, textAlign: TextAlign.left)
                                          ),
                                          if (neighbour['tasks']?.isEmpty ?? true)
                                          Expanded(
                                            flex: 4,
                                            child: Text(
                                              neighbour['tasks']?.length.toString() ?? '-',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(color: AppColors.success)
                                            )
                                          )
                                          else
                                          Expanded(
                                            flex: 3,
                                            child: MouseRegion(
                                              cursor: SystemMouseCursors.click,
                                              child: SelectionContainer.disabled(
                                                child: GestureDetector(
                                                  behavior: HitTestBehavior.opaque,
                                                  onTap: () {
                                                    if (neighbour['tasks'].length == 1){
                                                      _openTask(id: neighbour['tasks'].first);
                                                    } else {
                                                      _openTasks(List<int>.from(neighbour!['tasks']));
                                                    }
                                                  },
                                                  child: Text(
                                                    neighbour['tasks']?.length.toString() ?? '-',
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(color: AppColors.error)
                                                  )
                                                ),
                                              ),
                                            )
                                          ),
                                          Expanded(
                                            flex: 7,
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
                        lineColor: _getCustomerBorderColor(customer),
                        icon: Icons.person,
                        title: 'Абонент',
                        miniButtons: [
                          Tooltip(
                            message: 'Открыть данные по ONT',
                            child: IconButton(
                              onPressed: _openONT,
                              icon: const Icon(Icons.router_outlined, size: 18, color: AppColors.neo),
                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36)
                            )
                          ),
                          const Tooltip(
                            message: 'Открыть вложения абонента и его заданий',
                            child: IconButton(
                              onPressed: null, //_openAttachs,
                              icon: Icon(Icons.attach_file, size: 18, color: AppColors.secondary),
                              constraints: BoxConstraints(minWidth: 36, minHeight: 36)
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
                            message: 'Открыть абонента в UserSide',
                            child: IconButton(
                              onPressed: () => _openCustomerInUS(customer!['id']),
                              icon: const Icon(Icons.open_in_browser, size: 18, color: AppColors.neo),
                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36)
                            )
                          ),
                          Tooltip(
                            message: 'Копировать ссылку на абонента в UserSide',
                            child: IconButton(
                              onPressed: () => _copyCustomerLink(customer!['id']),
                              icon: const Icon(Icons.copy, size: 18, color: AppColors.neo),
                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36)
                            )
                          ),
                          Tooltip(
                            message: 'Обновить данные',
                            child: IconButton(
                              onPressed: customer != null? () => _loadCustomerData(customer!['id'], loadAll: false) : null,
                              icon: Icon(Icons.refresh, size: 18, color: customer == null? AppColors.secondary : AppColors.neo),
                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36)
                            )
                          )
                        ],
                        child: customer == null? const Center(child: AngularProgressBar()) :
                        Column(
                          children: [
                            if (customer!['is_potential'])
                            const Row(
                              spacing: 5,
                              children: [
                                Icon(Icons.favorite, color: AppColors.neo, size: 18),
                                Text('Потенциальный абонент', style: TextStyle(color: AppColors.neo))
                              ]
                            ),
                            if (customer!['is_corporate'])
                            const Row(
                              spacing: 5,
                              children: [
                                Icon(Icons.business, color: AppColors.neo, size: 18),
                                Text('Юридическое лицо', style: TextStyle(color: AppColors.neo))
                              ]
                            ),
                            if (!customer!['has_billing'])
                            const Row(
                              spacing: 5,
                              children: [
                                Icon(Icons.money_off_csred_outlined, color: AppColors.error, size: 18),
                                Text('Нет в биллинге', style: TextStyle(color: AppColors.error))
                              ]
                            ),
                            if (customer!['olt_id'] == null)
                            const Row(
                              spacing: 5,
                              children: [
                                Icon(Icons.cable, color: AppColors.warning, size: 18),
                                Text('Абонент не коммутирован', style: TextStyle(color: AppColors.warning))
                              ]
                            ),
                        
                            // if ((customer!['onu_level'] ?? 0) < -25)
                            // Row(
                            //   spacing: 5,
                            //   children: [
                            //     const Icon(Icons.network_check, color: AppColors.error, size: 18),
                            //     Text('Низкий уровень сигнала', style: TextStyle(color: _getSignalColor(customer!['onu_level'])))
                            //   ]
                            // ),

                            if (customer!['status'] == 'Отключен')
                            const Row(
                              spacing: 5,
                              children: [
                                Icon(Icons.power_settings_new, color: AppColors.error, size: 18),
                                Text('Абонент отключен', style: TextStyle(color: AppColors.error))
                              ]
                            ),

                            if (customer!['status'] == 'Пауза')
                            const Row(
                              spacing: 5,
                              children: [
                                Icon(Icons.pause_circle_outline, color: AppColors.warning, size: 18),
                                Text('Абонент на паузе', style: TextStyle(color: AppColors.warning))
                              ]
                            ),

                            if (_getActivityColor(customer!['timestamps']['last_active_at']) == AppColors.error)
                            const Row(
                              spacing: 5,
                              children: [
                                Icon(Icons.access_time, color: AppColors.error, size: 18),
                                Text('Последняя активность > 10 минут назад', style: TextStyle(color: AppColors.error))
                              ]
                            ),

                            if (_getBoxBorderColor(box?['customers']) == AppColors.error)
                            const Row(
                              spacing: 5,
                              children: [
                                Icon(Icons.build_circle_outlined, color: AppColors.error, size: 18),
                                Text('Проблемы в коробке', style: TextStyle(color: AppColors.error))
                              ]
                            ),
                            InfoTile(
                              title: 'ФИО',
                              value: customer!['name']
                            ),
                            InfoTile(
                              title: 'Лицевой счёт',
                              value: customer!['agreement']?.toString()
                            ),
                            InfoTile(
                              title: 'Баланс',
                              value: '${customer!['balance']} сом',
                              valueColor: _getBalanceColor((customer!['balance'] ?? 0) as num)
                            ),
                            InfoTile(
                              title: 'Статус',
                              value: customer!['status'],
                              valueColor: _getStatusColor(customer!['status'] ?? '-')
                            ),
                            InfoTile(
                              title: 'Группа',
                              value: customer!['group']?['name']
                            ),
                            InfoTile(
                              title: 'Последняя активность',
                              value: formatDate(customer!['timestamps']['last_active_at']),
                              valueColor: _getActivityColor(customer!['timestamps']['last_active_at'] ?? '-')
                            ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     Text('Уровень сигнала:'),
                            //     Text((customer!['onu_level']).toString(), style: TextStyle(color: _getSignalColor(customer!['onu_level'])))
                            //   ]
                            // ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Номер телефона', style: TextStyle(color: AppColors.secondary)),
                                Column(
                                  children: customer!['phones'].map<Widget>((phone) {
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
                                    children: customer!['tariffs'].map<Widget>((tariff) {
                                      return Text(tariff['name'] ?? '-', softWrap: true, textAlign: TextAlign.right);
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
                            if (customer!['geodata']?['coord'] != null)
                            InfoTile(title: 'Координаты', value: customer!['geodata']['coord'].join(', ')),
                            if (customer!['geodata']?['address'] != null)
                            InfoTile(title: 'Адрес', value: customer!['geodata']['address']),
                            if (customer!['geodata']?['2gis_link'] != null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Ссылка 2GIS', style: TextStyle(color: AppColors.secondary)),
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () async => await _openUrl(customer!['geodata']['2gis_link']),
                                    child: const Icon(Icons.public, size: 18, color: AppColors.neo)
                                  ),
                                )
                              ]
                            ),
                            if (customer!['geodata']?['neo_link'] != null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Ссылка Neotelecom', style: TextStyle(color: AppColors.secondary)),
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () async => await _openUrl(customer!['geodata']['neo_link']),
                                    child: const Icon(Icons.public, size: 18, color: AppColors.neo)
                                  ),
                                )
                              ]
                            ),
                            if (customer!['geodata'] == null)
                            const Text('Нет данных', style: TextStyle(color: AppColors.secondary)),
                            // const SizedBox(height: 5),
                            // const Row(
                            //   children: [
                            //     Icon(Icons.device_hub, color: AppColors.neo),
                            //     SizedBox(width: 8),
                            //     Text('Оборудование', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))
                            //   ]
                            // ),
                            // const Divider(),
                            // if (customer!['inventory'].isEmpty)
                            // const Center(
                            //   child: Text('У абонента нет оборудования', style: TextStyle(color: AppColors.secondary))
                            // ),
                            // if (customer!['inventory'].isNotEmpty)
                            // const Row(
                            //   children: [
                            //     Expanded(
                            //       flex: 7,
                            //       child: Text('Название', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold))
                            //     ),
                            //     Expanded(
                            //       flex: 6,
                            //       child: Text('SN', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))
                            //     ),
                            //     Expanded(
                            //       flex: 2,
                            //       child: Text('Кол-во', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))
                            //     )
                            //   ]
                            // ),
                            // if (customer!['inventory'].isNotEmpty)
                            // ListView.builder(
                            //   shrinkWrap: true,
                            //   physics: const NeverScrollableScrollPhysics(),
                            //   itemCount: customer!['inventory'].length,
                            //   itemBuilder: (c, i){
                            //     final equipment = customer!['inventory'][i];
                            //     return Padding(
                            //       padding: const EdgeInsets.only(bottom: 6),
                            //       child: Row(
                            //         children: [
                            //           Expanded(
                            //             flex: 7,
                            //             child: Text(equipment['name'] ?? '-', softWrap: true, textAlign: TextAlign.left)
                            //           ),
                            //           Expanded(
                            //             flex: 6,
                            //             child: equipment['sn'] == null?
                            //               const Text('-', softWrap: true, textAlign: TextAlign.center)
                            //               : MouseRegion(
                            //                 cursor: SystemMouseCursors.click,
                            //                 child: SelectionContainer.disabled(
                            //                   child: GestureDetector(
                            //                     behavior: HitTestBehavior.opaque,
                            //                     onTap: _openONT,
                            //                     child: Text(equipment['sn'], softWrap: true, textAlign: TextAlign.center,
                            //                       style: const TextStyle(color: AppColors.neo,
                            //                       decorationColor: AppColors.neo,
                            //                       decoration: TextDecoration.underline)
                            //                     )
                            //                   ),
                            //                 ),
                            //               )
                            //           ),
                            //           Expanded(
                            //             flex: 2,
                            //             child: Text(equipment['amount']?.toString() ?? '0', softWrap: true, textAlign: TextAlign.right)
                            //           )
                            //         ]
                            //       )
                            //     );
                            //   }
                            // )
                          ]
                        )
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            BoxCard(
                              lineColor: _getTaskBorderColor(tasks),
                              icon: Icons.assignment,
                              title: 'Задания абонента',
                              flex: 3,
                              last: true,
                              miniButtons: [
                                Tooltip(
                                  message: 'Обновить данные',
                                  child: IconButton(
                                    onPressed: tasks != null? _loadTasksData : null,
                                    icon: Icon(Icons.refresh, size: 18, color: tasks == null? AppColors.secondary : AppColors.neo),
                                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36)
                                  )
                                )
                              ],
                              child: tasks == null? const Center(child: AngularProgressBar()) :
                              Column(
                                children: [
                                  if (tasks!.isEmpty)
                                  const Center(
                                    child: Text('У абонента нет заданий', style: TextStyle(color: AppColors.secondary))
                                  )
                                  else
                                  const Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text('ID', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold))
                                      ),
                                      Expanded(
                                        flex: 7,
                                        child: Text('Тип задания', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))
                                      ),
                                      Expanded(
                                        flex: 6,
                                        child: Text('Дата создания', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Text('Статус', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))
                                      ),
                                      Expanded( // space for open button
                                        flex: 2,
                                        child: SizedBox()
                                      )
                                    ]
                                  ),
                                  if (tasks!.isNotEmpty)
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: tasks!.length,
                                      itemBuilder: (c, i){
                                        final task = tasks![i];
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 6),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: Text(task['id'].toString(), style: const TextStyle(fontSize: 13)) //
                                              ),
                                              Expanded(
                                                flex: 7,
                                                child: Text(task['type']['name'] ?? '-', softWrap: true, textAlign: TextAlign.left)
                                              ),
                                              Expanded(
                                                flex: 6,
                                                child: Text(formatDate(task['timestamps']['created_at']), softWrap: true, textAlign: TextAlign.center,
                                                  style: TextStyle(color: _getTaskDateColor(task['timestamps']['created_at'], task['status']['id']), fontSize: 13) //
                                                )
                                              ),
                                              Expanded(
                                                flex: 5,
                                                child: Text(task['status']['name'], softWrap: true, textAlign: TextAlign.center,
                                                  style: TextStyle(color: getTaskStatusColor(task['status']['id'] ?? 0))
                                                )
                                              ),
                                              Flexible(
                                                flex: 2,
                                                child: IconButton(
                                                  onPressed: () => _openTask(data: Map<String, dynamic>.from(task)),
                                                  icon: const Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.neo)
                                                )
                                              )
                                            ]
                                          )
                                        );
                                      }
                                    )
                                  ),
                                  if (tasks!.isNotEmpty)
                                  Text('Загружено ${tasks?.length ?? 0}/$taskTotal', style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
                                  if (taskLimited)
                                  ElevatedButton(
                                    onPressed: _loadTasksData,
                                    child: const Text('Загрузить еще')
                                  )
                                ]
                              )
                            ),
                            BoxCard(
                              lineColor: AppColors.main,
                              icon: Icons.device_hub,
                              title: 'Оборудование',
                              flex: 2,
                              last: true,
                              miniButtons: [
                                Tooltip(
                                  message: 'Обновить данные',
                                  child: IconButton(
                                    onPressed: inventory != null? _loadInventoryData : null,
                                    icon: Icon(Icons.refresh, size: 18, color: inventory == null? AppColors.secondary : AppColors.neo),
                                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36)
                                  )
                                )
                              ],
                              child: inventory == null? const Center(child: AngularProgressBar()) :
                              Column(
                                children: [
                                  if (inventory!.isEmpty)
                                  const Center(
                                    child: Text('У абонента нет оборудования', style: TextStyle(color: AppColors.secondary))
                                  ),
                                  if (inventory!.isNotEmpty)
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
                                  if (inventory!.isNotEmpty)
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: inventory!.length,
                                      itemBuilder: (c, i){
                                        final equipment = inventory![i];
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
                            )
                            // const BoxCard(
                            //   lineColor: AppColors.neo,
                            //   title: '',
                            //   last: true,
                            //   child: Center(child: Text('coming soon', style: TextStyle(color: AppColors.secondary, fontSize: 12)))
                            // )
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
                      //                   onPressed: () => _openCustomerInUS(customer!['id']),
                      //                   icon: const Icon(Icons.open_in_browser),
                      //                   label: const Text('Открыть абонента в UserSide')
                      //                 )
                      //               ),
                      //               SizedBox(
                      //                 width: 270,
                      //                 child: ElevatedButton.icon(
                      //                   onPressed: () => _copyCustomerLink(customer!['id']),
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

