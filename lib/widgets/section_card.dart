import 'package:flutter/material.dart';
import 'package:smartlink/i18n.dart';
import 'package:smartlink/theme.dart';
import 'package:smartlink/widgets/app_chip.dart';

class SectionCard extends StatelessWidget {
    const SectionCard({
        required this.title,
        required this.child,
        super.key,
        this.icon,
        this.online
    });
    final String title;
    final Widget child;
    final IconData? icon;

    final bool? online;

    @override
    Widget build(BuildContext context) {
        return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200)
            ),
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                                Row(
                                    spacing: 4,
                                    children: [
                                        if (icon != null)
                                        Icon(icon, size: 18, color: AppColors.neo),
                                        Text(title, style: const TextStyle(fontWeight: FontWeight.w600))
                                    ]
                                ),
                                if (online != null)
                                AppChip(
                                    text: online!? t.status.online_badge : t.status.offline_badge,
                                    color: online!? AppColors.success : AppColors.error
                                )
                            ]
                        ),
                        child
                    ]
                )
            )
        );
    }
}
