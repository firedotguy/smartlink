import 'package:flutter/material.dart';
import 'package:smartlink/theme.dart';

/// Маленькая иконка-действие с подсказкой.
///
/// Используется в заголовках карточек и диалогов. Когда [on_pressed] равен
/// `null`, иконка автоматически становится серой.
class IconAction extends StatelessWidget {
    const IconAction({
        required this.tooltip,
        required this.icon,
        super.key,
        this.on_pressed,
        this.color = AppColors.neo,
        this.enabled = true
    });
    final String tooltip;
    final IconData icon;
    final VoidCallback? on_pressed;
    final Color color;

    /// Позволяет погасить кнопку, не убирая обработчик.
    final bool enabled;

    @override
    Widget build(BuildContext context) {
        final bool active = enabled && on_pressed != null;

        return Tooltip(
            message: tooltip,
            child: IconButton(
                onPressed: active? on_pressed : null,
                icon: Icon(icon, size: 18, color: active? color : AppColors.secondary),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36)
            )
        );
    }
}
