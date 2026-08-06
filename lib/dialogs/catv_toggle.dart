import 'package:flutter/material.dart';
import 'package:smartlink/api.dart';
import 'package:smartlink/i18n.dart';
import 'package:smartlink/theme.dart';
import 'package:smartlink/utils.dart';
import 'package:smartlink/widgets/dialog_header.dart';
import 'package:smartlink/widgets/icon_action.dart';
import 'package:smartlink/widgets/info_tile.dart';

/// Подтверждение переключения CATV-порта.
class CatvToggleDialog extends StatefulWidget {
    const CatvToggleDialog({
        required this.state,
        required this.olt_id,
        required this.catv_id,
        required this.sn,
        super.key,
        this.is_customer_active = false
    });

    /// Текущее состояние порта.
    final bool state;

    final int olt_id;
    final int catv_id;
    final String sn;
    final bool is_customer_active;

    @override
    State<CatvToggleDialog> createState() => _CatvToggleDialogState();
}

class _CatvToggleDialogState extends State<CatvToggleDialog> {
    bool toggling = false;

    Future<void> _toggle() async {
        if (toggling) return;
        setState(() {
            toggling = true;
        });

        bool toggled = false;
        try {
            final res = await toggle_catv(widget.sn, widget.olt_id, widget.catv_id, !widget.state);

            if (res?['detail'] != null){
                l.e('error toggling catv: ${res['detail']}');
                if (mounted) show_error(context, t.catv.toggle_error('${res['detail']}'));
            } else {
                l.i('catv toggled');
                toggled = true;
                if (mounted) show_success(context, t.catv.toggled);
            }
        } catch (e) {
            l.e('error toggling catv: $e');
            if (mounted) show_error(context, t.catv.toggle_failed);
        } finally {
            if (mounted) Navigator.pop(context, toggled);
        }
    }

    @override
    Widget build(BuildContext context) {
        return AlertDialog(
            title: DialogHeader(
                title: widget.state? t.catv.disable_title : t.catv.enable_title,
                actions: [
                    IconAction(
                        tooltip: t.catv.toggle_tooltip,
                        icon: widget.state? Icons.toggle_off : Icons.toggle_on,
                        enabled: widget.is_customer_active && !toggling,
                        on_pressed: _toggle
                    )
                ]
            ),
            content: SelectionArea(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(
                            widget.state? t.catv.disable_confirm : t.catv.enable_confirm,
                            style: const TextStyle(fontSize: 16)
                        ),
                        InfoTile(
                            title: t.catv.port_state,
                            value: widget.state? t.status.enabled : t.status.disabled,
                            value_color: widget.state? AppColors.success : AppColors.error
                        ),
                        InfoTile(title: t.catv.sn, value: widget.sn),
                        InfoTile(title: t.catv.olt_id, value: widget.olt_id.toString()),
                        InfoTile(title: t.catv.catv_id, value: widget.catv_id.toString()),

                        if (!widget.is_customer_active) ...[
                            const SizedBox(height: 5),
                            Text(
                                t.catv.customer_inactive,
                                style: const TextStyle(color: AppColors.error, fontSize: 15)
                            )
                        ]
                    ]
                )
            ),
            actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(t.common.cancel)
                ),
                ElevatedButton(
                    onPressed: widget.is_customer_active? _toggle : null,
                    child: toggling
                        ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator())
                        : Text(widget.state? t.catv.disable : t.catv.enable)
                )
            ]
        );
    }
}
