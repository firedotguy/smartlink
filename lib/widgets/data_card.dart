import 'package:flutter/material.dart';
import 'package:smartlink/theme.dart';

class DataCard extends StatelessWidget {
    const DataCard({
        required this.line_color,
        required this.title,
        required this.child,
        super.key,
        this.icon,
        this.last = false,
        this.flex = 1,
        this.mini_buttons = const []
    });

    final Color line_color;

    final IconData? icon;
    final String title;
    final Widget child;

    final bool last;

    final int flex;
    final List<Widget> mini_buttons;

    @override
    Widget build(BuildContext context) {
        return Expanded(
            flex: flex,
            child: Card(
                margin: !last? const EdgeInsets.only(bottom: 16, right: 16) : const EdgeInsets.only(bottom: 16),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SelectionArea(
                        child: Row(
                            spacing: 8,
                            children: [
                                Container(width: 6, color: line_color),
                                Expanded(
                                    child: Padding(
                                        padding: const EdgeInsets.only(top: 8, bottom: 16, right: 16),
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                                Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                        Row(
                                                            spacing: 8,
                                                            children: [
                                                                if (icon != null)
                                                                Icon(icon, color: AppColors.neo),
                                                                Text(
                                                                    title,
                                                                    style: const TextStyle(
                                                                        color: AppColors.main,
                                                                        fontSize: 18,
                                                                        fontWeight: FontWeight.bold
                                                                    )
                                                                )
                                                            ]
                                                        ),
                                                        Row(spacing: 2, children: mini_buttons)
                                                    ]
                                                ),
                                                const Divider(),
                                                const SizedBox(height: 4),
                                                Expanded(child: child)
                                            ]
                                        )
                                    )
                                )
                            ]
                        )
                    )
                )
            )
        );
    }
}
