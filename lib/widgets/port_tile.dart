import 'package:flutter/material.dart';
import 'package:smartlink/i18n.dart';
import 'package:smartlink/theme.dart';

/// Плитка порта ONT (CATV или ETH).
///
/// Цвет отражает реальное состояние линка ([up]), а серый цвет с иконкой
/// «запрещено» — административно выключенный порт ([enabled] == false).
class PortTile extends StatelessWidget {
    const PortTile({
        required this.label,
        required this.up,
        required this.tooltip,
        super.key,
        this.enabled = true,
        this.detail,
        this.on_tap
    });

    final String label;

    /// Реальное состояние линка (`actual_status`).
    final bool up;

    /// Административное состояние порта (`status`).
    final bool enabled;

    /// Вторая строка плитки: скорость, дуплекс или причина отсутствия линка.
    final String? detail;

    final String tooltip;
    final VoidCallback? on_tap;

    @override
    Widget build(BuildContext context) {
        final Color color = !enabled? AppColors.secondary : up? AppColors.success : AppColors.error;

        return Tooltip(
            message: tooltip,
            child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: on_tap,
                child: Container(
                    width: 110,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: color.withValues(alpha: 0.45))
                    ),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 3,
                        children: [
                            Row(
                                spacing: 6,
                                children: [
                                    Icon(enabled? Icons.circle : Icons.block, size: 11, color: color),
                                    Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))
                                ]
                            ),
                            Text(
                                detail ?? (up? t.status.enabled : t.status.disabled),
                                style: TextStyle(fontSize: 12, color: AppColors.main.withValues(alpha: 0.7))
                            )
                        ]
                    )
                )
            )
        );
    }
}
