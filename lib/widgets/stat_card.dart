import 'package:flutter/material.dart';
import 'package:smartlink/theme.dart';

/// Плитка с одной числовой метрикой (RX, TX, температура).
class StatCard extends StatelessWidget {
    const StatCard({required this.label, required this.value, super.key, this.color});
    final String label;
    final String value;
    final Color? color;

    @override
    Widget build(BuildContext context) {
        return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                border: Border.all(color: AppColors.main),
                borderRadius: BorderRadius.circular(10),
                color: AppColors.bg.withValues(alpha: 0.4)
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(label, style: const TextStyle(color: AppColors.secondary, fontSize: 12)),
                    const SizedBox(height: 6),
                    Text(
                        value,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: color ?? Theme.of(context).colorScheme.primary
                        )
                    )
                ]
            )
        );
    }
}
