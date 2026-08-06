import 'package:flutter/material.dart';
import 'package:smartlink/theme.dart';

/// Подзаголовок внутри карточки: иконка, текст и разделитель.
class SubHeading extends StatelessWidget {
    const SubHeading({required this.icon, required this.title, super.key, this.divider = true});
    final IconData icon;
    final String title;
    final bool divider;

    @override
    Widget build(BuildContext context) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
                    children: [
                        Icon(icon, color: AppColors.neo),
                        const SizedBox(width: 8),
                        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold))
                    ]
                ),
                if (divider) const Divider()
            ]
        );
    }
}
