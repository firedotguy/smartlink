import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartlink/api.dart';
import 'package:smartlink/dialogs/new_task.dart';
import 'package:smartlink/dialogs/ont.dart';
import 'package:smartlink/dialogs/task.dart';
import 'package:smartlink/dialogs/tasks.dart';
import 'package:smartlink/i18n.dart';
import 'package:smartlink/pages/home/building_card.dart';
import 'package:smartlink/pages/home/customer_card.dart';
import 'package:smartlink/pages/home/items_card.dart';
import 'package:smartlink/pages/home/search_results.dart';
import 'package:smartlink/pages/home/tasks_card.dart';
import 'package:smartlink/theme.dart';
import 'package:smartlink/utils.dart';

class HomePage extends StatefulWidget {
    const HomePage({super.key, this.customer_id});
    final int? customer_id;

    @override
    State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
    // TODO: refactor loading (make Enum class)
    bool load = false;

    // поиск
    bool search = true;
    bool searching = false;
    bool customer_not_found = false;
    List<Map> customers = [];
    final TextEditingController search_controller = TextEditingController();
    Timer? _debounce_timer;
    int search_version = 0;
    int debounce = 300;

    // данные
    int? employee_id;
    Map? customer;
    Map? building;
    bool no_building = false;
    List<Map>? tasks;
    List<Map<String, dynamic>>? items;

    @override
    void initState() {
        super.initState();
        if (widget.customer_id != null) _load_customer(widget.customer_id!);
        _get_settings();
    }

    @override
    void dispose() {
        _debounce_timer?.cancel();
        search_controller.dispose();
        super.dispose();
    }


    // загрузка данных
    Future<void> _get_settings() async {
        l.i('get settings data');
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        debounce = prefs.getInt('debounce') ?? 300;

        employee_id = prefs.getInt('userId');
        if (employee_id == null){
            l.w('user id not found');
            if (mounted) show_error(context, t.home.user_id_missing);
        }
        setState(() {});
    }

    Future<void> _load_building() async {
        try {
            l.i('load building data');
            setState(() {
                building = null;
                no_building = false;
            });

            if (customer?['address']?['id'] == null){
                l.w('no building');
                setState(() {
                    no_building = true;
                });
                return;
            }

            building = await get_building(customer!['address']['id']);
            if (building!['detail'] != null){
                l.w('building not found');
                setState(() {
                    no_building = true;
                });
            }

            setState(() {
                load = false;
            });
        } catch (e) {
            l.e('error loading building data: $e');
            if (mounted) show_error(context, t.home.building_error('$e'), replace: true);
        }
    }

    Future<void> _load_tasks({int? customer_id}) async {
        try {
            l.i('load tasks');
            setState(() {
                tasks = null;
            });
            tasks = await get_customer_tasks(customer_id ?? customer!['id']);
            setState(() {});
        } catch (e) {
            l.e('error loading tasks: $e');
            if (mounted) show_error(context, t.home.tasks_error('$e'), replace: true);
        }
    }

    Future<void> _load_items({int? customer_id}) async {
        try {
            l.i('load items');
            setState(() {
                items = null;
            });
            items = await get_customer_items(customer_id ?? customer!['id']);
            setState(() {});
        } catch (e) {
            l.e('error loading items: $e');
            if (mounted) show_error(context, t.home.items_error('$e'), replace: true);
        }
    }

    void _load_customer(int id, {bool load_all = true}) {
        if (load) {
            l.i('load customer request ignored because load = true');
            return;
        }

        try {
            l.i('load customer $id');
            search_controller.clear();
            setState(() {
                load = true;
                customer = null;
                if (load_all){
                    no_building = false;
                    items = null;
                    building = null;
                    tasks = null;
                }
                search = false;
                searching = false;
                customers.clear();
            });

            get_customer(id).then((value){
                customer = value;
                setState(() {
                    load = false;
                });
                _load_building();
            });

            if (load_all){
                _load_tasks(customer_id: id);
                _load_items(customer_id: id);
            }
        } catch (e) {
            l.e('error getting customer data: $e');
            if (mounted) show_error(context, t.home.customer_error('$e'), replace: true);
        }
    }


    // поиск

    void _on_search_submit(String value) {
        l.i('search submitted - value: $value');
        if (searching) return;

        if (customers.isEmpty) {
            show_warning(context, t.home.customer_not_selected, replace: true);
            return;
        }
        _load_customer(customers.first['id']);
    }

