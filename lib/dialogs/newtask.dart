import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartlink/api.dart';
import 'package:smartlink/main.dart';

class NewTaskDialog extends StatefulWidget{
  const NewTaskDialog({required this.customerId, required this.addressId, required this.phones, this.box = false, super.key});
  final int customerId;
  final int? addressId;
  final List phones;
  final bool box;

  @override
  State<NewTaskDialog> createState() => _NewTaskDialogState();
}

class _NewTaskDialogState extends State<NewTaskDialog> {
  bool load = true;
  bool creating = false;

  // Тип задания
  int type = 37;
  int boxType = 38;

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
  late String appealType;
  List<String> appealTypes = [];

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
      appealTypes = List<String>.from(result['28']);
      appealType = appealTypes.first;
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
        final int id = await createTask(isBox? boxType : type, isBox? null : widget.customerId, employee, reason, isBox? widget.addressId : null, commentController.text,
          List<int>.from(divisions.where((e) => e['checked'] ?? false).map((e) => e['id']).toList()),
          phoneMask.unmaskText(phoneController.text), appealType);
        l.i('task created successfully, id: $id');
        if (context.mounted){
          Navigator.pop(context, {
            'box': isBox,
            'type': {
              'id': isBox? boxType : type,
              'name': isBox? boxType == 38?
                'Магистраль выезд на ремонт' : boxType == 48?
                'Магистраль-демонтаж/монтаж' : '-' : type == 37?
                'Выезд на ремонт' : type == 60?
                'Демонтаж оборудование' : type == 46?
                'Выезд к неактивным абонентам' : type == 53?
                'Выезд на ремонт (Равшан)' : '-'
            },
            'timestamps': {
              'created_at': DateTime.now().toString().substring(0, 19),
              'updated_at': DateTime.now().toString().substring(0, 19),
              'planned_at': DateTime.now().toString().substring(0, 19)
            },
            'status': {'id': 11, 'name': 'Не выполнено', 'system_id': 4},
            'id': id,
            'new': true
          });
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
          child: SelectionArea(
            child: Column(
              children: [
                TabBar(
                  tabs: [
                    const Tab(text: 'Ремонт', icon: Icon(Icons.home_repair_service)),
                    IgnorePointer(
                      ignoring: widget.addressId == null,
                      child: Opacity(
                        opacity: widget.addressId == null ? 0.3 : 1.0,
                        child: const Tab(
                          text: 'Магистральный ремонт',
                          icon: Icon(Icons.cable),
                        ),
                      ),
                    )
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
                              child: Text('Тип задания', style: TextStyle(fontWeight: FontWeight.bold))
                            ),
                            SizedBox(
                              height: 40, //
                              child: DropdownButtonFormField(
                                style: const TextStyle(fontSize: 13, fontFamily: 'Jost', color: AppColors.main, fontWeight: FontWeight.bold), //
                                value: type,
                                items: const [
                                  DropdownMenuItem(value: 37, child: Text('Выезд на ремонт', style: TextStyle(color: Color(0xFF999100)))),
                                  DropdownMenuItem(value: 60, child: Text('Демонтаж оборудование', style: TextStyle(color: Color(0xFF60686B)))),
                                  DropdownMenuItem(value: 46, child: Text('Выезд к неактивным абонентам', style: TextStyle(color: Color(0xFF523a6a)))),
                                  // DropdownMenuItem(value: 53, enabled: false,
                                  //   child: Text('Выезд на ремонт (Равшан)', style: TextStyle(color: Color(0xFF7c2f04), fontStyle: FontStyle.italic))
                                  // )
                                ],
                                onChanged: (v){
                                  setState(() {
                                    type = v!;
                                  });
                                }
                              ),
                            ),
                            const Align(
                              alignment: Alignment.topLeft,
                              child: Text('Номер телефона обратившегося', style: TextStyle(fontWeight: FontWeight.bold))
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
                            if (type != 60) ...[
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
                                )
                              ),
                              const Align(
                                alignment: Alignment.topLeft,
                                child: Text('Тип обращения', style: TextStyle(fontWeight: FontWeight.bold))
                              ),
                              SizedBox(
                                height: 40, //
                                child: DropdownButtonFormField(
                                  value: appealType,
                                  style: const TextStyle(fontSize: 13, fontFamily: 'Jost', color: AppColors.main), //
                                  items: appealTypes.map((e) {
                                    return DropdownMenuItem(value: e, child: Text(e));
                                  }).toList(),
                                  onChanged: (v){
                                    setState(() {
                                      appealType = v!;
                                    });
                                  }
                                )
                              )
                            ],
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
                              // height: 250,
                              width: 580,
                              child: ListView.builder(
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
                                      Expanded(
                                        child: MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                division['checked'] = !division['checked'];
                                              });
                                            },
                                            child: Text(division['name']),
                                          ),
                                        ),
                                      )
                                    ]
                                  );
                                }
                              ),
                            )
                          ]
                        ),
                      ),
                      if (widget.addressId == null)
                      const Column(
                        children: [
                          SizedBox(height: 5),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 5,
                            children: [
                              Icon(Icons.warning_amber_outlined, color: AppColors.error),
                              Text('Коробка не найдена', style: TextStyle(color: AppColors.error))
                            ]
                          ),
                          Text('Если коробка существует, дождитесь загрузки данных и переоткройте диалог', style: TextStyle(color: AppColors.secondary)
                          )
                        ],
                      )
                      else
                      SingleChildScrollView(
                        child: Column(
                          spacing: 5,
                          children: [
                            const SizedBox(height: 5),
                            const Align(
                              alignment: Alignment.topLeft,
                              child: Text('Тип задания', style: TextStyle(fontWeight: FontWeight.bold))
                            ),
                            SizedBox(
                              height: 40, //
                              child: DropdownButtonFormField(
                                style: const TextStyle(fontSize: 13, fontFamily: 'Jost', color: AppColors.main, fontWeight: FontWeight.bold), //
                                value: boxType,
                                items: const [
                                  DropdownMenuItem(value: 38, child: Text('Магистраль выезд на ремонт', style: TextStyle(color: Color(0xFF860d1c)))),
                                  DropdownMenuItem(value: 48, child: Text('Магистраль-демонтаж/монтаж', style: TextStyle(color: Color(0xFF3a538a))))
                                ],
                                onChanged: (v){
                                  setState(() {
                                    boxType = v!;
                                  });
                                }
                              ),
                            ),
                            if (boxType != 38) ...[
                              const Align(
                                alignment: Alignment.topLeft,
                                child: Text('Номер телефона обратившегося', style: TextStyle(fontWeight: FontWeight.bold))
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
                              )
                            ],
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
                            if (boxType != 48) ...[
                              const Align(
                                alignment: Alignment.topLeft,
                                child: Text('Тип обращения', style: TextStyle(fontWeight: FontWeight.bold))
                              ),
                              SizedBox(
                                height: 40, //
                                child: DropdownButtonFormField(
                                  style: const TextStyle(fontSize: 13, color: AppColors.main, fontFamily: 'Jost'), //
                                  value: appealType,
                                  items: appealTypes.map((e) {
                                    return DropdownMenuItem(value: e, child: Text(e));
                                  }).toList(),
                                  onChanged: (v){
                                    setState(() {
                                      appealType = v!;
                                    });
                                  }
                                )
                              ),
                            ],
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
          ),
        ) : const Center(child: AngularProgressBar()),
        actions: [
          Builder(
            builder: (actionsContext) {
              return AnimatedBuilder(
                animation: DefaultTabController.of(actionsContext),
                builder: (context, child) {
                  final isBox = DefaultTabController.of(actionsContext).index == 1;
                  bool disabled = false;

                  if (isBox && widget.addressId == null) {
                    disabled = true;
                  }
                  else if (phoneController.text.isEmpty) {
                    if (!isBox) {
                      disabled = true;
                    } else if (boxType != 38) {
                      disabled = true;
                    }
                  }
                  return ElevatedButton(
                    onPressed: disabled? null : () => _createTask(context),
                    child: creating? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator()) : const Text('Создать')
                  );
                }
              );
            }
          )
        ],
      ),
    );
  }
}
