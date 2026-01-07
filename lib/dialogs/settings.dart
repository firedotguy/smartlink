import 'package:flutter/material.dart' hide Chip;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartlink/main.dart';
import 'package:smartlink/pages/sign.dart';

/// A modal settings dialog that allows users to configure SmartLink Viewer behavior.
///
/// This dialog is typically shown when the user taps the "⚙️" button located
/// in the top-right corner of the app interface. It supports configuration options such as:
///
/// - Debounce delay for API calls
/// - Theme (dark/light/system - planned)
/// - Auto-load neighbors behavior
/// - Changelog
///
/// The dialog is implemented as a stateful widget to allow live updating of settings.
class SettingsDialog extends StatefulWidget{
  /// Creates a new instance of the settings dialog.
  ///
  /// All state is handled internally, and no parameters are required.
  const SettingsDialog({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog>{
  String theme = 'smartlink-dark';
  int debounce = 300;
  String loadNeighbours = 'onWrong';
  int neighbourLimit = 10;
  int taskLimit = 5;
  bool logined = false;

  TextEditingController debounceController = TextEditingController(text: '0');
  bool debounceError = false;
  bool changed = false;

  void _getSettings() async {
    l.i('get settings');
    final prefs = await SharedPreferences.getInstance();
    l.i('available keys: ${prefs.getKeys()}');
    // theme = prefs.getString('theme') ?? 'smartlink-dark';
    debounce = prefs.getInt('debounce') ?? 300;
    debounceController.text = debounce.toString();
    loadNeighbours = prefs.getString('loadNeighbours') ?? 'onWrong';
    neighbourLimit = prefs.getInt('neighbourLimit') ?? 10;
    if (neighbourLimit == 9999) neighbourLimit = 0;
    taskLimit = prefs.getInt('taskLimit') ?? 5;
    if (taskLimit == 9999) taskLimit = 0;
    logined = (prefs.getString('login') ?? '') != '';
    setState(() {});
  }

  // void _updateBool(String key, bool value) async {
  //   setState(() {
  //     changed = true;
  //   });
  //   l.i('update bool setting $key to $value');
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setBool(key, value);
  // }

  void _updateInt(String key, int value) async {
    setState(() {
      changed = true;
    });
    l.i('update int setting $key to $value');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  // void _updateString(String key, String value) async {
  //   setState(() {
  //     changed = true;
  //   });
  //   l.i('update string setting $key to $value');
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString(key, value);
  // }

  void _logOut() async {
    l.i('logging out');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('login', '');
  }

  @override
  void initState() {
    super.initState();
    _getSettings();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Настройки'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 600
        ),
        child: SelectionArea(
          child: Column(
            spacing: 10,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Text('Тема', style: TextStyle(color: AppColors.main)),
                      Chip(text: 'Отключено', color: AppColors.error)
                    ],
                  ),
                  IntrinsicWidth(
                    child: DropdownButtonFormField(
                      initialValue: theme,
                      items: const [
                        DropdownMenuItem(value: 'smartlink-dark', child: Text('SmartLink (dark)')),
                        DropdownMenuItem(value: 'smartlink-light', child: Text('SmartLink (light)', style: TextStyle(color: Color(0xFF121212), backgroundColor: Color(0xFFD1D5DC)))),
                        DropdownMenuItem(value: 'smartlink-dark-high', child: Text('SmartLink (dark) high-contrast', style: TextStyle(color: Colors.white, backgroundColor: Colors.black))),
                        DropdownMenuItem(value: 'smartlink-green', child: Text('SmartLink (green)', style: TextStyle(backgroundColor: Color(0xFF162515), color: Colors.white))),
                        DropdownMenuItem(value: 'smartlink-red', child: Text('SmartLink (red)', style: TextStyle(backgroundColor: Color(0xFF251515), color: Colors.white))),
                        DropdownMenuItem(value: 'userside', child: Text('UserSide', style: TextStyle(color: Colors.black, backgroundColor: Colors.white))),
                        DropdownMenuItem(value: 'ember-dark', child: Text('Ember', style: TextStyle(color: Color(0xFFFBEADB), backgroundColor: Color(0xFF1E1C1A)))),
                        DropdownMenuItem(value: 'dracula', child: Text('Dracula', style: TextStyle(color: Color(0xFFE3E2E9), backgroundColor: Color(0xFF0E0D11)))),
                        DropdownMenuItem(value: 'monokai', child: Text('Monokai', style: TextStyle(color: Color(0xFFFCFCFA), backgroundColor: Color(0xFF221F22))))
                      ],
                      onChanged: null //(v) {}
                    )
                  )
                ]
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Text('Загрузка соседей', style: TextStyle(color: AppColors.main)),
                      Chip(text: 'Отключено', color: AppColors.error)
                    ],
                  ),
                  IntrinsicWidth(
                    child: DropdownButtonFormField(
                      initialValue: loadNeighbours,
                      items: const [
                        DropdownMenuItem(value: 'never', child: Text('Никогда')),
                        DropdownMenuItem(value: 'onWrong', child: Text('При неполадках у абонента')),
                        DropdownMenuItem(value: 'always', child: Text('Всегда'))
                      ],
                      onChanged: null //(v) {
                      //   setState(() {
                      //     loadNeighbours = v!;
                      //   });
                      //   _updateString('loadNeighbours', v!);
                      // }
                    )
                  )
                ]
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text('Задержка при вводе', style: TextStyle(color: AppColors.main)),
                      Text('Время ожидания после поиска перед загрузкой абонентов', style: TextStyle(color: AppColors.secondary, fontSize: 12))
                    ]
                  ),
                  SizedBox(
                    width: 120,
                    child: TextField(
                      controller: debounceController,
                      decoration: InputDecoration(
                        hintText: 'мс',
                        errorText: debounceError? 'Неправильное значение' : null
                      ),
                      onChanged: (v){
                        if (int.tryParse(v) == null){
                          setState(() {
                            debounceError = true;
                          });
                        } else {
                          setState(() {
                            debounceError = false;
                            debounce = int.parse(v);
                          });
                          _updateInt('debounce', int.parse(v));
                        }
                      }
                    )
                  )
                ]
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text('Лимит на загрузку соседей', style: TextStyle(color: AppColors.main)),
                      Text('Макс. количество соседей для загрузки за раз', style: TextStyle(color: AppColors.secondary, fontSize: 12)),
                      Text('0 = нет лимита, загружать всех сразу (не рекомендуется)', style: TextStyle(color: AppColors.secondary, fontSize: 12)),
                    ]
                  ),
                  Row(
                    spacing: 16,
                    children: [
                      SizedBox(
                        width: 200,
                        child: Slider(
                          value: neighbourLimit.toDouble(),
                          onChanged: (value) {
                            neighbourLimit = value.toInt();
                            _updateInt('neighbourLimit', neighbourLimit == 0? 9999 : neighbourLimit);
                          },
                          min: 0,
                          max: 100
                        )
                      ),
                      Text(neighbourLimit.toString())
                    ]
                  )
                ]
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text('Лимит на загрузку заданий', style: TextStyle(color: AppColors.main)),
                      Text('Макс. количество заданий для загрузки за раз', style: TextStyle(color: AppColors.secondary, fontSize: 12)),
                      Text('0 = нет лимита, загружать все сразу (не рекомендуется)', style: TextStyle(color: AppColors.secondary, fontSize: 12)),
                    ]
                  ),
                  Row(
                    spacing: 16,
                    children: [
                      SizedBox(
                        width: 200,
                        child: Slider(
                          value: taskLimit.toDouble(),
                          onChanged: (value) {
                            taskLimit = value.toInt();
                            _updateInt('taskLimit', taskLimit == 0? 9999 : taskLimit);
                          },
                          min: 0,
                          max: 30
                        )
                      ),
                      Text(taskLimit.toString())
                    ]
                  ),
                ]
              ),
              ElevatedButton.icon(
                onPressed: logined? (){
                  _logOut();
                  Navigator.pop(context);
                  l.i('push to sign page, reason: sign out');
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AppLayout(child: SignPage())));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Вы вышли из аккаунта', style: TextStyle(color: AppColors.success))
                  ));
                } : null,
                label: const Text('Выйти из аккаунта'),
                icon: const Icon(Icons.logout)
              ),
              if (changed)
              const SizedBox(height: 10),
              if (changed)
              const Text('Для применения изменений перезагрузите страницу', style: TextStyle(color: AppColors.warning)),
              const SizedBox(height: 15),
              // const Divider(),
              // const Align(
              //   alignment: Alignment.topLeft,
              //   child: Text('Developer mode', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
              // ),
              // ElevatedButton(
              //   onPressed: (){
              //     Navigator.pop(context);
              //     l.i('push to sign page, reason: manual pushing');
              //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AppLayout(child: SignPage())));
              //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              //       content: Text('Перевод на SignPage', style: TextStyle(color: AppColors.success))
              //     ));
              //   },
              //   child: const Text('Перейти на страницу входа')
              // ),
              // ElevatedButton(
              //   onPressed: (){
              //     Navigator.pop(context);
              //     l.i('push to home page, manual pushing');
              //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AppLayout(child: HomePage())));
              //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              //       content: Text('Перевод на HomePage', style: TextStyle(color: AppColors.success))
              //     ));
              //   },
              //   child: const Text('Перейти на домашюю страницу')
              // ),
              // ElevatedButton(
              //   onPressed: (){
              //     Navigator.pop(context);
              //     l.i('push to home page, reason: manual pushing');
              //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AppLayout(child: HomePage(customerId: 42025))));
              //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              //       content: Text('Перевод на HomePage with search', style: TextStyle(color: AppColors.success))
              //     ));
              //   },
              //   child: const Text('Перейти на домашнюю страницу с абонентом')
              // )
            ]
          ),
        )
      ),
      actions: [
        ElevatedButton(
          onPressed: (){
            Navigator.pop(context);
          },
          child: const Text('Ок')
        )
      ]
    );
  }
}
