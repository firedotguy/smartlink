import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartlink/api.dart';
import 'package:smartlink/i18n.dart';
import 'package:smartlink/pages/home.dart';
import 'package:smartlink/theme.dart';
import 'package:smartlink/utils.dart';
import 'package:smartlink/widgets/app_layout.dart';

class LoginPage extends StatefulWidget {
    const LoginPage({super.key});

    @override
    State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
    final TextEditingController login_controller = TextEditingController();
    final TextEditingController password_controller = TextEditingController();
    bool load = false;

    @override
    void dispose() {
        login_controller.dispose();
        password_controller.dispose();
        super.dispose();
    }

    Future<void> _login() async {
        l.i('login button clicked - login: ${login_controller.text}');
        setState(() {
            load = true;
        });

        try {
            final Map result = await login(login_controller.text, password_controller.text);

            if (result['detail'] == null){
                final SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('login', login_controller.text);
                await prefs.setInt('userId', result['id']);

                if (!mounted) return;
                l.i('logined successfully');
                show_success(context, t.login.success);
                l.i('push to home page, reason: login in');
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const AppLayout(child: HomePage()))
                );
                return;
            }

            setState(() {
                load = false;
            });
            l.w('wrong login or password');
            if (mounted) show_warning(context, t.login.wrong_credentials);
        } catch (e) {
            setState(() {
                load = false;
            });
            l.e('error while login: $e');
            if (mounted) show_error(context, t.login.error);
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
                                    Text(t.login.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 20),
                                    TextField(
                                        decoration: InputDecoration(hintText: t.login.username),
                                        controller: login_controller,
                                    ),
                                    const SizedBox(height: 10),
                                    TextField(
                                        decoration: InputDecoration(hintText: t.login.password),
                                        obscureText: true,
                                        controller: password_controller,
                                        onSubmitted: (_) => _login(),
                                    ),
                                    const SizedBox(height: 15),
                                    ElevatedButton(
                                        onPressed: _login,
                                        child: load
                                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator())
                                            : Text(t.login.submit)
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
