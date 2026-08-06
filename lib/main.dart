import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartlink/i18n.dart';
import 'package:smartlink/pages/home.dart';
import 'package:smartlink/pages/login.dart';
import 'package:smartlink/theme.dart';
import 'package:smartlink/utils.dart';
import 'package:smartlink/widgets/app_layout.dart';

void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    initializeDateFormatting('ru_RU', null);
    Intl.defaultLocale = 'ru_RU';
    runApp(const MainApp());
}

class MainApp extends StatefulWidget {
    const MainApp({super.key});

    @override
    State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
    Widget page = const SizedBox();

    Future<void> init() async {
        setState(() {
            page = const Scaffold(body: Center(child: CircularProgressIndicator()));
        });

        l.i('get login data from shared prefs');
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String? login = prefs.getString('login');

        if (login != null && login != ''){
            l.i('login: $login');
            page = const HomePage();
        } else {
            l.i('user not logged in');
            page = const LoginPage();
        }
        setState(() {});
    }

    @override
    void initState() {
        super.initState();
        WidgetsBinding.instance.addPostFrameCallback((_) {
            init();
        });
    }

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: t.app.title,
            themeMode: ThemeMode.dark,
            darkTheme: dark_theme,
            home: AppLayout(child: page),
            debugShowCheckedModeBanner: false,
        );
    }
}
