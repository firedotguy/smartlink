import 'package:flutter/material.dart';
import 'package:smartlink/i18n.dart';
import 'package:smartlink/theme.dart';
import 'package:smartlink/widgets/app_chip.dart';
import 'package:smartlink/widgets/tappable.dart';

class InfoTile extends StatelessWidget {
    const InfoTile({
        required this.title,
        super.key,
        this.value,
        this.child,
        this.value_color,
        this.preview = false,
        this.badge,
        this.hint,
        this.on_tap,
        this.action
    });

    final String title;
    final String? value;
    final Widget? child;
    final Color? value_color;
    final bool preview;
    final Widget? badge;
    final String? hint;
    final VoidCallback? on_tap;
    final Widget? action;

    Widget _value_text() {
        return child ?? Text(
            value ?? t.common.empty,
            textAlign: TextAlign.right,
            style: TextStyle(color: value_color ?? AppColors.main)
        );
    }

    Widget _build_value() {
        if (on_tap != null) {
            return Tappable(
                on_tap: on_tap,
                disable_selection: true,
                child: _value_text()
            );
        }

        if (action != null) {
            return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                    Flexible(child: _value_text()),
                    const SizedBox(width: 8),
                    action!
                ]
            );
        }

        return _value_text();
    }

    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Flexible(
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Row(
                                    mainAxisSize: MainAxisSize.min,
                                    spacing: 8,
                                    children: [
                                        Text(title, style: const TextStyle(color: AppColors.secondary)),
                                        if (preview)
                                        Tooltip(
                                            message: t.common.preview_tooltip,
                                            child: AppChip(text: t.common.preview, color: AppColors.success)
                                        ),
                                        ?badge
                                    ]
                                ),
                                if (hint != null)
                                Text(hint!, style: const TextStyle(color: AppColors.secondary, fontSize: 12))
                            ]
                        )
                    ),
                    Flexible(child: _build_value())
                ]
            )
        );
    }
}
