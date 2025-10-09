import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartlink/api.dart';
import 'package:smartlink/main.dart';

class NewTaskDialog extends StatefulWidget{
  const NewTaskDialog({required this.customerId, required this.boxId, required this.phones, this.box = false, super.key});
  final int customerId;
  final int boxId;
  final List phones;
  final bool box;

  @override
  State<NewTaskDialog> createState() => _NewTaskDialogState();
}

class _NewTaskDialogState extends State<NewTaskDialog> {
  bool load = true;
  bool creating = false;

  // Номер обратившегося
  TextEditingController phoneController = TextEditingController();
  MaskTextInputFormatter phoneMask = MaskTextInputFormatter(
    mask: '+996 (###) ###-###',
    filter: {"#": RegExp(r'[0-9]')}
  );

  // Причина обращения
  late String reason;
  List<String> reasons = [];

  // Тип обращения (ремонт)
  late String type;
  List<String> types = [];

  // Тип обращения (магистральный ремонт)
  late String boxReason;
  List<String> boxReasons = [];

  // Описание
  TextEditingController commentController = TextEditingController();

  // Исполнители
  List<Map> divisions = [];
  bool showDivisions = false;

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
        l.e('error while loading addata/divisions: $e');
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Ошибка загрузки данных', style: TextStyle(color: AppColors.error))
        ));
      }
    }
  }

  void _createTask(context) async {
    setState(() {
      creating = true;
    });
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
          List<int>.from(divisions.where((e) => e['checked'] ?? false).map((e) => e['id']).toList()), phoneMask.unmaskText(phoneController.text), type);
        l.i('task created successfully, id: $id');
        if (context.mounted){
          Navigator.pop(context, {'box': isBox, 'id': id});
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
      initialIndex: widget.box? 1 : 0,
      length: 2,
      child: AlertDialog(
        title: const Text('Создать задание'),
        content: !load? SizedBox(
          width: 600,
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
                          const SizedBox(height: 5),
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Text('Номер обратившегося', style: TextStyle(fontWeight: FontWeight.bold))
                          ),
                          SizedBox(
                            height: 40, //
                            child: TextField(
                              style: const TextStyle(fontSize: 13), //
                              decoration: const InputDecoration(
                                hintText: 'Введите номер телефона'
                              ),
                              controller: phoneController,
                              inputFormatters: [phoneMask],
                              onChanged: (v){
                                l.i('phone value changed to $v');
                                setState(() {});
                              }
                            ),
                          ),
                          if (widget.phones.isNotEmpty)
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Text('или выберите из следующих', style: TextStyle(color: AppColors.secondary))
                          ),
                          if (widget.phones.isNotEmpty)
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
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Text('Причина обращения', style: TextStyle(fontWeight: FontWeight.bold))
                          ),
                          SizedBox(
                            height: 40, //
                            child: DropdownButtonFormField(
                              style: const TextStyle(fontSize: 13, fontFamily: 'Jost', color: AppColors.main), //
                              value: reason,
                              items: reasons.map((e) {
                                return DropdownMenuItem(value: e, child: Text(e));
                              }).toList(),
                              onChanged: (v){
                                setState(() {
                                  reason = v!;
                                });
                              }
                            ),
                          ),
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Text('Тип обращения', style: TextStyle(fontWeight: FontWeight.bold))
                          ),
                          SizedBox(
                            height: 40, //
                            child: DropdownButtonFormField(
                              value: type,
                              style: const TextStyle(fontSize: 13, fontFamily: 'Jost', color: AppColors.main), //
                              items: types.map((e) {
                                return DropdownMenuItem(value: e, child: Text(e));
                              }).toList(),
                              onChanged: (v){
                                setState(() {
                                  type = v!;
                                });
                              }
                            ),
                          ),
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Text('Описание', style: TextStyle(fontWeight: FontWeight.bold))
                          ),
                          TextField(
                            controller: commentController,
                            maxLines: 3,
                            style: const TextStyle(fontSize: 13), //
                            decoration: const InputDecoration(
                              hintText: 'Введите описание (необязательно)'
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Исполнители', style: TextStyle(fontWeight: FontWeight.bold)),
                              IconButton(
                                onPressed: (){
                                  setState(() {
                                    showDivisions = !showDivisions;
                                  });
                                },
                                icon: Icon(showDivisions? Icons.arrow_drop_down_sharp : Icons.arrow_drop_up_sharp, color: AppColors.secondary)
                              )
                            ],
                          ),
                          if (showDivisions)
                          SizedBox(
                            height: 250,
                            width: 580,
                            child: ListView.builder(
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
                            ),
                          )
                        ]
                      ),
                    ),
                    SingleChildScrollView(
                      child: Column(
                        spacing: 5,
                        children: [
                          const SizedBox(height: 5),
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Text('Обращение с номера', style: TextStyle(fontWeight: FontWeight.bold))
                          ),
                          SizedBox(
                            height: 40, //
                            child: TextField(
                              style: const TextStyle(fontSize: 13), //
                              decoration: const InputDecoration(
                                hintText: 'Введите номер телефона'
                              ),
                              controller: phoneController,
                              inputFormatters: [phoneMask],
                              onChanged: (v){
                                l.i('phone value changed to $v');
                                setState(() {});
                              }
                            ),
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
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Text('Причина обращения', style: TextStyle(fontWeight: FontWeight.bold))
                          ),
                          SizedBox(
                            height: 40, //
                            child: DropdownButtonFormField(
                              style: const TextStyle(fontSize: 13, color: AppColors.main, fontFamily: 'Jost'), //
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
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Text('Тип обращения', style: TextStyle(fontWeight: FontWeight.bold))
                          ),
                          SizedBox(
                            height: 40, //
                            child: DropdownButtonFormField(
                              style: const TextStyle(fontSize: 13, color: AppColors.main, fontFamily: 'Jost'), //
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
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Text('Описание', style: TextStyle(fontWeight: FontWeight.bold))
                          ),
                          TextField(
                            controller: commentController,
                            maxLines: 3,
                            style: const TextStyle(fontSize: 13), //
                            decoration: const InputDecoration(
                              hintText: 'Введите описание (необязательно)'
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Исполнители', style: TextStyle(fontWeight: FontWeight.bold)),
                              IconButton(
                                onPressed: (){
                                  setState(() {
                                    showDivisions = !showDivisions;
                                  });
                                },
                                icon: Icon(showDivisions? Icons.arrow_drop_down_sharp : Icons.arrow_drop_up_sharp, color: AppColors.secondary)
                              )
                            ],
                          ),
                          if (showDivisions)
                          SizedBox(
                            height: 250,
                            width: 580,
                            child: ListView.builder(
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
                            ),
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
                child: creating? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator()) : const Text('Создать')
              );
            }
          )
        ],
      ),
    );
  }
}
