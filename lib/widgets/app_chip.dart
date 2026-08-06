import 'package:flutter/material.dart';
import 'package:smartlink/theme.dart';
import 'package:smartlink/widgets/tappable.dart';

/// Компактная метка-«таблетка» с необязательной кликабельной иконкой.
///
/// Назван `AppChip`, а не `Chip`, чтобы не конфликтовать с материаловским
/// виджетом — иначе каждый импорт `material.dart` пришлось бы писать
/// с `hide Chip`.
class AppChip extends StatelessWidget {
    const AppChip({
        required this.text,
        super.key,
        this.icon,
        this.color = AppColors.neo,
        this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        this.on_icon_tap,
        this.icon_tooltip
    });
    final IconData? icon;
    final String text;
    final Color color;
    final EdgeInsets padding;
    final VoidCallback? on_icon_tap;
    final String? icon_tooltip;

    @override
    Widget build(BuildContext context) {
        Widget? leading;
        if (icon != null) {
            leading = Tappable(
                on_tap: on_icon_tap,
                child: Icon(icon, size: 14, color: color)
            );
            if (icon_tooltip != null) leading = Tooltip(message: icon_tooltip, child: leading);
        }

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
                    if (leading != null) leading,
                    Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600))
                ]
            )
        );
    }
}
