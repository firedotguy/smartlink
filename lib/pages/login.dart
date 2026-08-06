import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartlink/api.dart';
import 'package:smartlink/main.dart';
import 'package:smartlink/pages/home.dart';

class LoginPage extends StatefulWidget {
    const LoginPage({super.key});

    @override
    State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
    TextEditingController loginController = TextEditingController();
    TextEditingController passController = TextEditingController();
    bool load = false;

    Future<void> _login() async {
        l.i('login button clicked - login: ${loginController.text}, password: ${passController.text}');
        setState(() {
            load = true;
        });
        try{
            final result = await login(loginController.text, passController.text);
            if (result['detail'] == null){
                final prefs = await SharedPreferences.getInstance();
                prefs.setString('login', loginController.text);
                prefs.setInt('userId', result['id']);

                if (mounted){
                    l.i('logined successfully');
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Успешная авторизация', style: TextStyle(color: AppColors.success))
                    ));
                    l.i('push to home page, reason: login in');
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const AppLayout(child: HomePage())));
                }
            } else {
                setState(() {
                    load = false;
                });
                l.w('wrong login or password');
                if (mounted){
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Ошибка авторизации: неверный логин или пароль', style: TextStyle(color: AppColors.warning))
                    ));
                }
            }
        } catch (e){
            setState(() {
                load = false;
            });
            if (mounted){
                l.e('error while login: $e');
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Ошибка авторизации', style: TextStyle(color: AppColors.error))
                ));
            }
        }
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: SafeArea(
                child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                                Color(0xFF025B81),
                                Colors.black
                            ]
                        )
                    ),
                    alignment: Alignment.center,
                    child: IntrinsicWidth(
                        child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                                color: AppColors.bg,
                                borderRadius: BorderRadius.circular(12)
                            ),
                            constraints: const BoxConstraints(minWidth: 400),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                    const Text('Авторизация', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 20),
                                    TextField(
                                        decoration: const InputDecoration(hintText: 'Логин'),
                                        controller: loginController,
                                    ),
                                    const SizedBox(height: 10),
                                    TextField(
                                        decoration: const InputDecoration(hintText: 'Пароль'),
                                        obscureText: true,
                                        controller: passController,
                                        onSubmitted: (v) => _login(),
                                    ),
                                    const SizedBox(height: 15),
                                    ElevatedButton(
                                        onPressed: _login,
                                        child: load? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator()) : const Text('Войти')
                                    )
                                ]
                            )
                        )
                    )
                )
            )
        );
    }
}
