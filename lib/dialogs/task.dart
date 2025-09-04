import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartlink/api.dart';
import 'package:smartlink/main.dart';

class TaskDialog extends StatefulWidget{
  const TaskDialog({required this.customerId, required this.boxId, required this.phones, super.key});
  final int customerId;
  final int boxId;
  final List phones;

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  TextEditingController phoneController = TextEditingController();
  MaskTextInputFormatter phoneMask = MaskTextInputFormatter(
    mask: '+996 (###) ###-###',
    filter: {"#": RegExp(r'[0-9]')}
  );
  late String reason;
  List<String> reasons = [];
  late String type;
  List<String> types = [];
  late String boxReason;
  List<String> boxReasons = [];
  List<Map> divisions = [];
  TextEditingController commentController = TextEditingController();
  bool load = true;

  void _getReasons() async {
    try {
      final result = await getAdditionalData();
      reasons = List<String>.from(result['30']);
      reason = reasons.first;
      boxReasons = List<String>.from(result['33']);
      boxReason = boxReasons.first;
      types = List<String>.from(result['28']);
      type = types.first;
      divisions = List<Map>.from(await getDivisions());

      setState(() {
        load = false;
      });
    } catch (e) {
      if (mounted) {
        l.e('error while loading additional_data/divisions: $e');
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Ошибка загрузки данных', style: TextStyle(color: AppColors.error))
        ));
      }
    }
  }

  void _createTask(context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? employee = prefs.getInt('userId');
    if (employee == null){
      l.e('error while creating task: no employeeId');
      if (context.mounted){
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Ошибка при создании задания: ID автора не найден. Пожалуйста, авторизуйтесь', style: TextStyle(color: AppColors.error))
        ));
      }
    } else {
      try{
        final bool isBox = context.mounted? DefaultTabController.of(context).index == 1 : false;
        final int id = await createTask(widget.customerId, employee, reason, isBox, widget.boxId, commentController.text,
          List<int>.from(divisions.where((e) => e['checked']).map((e) => e['id']).toList()), phoneMask.unmaskText(phoneController.text), type);
        l.i('task created successfully, id: $id');
        if (context.mounted){
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Задание создано', style: TextStyle(color: AppColors.success))
          ));
        }
      } catch (e){
        l.e('error while creating task: $e');
        if (context.mounted){
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Ошибка при создании задания', style: TextStyle(color: AppColors.error))
          ));
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getReasons();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: AlertDialog(
        title: const Text('Создать задание'),
        content: !load? SizedBox(
          width: 500,
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(text: 'Ремонт', icon: Icon(Icons.home_repair_service)),
                  Tab(text: 'Магистральный ремонт', icon: Icon(Icons.cable))
                ]
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        spacing: 5,
                        children: [
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Text('Обращение с номера', style: TextStyle(fontWeight: FontWeight.bold))
                          ),
                          SizedBox(
                            height: 40, //shit
                            child: TextField(
                              style: const TextStyle(fontSize: 13), //shit
                              decoration: const InputDecoration(
                                hintText: 'Введите номер телефона'
                              ),
                              controller: phoneController,
                              inputFormatters: [phoneMask],
                              onChanged: (v){
                                l.i('phone value changed to $v');
                                setState(() {});
                              }
                            )
                          ),
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Text('или выберите из следующих', style: TextStyle(color: AppColors.secondary))
                          ),
                          Row(
                            spacing: 5,
                            children: widget.phones.map((e){
                              final String phone = phoneMask.maskText(e);
                              return ChoiceChip(
                                label: Text(phone),
                                selected: phone == phoneController.text,
                                onSelected: (v){
                                  l.i('select phone $e using ChoiceChip');
                                  setState(() {
                                    phoneController.text = phone;
                                  });
                                }
                              );
                            }).toList()
                          ),
                          const SizedBox(height: 5),
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Text('Причина обращения', style: TextStyle(fontWeight: FontWeight.bold))
                          ),
                          SizedBox(
                            height: 40, //shit
                            child: DropdownButtonFormField(
                              style: const TextStyle(fontSize: 13, color: AppColors.main, fontFamily: 'Jost'), //shit
                              value: reason,
                              items: reasons.map((e) {
                                return DropdownMenuItem(value: e, child: Text(e));
                              }).toList(),
                              onChanged: (v){
                                setState(() {
                                  reason = v!;
                                });
                              }
                            )
                          ),
                          const SizedBox(height: 5),
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Text('Тип обращения', style: TextStyle(fontWeight: FontWeight.bold))
                          ),
                          SizedBox(
                            height: 40, //shit
                            child: DropdownButtonFormField(
                              style: const TextStyle(fontSize: 13, color: AppColors.main, fontFamily: 'Jost'), //shit
                              value: type,
                              items: types.map((e) {
                                return DropdownMenuItem(value: e, child: Text(e));
                              }).toList(),
                              onChanged: (v){
                                setState(() {
                                  type = v!;
                                });
                              }
                            )
                          ),
                          const SizedBox(height: 5),
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Text('Описание', style: TextStyle(fontWeight: FontWeight.bold))
                          ),
                          TextField(
                            controller: commentController,
                            maxLines: 3,
                            style: const TextStyle(fontSize: 13), //shit
                            decoration: const InputDecoration(
                              hintText: 'Введите описание (необязательно)'
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Text('Исполнители', style: TextStyle(fontWeight: FontWeight.bold))
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: divisions.length,
                            itemBuilder: (c, i){
                              final division = divisions[i];
                              if (division['checked'] == null){
                                division['checked'] = false;
                                divisions[i]['checked'] = false;
                              }
                              return Row(
                                spacing: 5,
                                children: [
                                  Checkbox(
                                    value: division['checked'],
                                    onChanged: (v){
                                      setState(() {
                                        division['checked'] = v!;
                                      });
                                    },
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                  ),
                                  Expanded(child: Text(division['name']))
                                ]
                              );
                            }
                          )
                        ]
                      ),
                    ),
                    SingleChildScrollView(
                      child: Column(
                        spacing: 5,
                        children: [
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Text('Обращение с номера', style: TextStyle(fontWeight: FontWeight.bold))
                          ),
                          SizedBox(
                            height: 40, //shit
                            child: TextField(
                              style: const TextStyle(fontSize: 13), //shit
                              decoration: const InputDecoration(
                                hintText: 'Введите номер телефона'
                              ),
                              controller: phoneController,
                              inputFormatters: [phoneMask],
                              onChanged: (v){
                                l.i('phone value changed to $v');
                                setState(() {});
                              }
                            )
                          ),
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Text('или выберите из следующих', style: TextStyle(color: AppColors.secondary))
                          ),
                          Row(
                            spacing: 5,
                            children: widget.phones.map((e){
                              final String phone = phoneMask.maskText(e);
                              return ChoiceChip(
                                label: Text(phone),
                                selected: phone == phoneController.text,
                                onSelected: (v){
                                  l.i('select phone $e using ChoiceChip');
                                  setState(() {
                                    phoneController.text = phone;
                                  });
                                }
                              );
                            }).toList()
                          ),
                          const SizedBox(height: 5),
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Text('Причина обращения', style: TextStyle(fontWeight: FontWeight.bold))
                          ),
                          SizedBox(
                            height: 40, //shit
                            child: DropdownButtonFormField(
                              style: const TextStyle(fontSize: 13, color: AppColors.main, fontFamily: 'Jost'), //shit
                              value: boxReason,
                              items: boxReasons.map((e) {
                                return DropdownMenuItem(value: e, child: Text(e));
                              }).toList(),
                              onChanged: (v){
                                setState(() {
                                  boxReason = v!;
                                });
                              }
                            )
                          ),
                          const SizedBox(height: 5),
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Text('Тип обращения', style: TextStyle(fontWeight: FontWeight.bold))
                          ),
                          SizedBox(
                            height: 40, //shit
                            child: DropdownButtonFormField(
                              style: const TextStyle(fontSize: 13, color: AppColors.main, fontFamily: 'Jost'), //shit
                              value: type,
                              items: types.map((e) {
                                return DropdownMenuItem(value: e, child: Text(e));
                              }).toList(),
                              onChanged: (v){
                                setState(() {
                                  type = v!;
                                });
                              }
                            )
                          ),
                          const SizedBox(height: 5),
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Text('Описание', style: TextStyle(fontWeight: FontWeight.bold))
                          ),
                          TextField(
                            controller: commentController,
                            maxLines: 3,
                            style: const TextStyle(fontSize: 13), //shit
                            decoration: const InputDecoration(
                              hintText: 'Введите описание (необязательно)'
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Text('Исполнители', style: TextStyle(fontWeight: FontWeight.bold))
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: divisions.length,
                            itemBuilder: (c, i){
                              final division = divisions[i];
                              if (division['checked'] == null){
                                division['checked'] = false;
                                divisions[i]['checked'] = false;
                              }
                              return Row(
                                spacing: 5,
                                children: [
                                  Checkbox(
                                    value: division['checked'],
                                    onChanged: (v){
                                      setState(() {
                                        division['checked'] = v!;
                                      });
                                    },
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                  ),
                                  Expanded(child: Text(division['name']))
                                ]
                              );
                            }
                          )
                        ]
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ) : const Center(child: AngularProgressBar()),
        actions: [
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => _createTask(context),
                child: const Text('Создать')
              );
            }
          )
        ],
      ),
    );
  }
}
