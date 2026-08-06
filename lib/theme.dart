import 'package:flutter/material.dart';

/// Палитра приложения.
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

final ThemeData dark_theme = ThemeData(
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
    ),
    sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.neo,
        inactiveTrackColor: AppColors.secondary,
        disabledActiveTrackColor: AppColors.main,
        thumbColor: AppColors.neo,
        padding: EdgeInsets.zero
    )
);
