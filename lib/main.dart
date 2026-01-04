import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartlink/dialogs/settings.dart';
import 'package:smartlink/firebase_options.dart';
import 'package:smartlink/pages/home.dart';
import 'package:smartlink/pages/sign.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

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
        clipper: _AngularClipper(),
        child: Stack(
          children: [
            CustomPaint(
              size: Size(widget.width, widget.height),
              painter: _BarBackgroundPainter(backgroundColor: widget.backgroundColor),
            ),
            AnimatedBuilder(
              animation: _ctl,
              builder: (_, _) {
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

class _AngularClipper extends CustomClipper<Path> {
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
          return AppColors.secondary;
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

String formatDate(String? input) {
  if (input == null || input.isEmpty) {
    return '-';
  }

  final parts = input.split(' ');
  if (parts.length < 2) return input;

  final dateParts = parts[0].split('-');
  if (dateParts.length < 3) return input;

  final time = parts[1];

  final isYearFirst = dateParts[0].length == 4;

  final day = isYearFirst ? dateParts[2] : dateParts[0];
  final month = dateParts[1];
  final year = isYearFirst ? dateParts[0].substring(2) : dateParts[2].substring(2);

  return '$day.$month.$year $time';
}

Color getTaskStatusColor(int status) {
    return switch (status) {
      18 => const Color(0xFFfff100),
      12 || 20 => const Color(0xFF00a650),
      3 || 17 => const Color(0xFF438ccb),
      15 => const Color(0xFFee1d24),
      14 || 11 => AppColors.secondary,
      1 => const Color(0xFFf7941d),
      10 => const Color(0xFFef6ea8),
      16 => const Color(0xFF00aeef),
      9 => const Color(0xFF00f000),

      _ => AppColors.main
    };
  }

class Chip extends StatelessWidget {
  const Chip({required this.text, this.icon, super.key, this.color = AppColors.neo, this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3), this.onIconTap, this.iconTooltip});
  final IconData? icon;
  final String text;
  final Color color;
  final EdgeInsets padding;
  final VoidCallback? onIconTap;
  final String? iconTooltip;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: .45))
      ),
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          if (icon != null && iconTooltip == null)
          MouseRegion(
            cursor: onIconTap == null? MouseCursor.defer : SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onIconTap,
              child: Icon(icon, size: 14, color: color)
            ),
          ),
          if (icon != null && iconTooltip != null)
          Tooltip(
            message: iconTooltip,
            child: MouseRegion(
              cursor: onIconTap == null? MouseCursor.defer : SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onIconTap,
                child: Icon(icon, size: 14, color: color)
              ),
            )
          ),
          Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600))
        ]
      )
    );
  }
}

class AppLayout extends StatefulWidget {
  const AppLayout({required this.child, super.key});
  final Widget child;

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  String version = 'unknown';

  void _getVersion() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    version = info.version;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      _getVersion();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SelectionArea(
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            widget.child,
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: SelectionContainer.disabled(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: (){
                    showAboutDialog(
                      context: context,
                      applicationName: 'SmartLinkViewer',
                      applicationVersion: 'v$version (API 2.3.0)', // TODO: get api version from api
                      applicationIcon: Image.asset('assets/favicon-text.png', width: 60, height: 60),
                      applicationLegalese: '© 2025 «НеоТелеком»',
                      children: [
                        const Text('Experimental WASM renderer', style: TextStyle(color: AppColors.warning)),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () async => await launchUrl(Uri.parse('https://github.com/firedotguy/smartlink')),
                            child: const Text('View source code', style: TextStyle(color: AppColors.neo, decoration: TextDecoration.underline, decorationColor: AppColors.neo)),
                          ),
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () async => await launchUrl(Uri.parse('https://github.com/firedotguy/smartlinkAPI')),
                            child: const Text('View API source code', style: TextStyle(color: AppColors.neo, decoration: TextDecoration.underline, decorationColor: AppColors.neo)),
                          ),
                        ),
                      ]
                    );
                  },
                  child: Text('SmartLinkViewer v$version [γ]', style: const TextStyle(color: AppColors.secondary, fontSize: 12))
                )
              )
            )
          ]
        ),
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
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  Widget page = const SizedBox();

  Future init() async {
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
      title: 'SmartLink',
      themeMode: ThemeMode.dark,
      darkTheme: darkTheme,
      home: AppLayout(child: page),
      debugShowCheckedModeBanner: false,
    );
  }
}
