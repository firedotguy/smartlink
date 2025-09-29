import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartlink/dialogs/settings.dart';
import 'package:smartlink/firebase_options.dart';
import 'package:smartlink/pages/home.dart';
import 'package:smartlink/pages/sign.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

/// A custom linear progress bar with angled ends and animated runner.
///
/// Often used to indicate background loading or processing.
class AngularProgressBar extends StatefulWidget {
  /// Creates an angular progress bar with customizable dimensions and colors.
  const AngularProgressBar({
    super.key,
    this.width = 200,
    this.height = 10,
    this.backgroundColor = AppColors.main,
    this.color = AppColors.neo,
  });
  /// Width of the progress bar. Defaults to 200.
  final double width;
  /// Height of the progress bar. Defaults to 10.
  final double height;
  /// Background color of the progress bar.
  final Color backgroundColor;
  /// Color of the animated runner.
  final Color color;

  @override
  State<AngularProgressBar> createState() => _AngularProgressBarState();
}

class _AngularProgressBarState extends State<AngularProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipPath(
        clipper: AngularClipper(),
        child: Stack(
          children: [
            CustomPaint(
              size: Size(widget.width, widget.height),
              painter: _BarBackgroundPainter(backgroundColor: widget.backgroundColor),
            ),
            AnimatedBuilder(
              animation: _ctl,
              builder: (_, __) {
                final runnerWidth = widget.width / 5;
                final travelWidth = widget.width + runnerWidth;
                final dx = _ctl.value * travelWidth - runnerWidth;
                return Positioned(
                  left: dx,
                  child: Container(
                    width: runnerWidth,
                    height: widget.height,
                    decoration: BoxDecoration(
                      color: widget.color,
                      borderRadius: BorderRadius.circular(widget.height),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BarBackgroundPainter extends CustomPainter {

  _BarBackgroundPainter({required this.backgroundColor});
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(h / 2, 0)
      ..lineTo(w - h / 2, 0)
      ..lineTo(w, h / 2)
      ..lineTo(w - h / 2, h)
      ..lineTo(h / 2, h)
      ..lineTo(0, h / 2)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// Clipper that defines a trapezoidal shape with angled edges.
///
/// Used by [AngularProgressBar] to give the progress bar a non-rectangular shape.
class AngularClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final h = size.height;
    final w = size.width;

    final path = Path()
      ..moveTo(h / 2, 0)
      ..lineTo(w - h / 2, 0)
      ..lineTo(w, h / 2)
      ..lineTo(w - h / 2, h)
      ..lineTo(h / 2, h)
      ..lineTo(0, h / 2)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

final l = Logger(printer: SimplePrinter());

final ThemeData darkTheme = ThemeData(
  fontFamily: 'Jost',
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.bg,
  canvasColor: const Color(0xFF161b22),
  primaryColor: const Color(0xFF009bde),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Color(0xFF191D23),
    contentTextStyle: TextStyle(color: Colors.white),
  ),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF009bde),
    surface: Color(0xFF161b22),
    secondary: Color(0xFF009bde),
    error: Color(0xFFe74c3c),
    onError: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: AppColors.main
  ),
  dividerTheme: DividerThemeData(
    color: AppColors.main.withValues(alpha: 0.1)
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled)) {
          return const Color(0xFF4DAFD9);
        } else if (states.contains(WidgetState.pressed)) {
          return const Color(0xFF006692);
        } else if (states.contains(WidgetState.hovered)) {
          return const Color(0xFF0182B9);
        }
        return AppColors.neo;
      }),
      foregroundColor: WidgetStateProperty.all(AppColors.main),
      overlayColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.05)),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textStyle: WidgetStateProperty.all(
        const TextStyle(
          fontFamily: 'Jost',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.main,
        ),
      ),
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: AppColors.bg2,
    contentPadding: EdgeInsets.symmetric(vertical: 11, horizontal: 12),
    hintStyle: TextStyle(color: AppColors.secondary),
    border: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.main, width: 0.8),
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.secondary, width: 0.8),
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.neo, width: 1.2),
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.error, width: 1.2),
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
  ),
  cardTheme: const CardThemeData(
    color: AppColors.bg2,
    elevation: 5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
    margin: EdgeInsets.zero,
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: AppColors.main)
  ),
  switchTheme: SwitchThemeData(
    thumbColor: const WidgetStatePropertyAll(AppColors.main),
    overlayColor: WidgetStateProperty.all(Colors.transparent),
    trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.selected)) {
        if (states.contains(WidgetState.disabled)) {
          return const Color(0xFF4B5A6B);
        } else if (states.contains(WidgetState.hovered)) {
          return const Color(0xFF0182B9);
        }
        return AppColors.neo;
      } else {
        if (states.contains(WidgetState.hovered)){
          return const Color(0xFF7F91A6);
        }
        return AppColors.secondary;
      }
    })
  )
);

class AppColors {
  static const success = Color(0xFF58d68d);
  static const warning = Color(0xFFf1c40f);
  static const error = Color(0xFFe74c3c);
  static const neo = Color(0xFF009bde);
  static const main = Color(0xFFe6edf3);
  static const secondary = Color(0xFF8b949e);
  static const bg = Color(0xFF1e252d);
  static const bg2 = Color(0xFF2c333a);
}

String formatDate(String? date) {
  if (date == null){
    return '-';
  }
  final DateTime parsed = DateTime.parse(date);
  return '${parsed.day.toString().padLeft(2, '0')}.${parsed.month.toString().padLeft(2, '0')}.${parsed.year.toString().substring(2)} ${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}:${parsed.second.toString().padLeft(2, '0')}';
}

class AppLayout extends StatelessWidget {
  const AppLayout({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Scaffold(
        body: Stack(
          alignment: Alignment.bottomRight,
          children: [
            child,
            const Text('SmartLink viewer v0.2.0-3 [beta]', style: TextStyle(color: AppColors.secondary, fontSize: 12))
          ]
        ),
        floatingActionButton: Builder(
          builder: (context) => IconButton(
            onPressed: () {
              l.i('show settings dialog, reason: open settings');
              showDialog(
                context: context,
                builder: (_) => const SettingsDialog(),
              );
            },
            icon: const Icon(Icons.settings, color: AppColors.secondary)
          )
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop
      ),
    );
  }
}

/// The root widget of the SmartLink Viewer application.
///
/// Handles initialization and routing to either the [HomePage] or [SignPage]
/// depending on whether login credentials are stored in local preferences.
class MainApp extends StatefulWidget {
  /// Creates the main application widget.
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  Widget page = const SizedBox();

  Future init() async {
    FlutterNativeSplash.remove();
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
      page = const SignPage();
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
      themeMode: ThemeMode.dark,
      darkTheme: darkTheme,
      home: AppLayout(child: page),
      debugShowCheckedModeBanner: false,
    );
  }
}