    void _on_search_change(String value) {
        l.i('search changed - value: $value');
        _debounce_timer?.cancel();

        if (value.trim().isEmpty) {
            setState(() {
                customers.clear();
                customer_not_found = false;
                search = true;
                searching = false;
                load = false;
            });
            return;
        }

        final int version = ++search_version;
        _debounce_timer = Timer(Duration(milliseconds: debounce), () async {
            setState(() {
                searching = true;
                customer_not_found = false;
                search = true;
                load = false;
            });

            try {
                final List<Map> found = await search_customers(value);
                if (version != search_version) {
                    l.w('ignored outdated search response');
                    return;
                }

                setState(() {
                    customers = found;
                    customer_not_found = found.isEmpty;
                    searching = false;
                });
                l.i('found ${found.length} customers');
            } catch (e) {
                if (version != search_version) return;
                l.e('error getting customers: $e');
                setState(() {
                    customer_not_found = true;
                    searching = false;
                });
                if (mounted) show_error(context, t.home.customers_error, replace: true);
            }
        });
    }


    // действия

    void _open_ont() {
        if (customer == null) {
            show_warning(context, t.home.wait_customer);
            return;
        }
        if (customer!['sn'] == null){
            show_warning(context, t.home.no_sn);
            return;
        }
        if (customer!['olt_id'] == null){
            show_error(context, t.home.no_olt);
            return;
        }

        showDialog(context: context, builder: (context) {
            return OntDialog(
                olt_id: customer!['olt_id'],
                sn: customer!['sn'],
                agreement: customer!['agreement']['number'],
                customer_id: customer!['id'],
                is_customer_active: customer!['status'] == 'active'
            );
        });
    }

    void _open_new_task({bool building_task = false}) async {
        if (customer == null){
            show_warning(context, t.home.customer_not_loaded);
            return;
        }

        l.i('show newtask dialog');
        final Map? result = await showDialog(context: context, builder: (context) {
            return NewTaskDialog(
                customer_id: customer!['id'],
                address_id: building?['building_id'],
                phones: customer!['phones'],
                building: building_task
            );
        });
        if (result == null) return;
        if (result['reopen_with_building'] == true) {
            if (building?['building_id'] == null) {
                l.w('unable to reopen with building (still not loaded)');
                if (!mounted) return;
                show_warning(context, t.newTask.no_building_hint);
                return;
            }
            l.i('reopen with building');
            _open_new_task(building_task: true);
            return;
        }

        if (result['building'] != true){
            tasks?.add(result);
        } else {
            building?['tasks']?.add(result['id']);
        }
        setState(() {});
    }

    void _open_task({Map? data, int? id}){
        showDialog(
            context: context,
            builder: (context) => TaskDialog(
                task: data?['new'] == true? null : (data == null? null : Map<String, dynamic>.from(data)),
                id: id ?? data?['id']
            )
        );
    }

    void _open_tasks(List<int> ids){
        showDialog(context: context, builder: (context) => TasksDialog(tasks: ids));
    }


    // интерфейс

    Widget _search_field() {
        return Row(
            children: [
                const Expanded(child: SizedBox()), // выравнивание по центральной карточке
                Expanded(
                    child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: TextField(
                            decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.search, color: AppColors.secondary),
                                hintText: t.home.search_hint,
                                errorText: customer_not_found? ' ' : null,
                                helperText: customer_not_found? ' ' : null
                            ),
                            controller: search_controller,
                            onSubmitted: _on_search_submit,
                            onChanged: _on_search_change
                        )
                    )
                ),
                const Expanded(child: SizedBox())
            ]
        );
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
            body: SafeArea(
                child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                        child: Column(
                            children: [
                                _search_field(),
                                const SizedBox(height: 10),

                                if (search)
                                SizedBox(
                                    width: 450,
                                    height: 250,
                                    child: SearchResults(
                                        customers: customers,
                                        searching: searching,
                                        on_select: _load_customer
                                    )
                                ),
                                const SizedBox(height: 10),

                                if (!search)
                                Expanded(
                                    child: Row(
                                        children: [
                                            BuildingCard(
                                                building: building,
                                                not_found: no_building,
                                                on_refresh: _load_building,
                                                on_new_task: () => _open_new_task(building_task: true),
                                                on_open_tasks: (ids) {
                                                    if (ids.length == 1) {
                                                        _open_task(id: ids.first);
                                                    } else {
                                                        _open_tasks(ids);
                                                    }
                                                }
                                            ),
                                            CustomerCard(
                                                customer: customer,
                                                building: building,
                                                on_refresh: () => _load_customer(customer!['id'], load_all: false),
                                                on_open_ont: _open_ont,
                                                on_new_task: _open_new_task
                                            ),
                                            Expanded(
                                                child: Column(
                                                    children: [
                                                        TasksCard(
                                                            tasks: tasks,
                                                            on_refresh: _load_tasks,
                                                            on_open_task: (task) => _open_task(data: task)
                                                        ),
                                                        ItemsCard(
                                                            items: items,
                                                            on_refresh: _load_items,
                                                            on_open_ont: _open_ont
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
