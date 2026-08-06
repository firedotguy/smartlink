import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Chip;
import 'package:flutter/services.dart';
import 'package:flutter_date_formatter/flutter_date_formatter.dart';
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
        this.preview = false,
        // this.underlineColor = AppColors.neo,
        this.onTap,
        this.action,
        super.key
    });
    final String title;
    final String? value;
    final bool preview;
    // final Color underlineColor;
    final VoidCallback? onTap;
    final Widget? action;
    final Color? valueColor;

    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    Row(
                        spacing: 8,
                        children: [
                            Text(title, style: const TextStyle(color: AppColors.secondary)),
                            if (preview)
                            const Tooltip(
                                message: 'Функция в разработке',
                                child: Chip(text: 'Preview', color: AppColors.success)
                            )
                        ],
                    ),
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
                                )
                            )
                        )
                    )
                    else if (action != null)
                    Flexible(
                        child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                                Text(
                                    value ?? '-',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(color: valueColor ?? AppColors.main)
                                ),
                                const SizedBox(width: 8),
                                action!
                            ]
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


class BuildingCard extends StatelessWidget {

    const BuildingCard({
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

    bool search = true;
    bool searching = false;
    List<Map> customers = [];
    TextEditingController searchController = TextEditingController();
    Timer? _debounce;
    bool customerNotFound = false;
    int searchVersion = 0;
    int debounce = 300;

    int? id;
    Map? customer;
    bool noBuilding = false;
    Map? building;
    Map? attachs;
    List<Map>? tasks;
    List<Map>? items;

    Future<void> _openUrl(String link) async {
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
    Color _getActivityColor(String? lastActivity) {
        try {
            final parsed = DateTime.parse(lastActivity!.replaceAll('.', '-'));
            final difference = DateTime.now().difference(parsed).inMinutes;
            return difference <= 15? AppColors.success : AppColors.error;
        } catch (e) {
            return AppColors.secondary;
        }
    }

    Color? _getDiconnectDateColor(String date) {
        try {
            final parsed = DateTime.parse(date.replaceAll('.', '-'));
            final difference = parsed.difference(DateTime.now()).inDays;
            return difference < 3? AppColors.error : difference < 10? AppColors.warning : AppColors.success;
        } catch (e) {
            return AppColors.secondary;
        }
    }

    Color _getStatusColor(String status) {
        if (status == 'active') {
            return AppColors.success;
        }
        if (status == 'pause') {
            return AppColors.warning;
        }
        if (status == 'inactive') {
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
        if (customer?['status'] != null) {
            if (customer!['status'] == 'inactive' || _getActivityColor(customer['last_active_at']) == AppColors.error) {
                return AppColors.error;
            }
            if (customer['status'] == 'pause') {
                return AppColors.warning;
            }
            return AppColors.success;
        }
        return AppColors.main;
    }

    Color _getBuildingBorderColor(List<dynamic>? neighbours) {
        if (neighbours != null) {
            if (neighbours.isEmpty){
                return AppColors.success;
            }
            final allInactive = neighbours.every(
                (n) => _getActivityColor(n['last_active_at']) == AppColors.error
            );
            return allInactive ? AppColors.error : AppColors.success;
        }
        return AppColors.main;
    }

    Color _getTaskBorderColor(List<Map>? tasks) {
        if (tasks != null){
            for (var task in tasks){
                if (task['created_at'] == null || task['status']['id'] == 12 || task['status']['id'] == 10){
                    continue;
                }
                final DateTime parsed = DateTime.parse(task['created_at']);
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
    Future<void> _loadBuildingData({bool firstLoad = false}) async {
        try{
            l.i('load building data');
            setState(() {
                building = null;
                noBuilding = false;
            });
            if (customer?['address']['id'] == null){
                l.w('no building');
                setState(() {
                    noBuilding = true;
                });
                return;
            }
            // if (firstLoad || building2 == null){
            building = await getBuilding(customer!['address']['id']);
            if (building!['detail'] != null){
                l.w('building not found');
                setState(() {
                    noBuilding = true;
                });
            }
            // } else {
            //     final Map<String, dynamic> neighbours = await getCustomers(List<int>.from(building2['remaining_customer_ids']), limit: neighbourLimit, skip: buildingSkip);
            //     if (neighbours['status'] == 'fail'){
            //         l.w('fail to load neighbours');
            //         if (mounted){
            //             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка загрузки соседей', style: TextStyle(color: AppColors.error))));
            //         }
            //     }
            //     l.d('loaded ${building2['customers'].length + neighbours['data'].length}/$buildingTotal neighbours (was ${building2['customers'].length})');
            //     building2['customers'].addAll(neighbours['data']);
            //     building = building2;
            //     buildingLimited = buildingTotal > building2['customers'].length;
            //     buildingSkip += neighbourLimit;
            // }

            setState(() {
                load = false;
            });
        } catch (e) {
            l.e('error loading building data: $e');
            if (mounted) {
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ошибка получения данных коробки: $e', style: const TextStyle(color: AppColors.error)))
                );
            }
        }
    }

    Future<void> _loadTasksData({int? customerId}) async {
        try{
            l.i('load tasks');
            setState(() {
                tasks = null;
            });
            tasks = await getCustomerTasks(customerId ?? customer!['id']);
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

    Future<void> _loadItemsData({int? customerId}) async {
        try{
            l.i('load items');
            setState(() {
                items = null;
            });
            items = await getCustomerItems(customerId ?? customer!['id']);
            setState(() {});
        } catch (e) {
            l.e('error loading items: $e');
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
                        noBuilding = false;
                        items = null;
                        building = null;
                        tasks = null;
                    }
                    search = false;
                    searching = false;
                    customers.clear();
                });
                getCustomer(id).then((v){
                    customer = v;
                    setState(() {
                        load = false;
                    });
                    _loadBuildingData(firstLoad: true);
                });
                if (loadAll){
                    _loadTasksData(customerId: id);
                    _loadItemsData(customerId: id);
                }
                // if (loadNeighbours != 'never'){
                //     if (customer!['status'] == 'Отключен' || _getActivityColor(customer!['last_activity']) == AppColors.error || loadNeighbours == 'always'){
                //         l.i('something wrong with customer or loadNeighbours is "always", automatically load building');
                //     }
                // } else {
                //     l.i('neighbours not load becuase loadNeigbours is "never"');
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
            final List<Map> res = await searchCustomers(v);

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
    //     l.i('get attachments for customer ${customer!['id']}');
    //     if (context.mounted) {
    //         l.i('show attach dialog, reason: open attachments');
    //         showDialog(
    //             context: context,
    //             builder: (context) {
    //                 return StatefulBuilder(
    //                     builder: (context, setStateDialog) {
    //                         if (attachs == null) {
    //                             try {
    //                                 getAttach(customer!['id']).then((res) {
    //                                     setState(() {
    //                                         attachs = res;
    //                                     });
    //                                     setStateDialog(() {});
    //                                 });
    //                             } catch (e) {
    //                                 l.e('error getting attachments $e');
    //                                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    //                                         content: Text('Ошибка получения вложений', style: TextStyle(color: AppColors.error))
    //                                     )
    //                                 );
    //                                 Navigator.pop(context);
    //                             }
    //                         }
    //                         return AttachDialog(
    //                             data: attachs,
    //                             load: attachs == null
    //                         );
    //                     }
    //                 );
    //             }
    //         );
    //     }
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
            return OntDialog(oltId: customer!['olt_id'], sn: customer!['sn'], agreement: customer!['agreement']['number'], customerId: customer!['id'], isCustomerActive: customer!['status'] == 'active');
        });
    }

    void _openNewTask({bool buildingTask = false}) async {
        if (customer != null){
            l.i('show newtask dialog');
            final Map? res = await showDialog(context: context, builder: (context){
                return NewTaskDialog(
                    customerId: customer!['id'],
                    addressId: building?['address_id'],
                    phones: customer!['phones'],
                    building: buildingTask
                );
            });
            if (res == null) return;
            if (!res['building']){
                tasks?.add(res);
            } else {
                building?['tasks']?.add(res['id']);
            }
            setState(() {});
        } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Абонент не загружен', style: TextStyle(color: AppColors.warning))
            ));
        }
    }

    void _openObjectInUS(String type, int id) async {
        await _openUrl('https://us.neotelecom.kg/$type/$id');
    }

    void _copyObjectUSLink(String type, int id) async {
        await Clipboard.setData(ClipboardData(text: 'https://us.neotelecom.kg/$type/$id'));
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
            //     padding: const EdgeInsets.only(right: 16, bottom: 32),
            //     child: SizedBox(
            //         width: MediaQuery.of(context).size.width / 3.5,
            //         child: id==null? const Text('Чат не доступен в debug режиме', style: TextStyle(color: AppColors.secondary), textAlign: TextAlign.right) : ChatWidget(
            //             employeeId: id!,
            //             initialChatId: widget.initialChatId,
            //             initialOpenChat: widget.initialOpenChat
            //         )
            //     )
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
                                                        prefixIcon: const Icon(Icons.search, color: AppColors.secondary),
                                                        hintText: 'ФИО, ЛС, SN или телефон абонента',
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
                                            BuildingCard(
                                                lineColor: _getBuildingBorderColor(building?['customers']),
                                                icon: Icons.dns,
                                                title: 'Коробка',
                                                miniButtons: [
                                                    Tooltip(
                                                        message: 'Создать задание (Магистральный ремонт)',
                                                        child: IconButton(
                                                            onPressed: building != null? () => _openNewTask(buildingTask: true) : null,
                                                            icon: Icon(Icons.assignment_add, color: building == null? AppColors.secondary : AppColors.neo, size: 18)
                                                        )
                                                    ),
                                                    Tooltip(
                                                        message: 'Показать на карте',
                                                        child: IconButton(
                                                            onPressed: building != null? () => _openUrl('https://us.neotelecom.kg/map/show?opt_wh=1&by_building=${building!['id']}&is_show_center_marker=1@${building!['coordinates'][0]},${building!['coordinates'][1]},18z') : null,
                                                            icon: Icon(Icons.map, color: building == null? AppColors.secondary : AppColors.neo, size: 18)
                                                        )
                                                    ),
                                                    Tooltip(
                                                        message: 'Открыть коробку в UserSide',
                                                        child: IconButton(
                                                            onPressed: () => _openObjectInUS('building', building!['building_id']),
                                                            icon: const Icon(Icons.open_in_browser, size: 18, color: AppColors.neo),
                                                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36)
                                                        )
                                                    ),
                                                    Tooltip(
                                                        message: 'Копировать ссылку на коробке в UserSide',
                                                        child: IconButton(
                                                            onPressed: () => _copyObjectUSLink('building', building!['building_id']),
                                                            icon: const Icon(Icons.copy, size: 18, color: AppColors.neo),
                                                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36)
                                                        )
                                                    ),
                                                    Tooltip(
                                                        message: 'Обновить данные',
                                                        child: IconButton(
                                                            onPressed: building != null? () => _loadBuildingData(firstLoad: true) : null,
                                                            icon: Icon(Icons.refresh, size: 18, color: building == null? AppColors.secondary : AppColors.neo)
                                                        )
                                                    )
                                                ],
                                                child: building == null && !noBuilding? const Center(child: AngularProgressBar()) : Column(
                                                    children: [
                                                        if (noBuilding)
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
                                                                title: 'Название',
                                                                value: building?['name'] ?? '-'
                                                            ),
                                                            InfoTile(
                                                                title: 'Тип',
                                                                value: {'multiflat': 'Многоквартирный дом', 'private': 'Частный дом', 'office': 'Офисное здание', 'new': 'Новостройки', 'ravshan': 'Равшан'}[building?['type']]
                                                            ),
                                                            if (building?['coordinates'] != null)
                                                            InfoTile(
                                                                title: 'Координаты',
                                                                value: building?['coordinates'].join(', ')
                                                            ),
                                                            if (building?['install_type'] != null)
                                                            InfoTile(
                                                                title: 'Тип устнановки',
                                                                value: building?['install_type'] ?? '-'
                                                            ),
                                                            if (building?['build_status'] != null)
                                                            InfoTile(
                                                                title: 'Статус строительства',
                                                                value: building?['build_status'] ?? '-'
                                                            ),
                                                            InfoTile(
                                                                title: 'Открытые задания',
                                                                value: building?['tasks']?.length.toString() ?? '0',
                                                                valueColor: building?['tasks'] == null? AppColors.main :
                                                                    building!['tasks'].length == 0? AppColors.success : AppColors.error,
                                                                onTap: building?['tasks'] == null? null : building!['tasks'].length == 0? null : (){
                                                                    if (building!['tasks'].length == 1){
                                                                        _openTask(id: building!['tasks'].first);
                                                                    } else {
                                                                        _openTasks(List<int>.from(building!['tasks']));
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
                                                                        flex: 2,
                                                                        child: Text('ЛС', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold))
                                                                    ),
                                                                    Expanded(
                                                                        flex: 7,
                                                                        child: Text('Имя', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold))
                                                                    ),
                                                                    // Expanded(
                                                                    //     flex: 4,
                                                                    //     child: Text('Задания', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))
                                                                    // ),
                                                                    Expanded(
                                                                        flex: 4,
                                                                        child: Text('Активность', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))
                                                                    ),
                                                                    Expanded(
                                                                        flex: 3,
                                                                        child: Text('Статус', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))
                                                                    ),
                                                                    Expanded(
                                                                        flex: 1,
                                                                        child: Text('rx', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))
                                                                    )
                                                                ]
                                                            ),
                                                            const SizedBox(height: 8),
                                                            if (building?['customers']?.isNotEmpty ?? false)
                                                            Expanded(
                                                                child: ListView.builder(
                                                                    itemCount: building?['customers']?.length ?? 0,
                                                                    itemBuilder: (c, i) {
                                                                        final neighbour = building!['customers'][i];
                                                                        return Padding(
                                                                            padding: const EdgeInsets.only(bottom: 6),
                                                                            child: Row(
                                                                                children: [
                                                                                    Expanded(
                                                                                        flex: 2,
                                                                                        child: Text(neighbour['agreement'] ?? '-', softWrap: true, textAlign: TextAlign.left)
                                                                                    ),
                                                                                    Expanded(
                                                                                        flex: 7,
                                                                                        child: Text(neighbour['name'], softWrap: true, textAlign: TextAlign.left)
                                                                                    ),
                                                                                    // if (neighbour['tasks']?.isEmpty ?? true)
                                                                                    // Expanded(
                                                                                    //     flex: 4,
                                                                                    //     child: Text(
                                                                                    //         neighbour['tasks']?.length.toString() ?? '0',
                                                                                    //         textAlign: TextAlign.center,
                                                                                    //         style: const TextStyle(color: AppColors.success)
                                                                                    //     )
                                                                                    // )
                                                                                    // else
                                                                                    // Expanded(
                                                                                    //     flex: 3,
                                                                                    //     child: MouseRegion(
                                                                                    //         cursor: SystemMouseCursors.click,
                                                                                    //         child: SelectionContainer.disabled(
                                                                                    //             child: GestureDetector(
                                                                                    //                 behavior: HitTestBehavior.opaque,
                                                                                    //                 onTap: () {
                                                                                    //                     if (neighbour['tasks'].length == 1){
                                                                                    //                         _openTask(id: neighbour['tasks'].first);
                                                                                    //                     } else {
                                                                                    //                         _openTasks(List<int>.from(neighbour!['tasks']));
                                                                                    //                     }
                                                                                    //                 },
                                                                                    //                 child: Text(
                                                                                    //                     neighbour['tasks']?.length.toString() ?? '0',
                                                                                    //                     textAlign: TextAlign.center,
                                                                                    //                     style: const TextStyle(color: AppColors.error)
                                                                                    //                 )
                                                                                    //             ),
                                                                                    //         ),
                                                                                    //     )
                                                                                    // ),
                                                                                    Expanded(
                                                                                        flex: 4,
                                                                                        child: Text(formatDate(neighbour['last_active_at']), textAlign: TextAlign.center,
                                                                                            style: TextStyle(color: _getActivityColor(neighbour['last_active_at']))
                                                                                        )
                                                                                    ),
                                                                                    Expanded(
                                                                                        flex: 3,
                                                                                        child: Text(
                                                                                            neighbour['status'] == 'active'? 'Активен' : neighbour['status'] == 'pause'? 'Пауза' : 'Отключен', textAlign: TextAlign.center,
                                                                                            style: TextStyle(color: _getStatusColor(neighbour['status']))
                                                                                        )
                                                                                    ),
                                                                                    Expanded(
                                                                                        flex: 1,
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
                                                            const Text('У абонента нет соседей', style: TextStyle(color: AppColors.secondary)),
                                                        ]
                                                    ]
                                                )
                                            ),
                                            BuildingCard(
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
                                                            onPressed: () => _openObjectInUS('customer', customer!['id']),
                                                            icon: const Icon(Icons.open_in_browser, size: 18, color: AppColors.neo),
                                                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36)
                                                        )
                                                    ),
                                                    Tooltip(
                                                        message: 'Копировать ссылку на абонента в UserSide',
                                                        child: IconButton(
                                                            onPressed: () => _copyObjectUSLink('customer', customer!['id']),
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
                                                        //     spacing: 5,
                                                        //     children: [
                                                        //         const Icon(Icons.network_check, color: AppColors.error, size: 18),
                                                        //         Text('Низкий уровень сигнала', style: TextStyle(color: _getSignalColor(customer!['onu_level'])))
                                                        //     ]
                                                        // ),

                                                        if (customer!['status'] == 'inactive')
                                                        const Row(
                                                            spacing: 5,
                                                            children: [
                                                                Icon(Icons.power_settings_new, color: AppColors.error, size: 18),
                                                                Text('Абонент отключен', style: TextStyle(color: AppColors.error))
                                                            ]
                                                        ),

                                                        if (customer!['status'] == 'pause')
                                                        const Row(
                                                            spacing: 5,
                                                            children: [
                                                                Icon(Icons.pause_circle_outline, color: AppColors.warning, size: 18),
                                                                Text('Абонент на паузе', style: TextStyle(color: AppColors.warning))
                                                            ]
                                                        ),

                                                        if (_getActivityColor(customer!['last_active_at']) == AppColors.error)
                                                        Row(
                                                            spacing: 5,
                                                            children: [
                                                                const Icon(Icons.access_time, color: AppColors.error, size: 18),
                                                                Text('Последняя активность ${FlutterDateFormatter.formatRelativeDateTime(DateTime.parse(customer!['last_active_at'].replaceAll('.', '-')), locale: 'ru')}', style: const TextStyle(color: AppColors.error))
                                                            ]
                                                        ),

                                                        if (_getBuildingBorderColor(building?['customers']) == AppColors.error)
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
                                                            value: customer!['agreement']?['number']
                                                        ),
                                                        InfoTile(
                                                            title: 'Баланс',
                                                            value: '${customer!['balance']} сом',
                                                            valueColor: _getBalanceColor((customer!['balance'] ?? 0) as num)
                                                        ),
                                                        InfoTile(
                                                            title: 'Статус',
                                                            value: customer!['status'] == 'active'? 'Активен' : customer!['status'] == 'pause'? 'Пауза' : 'Отключен',
                                                            valueColor: _getStatusColor(customer!['status'] ?? '-')
                                                        ),
                                                        // InfoTile(
                                                        //     title: 'Дата создания',
                                                        //     value: formatDate(customer!['created_at']),
                                                        //     valueColor: AppColors.main
                                                        // ),
                                                        InfoTile(
                                                            title: 'Дата подключения',
                                                            value: formatDate(customer!['connected_at']),
                                                            valueColor: AppColors.main
                                                        ),
                                                        InfoTile(
                                                            title: 'Группа',
                                                            value: customer!['group']?['name']
                                                        ),
                                                        InfoTile(
                                                            title: 'Последняя активность',
                                                            value: formatDate(customer!['last_active_at']),
                                                            valueColor: _getActivityColor(customer!['last_active_at'] ?? '-')
                                                        ),
                                                        // InfoTile(
                                                        //     title: 'Последняя INET активность',
                                                        //     value: formatDate(customer!['last_inet_active_at']),
                                                        //     valueColor: _getActivityColor(customer!['last_inet_active_at'] ?? '-')
                                                        // ),
                                                        // Row(
                                                        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        //     children: [
                                                        //         Text('Уровень сигнала:'),
                                                        //         Text((customer!['onu_level']).toString(), style: TextStyle(color: _getSignalColor(customer!['onu_level'])))
                                                        //     ]
                                                        // ),
                                                        const SizedBox(height: 5),
                                                        Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                                Text(customer!['phones'].length == 1? 'Номер телефона' : 'Номера телефонов', style: const TextStyle(color: AppColors.secondary)),
                                                                Column(
                                                                    children: customer!['phones'].map<Widget>((phone) {
                                                                        return Row(
                                                                            children: [
                                                                                const Icon(Icons.phone, size: 18, color: AppColors.neo),
                                                                                const SizedBox(width: 8),
                                                                                Text(phone.toString())
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
                                                                Text(customer!['tariffs'].length == 1? 'Тариф' : 'Тарифы', style: const TextStyle(color: AppColors.secondary)),
                                                                Expanded(
                                                                    child: Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                                        children: customer!['tariffs'].map<Widget>((tariff) {
                                                                            return Text(tariff['content'] ?? '-', softWrap: true, textAlign: TextAlign.right);
                                                                        }).toList()
                                                                    )
                                                                )
                                                            ]
                                                        ),
                                                        const SizedBox(height: 5),
                                                        if (customer!['will_disconnect_at'] != null)
                                                        InfoTile(
                                                            title: 'Плановая дата отключения',
                                                            value: formatDate(customer!['will_disconnect_at']),
                                                            preview: true,
                                                            valueColor: _getDiconnectDateColor(customer!['will_disconnect_at'])
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
                                                        // if (customer!['coordinates'] != null)
                                                        // InfoTile(title: 'Координаты', value: customer!['coordinates'].join(', ')),
                                                        if (customer!['address']?['label'] != null)
                                                        InfoTile(
                                                            title: 'Адрес',
                                                            value: customer!['address']['label'],
                                                            action: Tooltip(
                                                                message: 'Открыть в 2GIS',
                                                                child: MouseRegion(
                                                                    cursor: SystemMouseCursors.click,
                                                                    child: GestureDetector(
                                                                        behavior: HitTestBehavior.opaque,
                                                                        onTap: () async => await _openUrl('https://2gis.kg/osh/search/${customer!['address']['label']}'),
                                                                        child: const Icon(Icons.open_in_new, size: 18, color: AppColors.neo)
                                                                    )
                                                                )
                                                            )
                                                        ),
                                                        if (customer!['coordinates'] != null)
                                                        Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                                const Text('Открыть на карте Neotelecom', style: TextStyle(color: AppColors.secondary)),
                                                                MouseRegion(
                                                                    cursor: SystemMouseCursors.click,
                                                                    child: GestureDetector(
                                                                        behavior: HitTestBehavior.opaque,
                                                                        onTap: () async => await _openUrl('https://us.neotelecom.kg/map/show?lat=${customer!['coordinates'][0]}&lon=${customer!['coordinates'][1]}&zoom=18'),
                                                                        child: const Icon(Icons.public, size: 18, color: AppColors.neo)
                                                                    ),
                                                                )
                                                            ]
                                                        ),
                                                        if (customer!['coordinates'] != null)
                                                        Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                                const Text('Открыть на карте 2GIS', style: TextStyle(color: AppColors.secondary)),
                                                                MouseRegion(
                                                                    cursor: SystemMouseCursors.click,
                                                                    child: GestureDetector(
                                                                        behavior: HitTestBehavior.opaque,
                                                                        onTap: () async => await _openUrl('http://2gis.kg/geo/${customer!['coordinates'][0]},${customer!['coordinates'][1]}'),
                                                                        child: const Icon(Icons.public, size: 18, color: AppColors.neo)
                                                                    ),
                                                                )
                                                            ]
                                                        ),
                                                        if (customer!['coordinates'] != null)
                                                        InfoTile(
                                                            title: 'Координаты',
                                                            value: customer!['coordinates'].join(', ')
                                                        ),
                                                        if (customer!['address']['entrance'] != null)
                                                        InfoTile(
                                                            title: 'Подъезд',
                                                            value: customer!['address']['entrance'].toString()
                                                        ),

                                                        if (customer!['address']['floor'] != null)
                                                        InfoTile(
                                                            title: 'Этаж',
                                                            value: customer!['address']['floor'].toString()
                                                        ),

                                                        if (customer!['address']['apartment'] != null)
                                                        InfoTile(
                                                            title: 'Квартира',
                                                            value: customer!['address']['apartment'].toString()
                                                        ),

                                                        // if (customer!['geodata'] == null)
                                                        // const Text('Нет данных', style: TextStyle(color: AppColors.secondary)),
                                                        // const SizedBox(height: 5),
                                                        // const Row(
                                                        //     children: [
                                                        //         Icon(Icons.device_hub, color: AppColors.neo),
                                                        //         SizedBox(width: 8),
                                                        //         Text('Оборудование', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))
                                                        //     ]
                                                        // ),
                                                        // const Divider(),
                                                        // if (customer!['items'].isEmpty)
                                                        // const Center(
                                                        //     child: Text('У абонента нет оборудования', style: TextStyle(color: AppColors.secondary))
                                                        // ),
                                                        // if (customer!['items'].isNotEmpty)
                                                        // const Row(
                                                        //     children: [
                                                        //         Expanded(
                                                        //             flex: 7,
                                                        //             child: Text('Название', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold))
                                                        //         ),
                                                        //         Expanded(
                                                        //             flex: 6,
                                                        //             child: Text('SN', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))
                                                        //         ),
                                                        //         Expanded(
                                                        //             flex: 2,
                                                        //             child: Text('Кол-во', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))
                                                        //         )
                                                        //     ]
                                                        // ),
                                                        // if (customer!['items'].isNotEmpty)
                                                        // ListView.builder(
                                                        //     shrinkWrap: true,
                                                        //     physics: const NeverScrollableScrollPhysics(),
                                                        //     itemCount: customer!['items'].length,
                                                        //     itemBuilder: (c, i){
                                                        //         final equipment = customer!['items'][i];
                                                        //         return Padding(
                                                        //             padding: const EdgeInsets.only(bottom: 6),
                                                        //             child: Row(
                                                        //                 children: [
                                                        //                     Expanded(
                                                        //                         flex: 7,
                                                        //                         child: Text(equipment['name'] ?? '-', softWrap: true, textAlign: TextAlign.left)
                                                        //                     ),
                                                        //                     Expanded(
                                                        //                         flex: 6,
                                                        //                         child: equipment['sn'] == null?
                                                        //                             const Text('-', softWrap: true, textAlign: TextAlign.center)
                                                        //                             : MouseRegion(
                                                        //                                 cursor: SystemMouseCursors.click,
                                                        //                                 child: SelectionContainer.disabled(
                                                        //                                     child: GestureDetector(
                                                        //                                         behavior: HitTestBehavior.opaque,
                                                        //                                         onTap: _openONT,
                                                        //                                         child: Text(equipment['sn'], softWrap: true, textAlign: TextAlign.center,
                                                        //                                             style: const TextStyle(color: AppColors.neo,
                                                        //                                             decorationColor: AppColors.neo,
                                                        //                                             decoration: TextDecoration.underline)
                                                        //                                         )
                                                        //                                     ),
                                                        //                                 ),
                                                        //                             )
                                                        //                     ),
                                                        //                     Expanded(
                                                        //                         flex: 2,
                                                        //                         child: Text(equipment['amount']?.toString() ?? '0', softWrap: true, textAlign: TextAlign.right)
                                                        //                     )
                                                        //                 ]
                                                        //             )
                                                        //         );
                                                        //     }
                                                        // )
                                                    ]
                                                )
                                            ),
                                            Expanded(
                                                child: Column(
                                                    children: [
                                                        BuildingCard(
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
                                                                                                child: Text(formatDate(task['created_at']), softWrap: true, textAlign: TextAlign.center,
                                                                                                    style: TextStyle(color: _getTaskDateColor(task['created_at'], task['status']['id']), fontSize: 13) //
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
                                                                    )
                                                                ]
                                                            )
                                                        ),
                                                        BuildingCard(
                                                            lineColor: AppColors.main,
                                                            icon: Icons.device_hub,
                                                            title: 'Оборудование',
                                                            flex: 2,
                                                            last: true,
                                                            miniButtons: [
                                                                Tooltip(
                                                                    message: 'Обновить данные',
                                                                    child: IconButton(
                                                                        onPressed: items != null? _loadItemsData : null,
                                                                        icon: Icon(Icons.refresh, size: 18, color: items == null? AppColors.secondary : AppColors.neo),
                                                                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36)
                                                                    )
                                                                )
                                                            ],
                                                            child: items == null? const Center(child: AngularProgressBar()) :
                                                            Column(
                                                                children: [
                                                                    if (items!.isEmpty)
                                                                    const Center(
                                                                        child: Text('У абонента нет оборудования', style: TextStyle(color: AppColors.secondary))
                                                                    ),
                                                                    if (items!.isNotEmpty)
                                                                    const Row(
                                                                        children: [
                                                                            Expanded(
                                                                                flex: 4,
                                                                                child: Text('Название', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold))
                                                                            ),
                                                                            Expanded(
                                                                                flex: 4,
                                                                                child: Text('Тип', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))
                                                                            ),
                                                                            Expanded(
                                                                                flex: 5,
                                                                                child: Text('SN', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))
                                                                            ),
                                                                            Expanded(
                                                                                flex: 2,
                                                                                child: Text('Количество', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))
                                                                            )
                                                                        ]
                                                                    ),
                                                                    if (items!.isNotEmpty)
                                                                    Expanded(
                                                                        child: ListView.builder(
                                                                            itemCount: items!.length,
                                                                            itemBuilder: (c, i){
                                                                                final item = items![i];
                                                                                return Padding(
                                                                                    padding: const EdgeInsets.only(bottom: 6),
                                                                                    child: Row(
                                                                                        children: [
                                                                                            Expanded(
                                                                                                flex: 4,
                                                                                                child: Text(item['category']['name'] ?? '-', softWrap: true, textAlign: TextAlign.left)
                                                                                            ),
                                                                                            Expanded(
                                                                                                flex: 4,
                                                                                                child: Text({'cable': 'Кабель', 'olt': 'OLT', 'edfa': 'EDFA', 'ont': 'ONT', 'clamp': 'Зажим', 'commutator': 'Коммутатор', 'coupling': 'Муфта', 'odf': 'ODF', 'patchcord': 'Патчкорд', 'other': 'Прочее', 'junction': 'Распред. коробка', 'router': 'Роутер', 'splitter': 'Разделитель', 'smart_home': 'Умный дом', 'cisco': 'Cisco', 'cambium': 'Cambium'}[item['category']['type']] ?? '-', softWrap: true, textAlign: TextAlign.center)
                                                                                            ),
                                                                                            Expanded(
                                                                                                flex: 5,
                                                                                                child: item['sn'] == null?
                                                                                                    const Text('-', softWrap: true, textAlign: TextAlign.center)
                                                                                                    : InkWell(
                                                                                                    onTap: _openONT,
                                                                                                    child: Text(item['sn'], softWrap: true, textAlign: TextAlign.center,
                                                                                                        style: const TextStyle(color: AppColors.neo,
                                                                                                        decorationColor: AppColors.neo,
                                                                                                        decoration: TextDecoration.underline)
                                                                                                    )
                                                                                                )
                                                                                            ),
                                                                                            Expanded(
                                                                                                flex: 2,
                                                                                                child: Text('${item['amount']} ${item['category']['unit']}', softWrap: true, textAlign: TextAlign.right)
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
                                                        // const BuildingCard(
                                                        //     lineColor: AppColors.neo,
                                                        //     title: '',
                                                        //     last: true,
                                                        //     child: Center(child: Text('coming soon', style: TextStyle(color: AppColors.secondary, fontSize: 12)))
                                                        // )
                                                    ]
                                                )
                                            )
                                            // Expanded(
                                            //     child: Row(
                                            //         children: [
                                            //             BuildingCard(
                                            //                 lineColor: AppColors.main,
                                            //                 icon: Icons.menu,
                                            //                 title: 'Меню действий',
                                            //                 last: !showBuilding,
                                            //                 child: Align(
                                            //                     alignment: Alignment.topCenter,
                                            //                     child: Column(
                                            //                         spacing: 5,
                                            //                         mainAxisSize: MainAxisSize.min,
                                            //                         children: [
                                            //                             SizedBox(
                                            //                                 width: 270,
                                            //                                 child: ElevatedButton.icon(
                                            //                                     onPressed: _openAttachs,
                                            //                                     icon: const Icon(Icons.attach_file),
                                            //                                     label: const Text('Открыть вложения')
                                            //                                 )
                                            //                             ),
                                            //                             SizedBox(
                                            //                                 width: 270,
                                            //                                 child: ElevatedButton.icon(
                                            //                                     onPressed: !showBuilding ? _loadBuildingData : null,
                                            //                                     icon: const Icon(Icons.group),
                                            //                                     label: Text(!showBuilding ? 'Загрузить соседей' : 'Соседи загружены')
                                            //                                 )
                                            //                             ),
                                            //                             SizedBox(
                                            //                                 width: 270,
                                            //                                 child: ElevatedButton.icon(
                                            //                                     onPressed: _openNewTask,
                                            //                                     icon: const Icon(Icons.assignment_add),
                                            //                                     label: const Text('Создать задание')
                                            //                                 )
                                            //                             ),
                                            //                             SizedBox(
                                            //                                 width: 270,
                                            //                                 child: ElevatedButton.icon(
                                            //                                     onPressed: _openONT,
                                            //                                     icon: const Icon(Icons.router_outlined),
                                            //                                     label: const Text('Загрузить данные по модему')
                                            //                                 )
                                            //                             ),
                                            //                             SizedBox(
                                            //                                 width: 270,
                                            //                                 child: ElevatedButton.icon(
                                            //                                     onPressed: () => _openObjectInUS(customer!['id']),
                                            //                                     icon: const Icon(Icons.open_in_browser),
                                            //                                     label: const Text('Открыть абонента в UserSide')
                                            //                                 )
                                            //                             ),
                                            //                             SizedBox(
                                            //                                 width: 270,
                                            //                                 child: ElevatedButton.icon(
                                            //                                     onPressed: () => _copyObjectUSLink(customer!['id']),
                                            //                                     icon: const Icon(Icons.copy),
                                            //                                     label: const Text('Скопировать ссылку')
                                            //                                 )
                                            //                             )
                                            //                         ]
                                            //                     )
                                            //                 )
                                            //             ),
                                            //         ]
                                            //     )
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
