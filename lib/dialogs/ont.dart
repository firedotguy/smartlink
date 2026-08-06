import 'package:duration/duration.dart';
import 'package:duration/locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_formatter/flutter_date_formatter.dart';
import 'package:quantify/quantify.dart';
import 'package:smartlink/api.dart';
import 'package:smartlink/dialogs/catv_toggle.dart';
import 'package:smartlink/i18n.dart';
import 'package:smartlink/theme.dart';
import 'package:smartlink/utils.dart';
import 'package:smartlink/widgets/angular_progress_bar.dart';
import 'package:smartlink/widgets/dialog_header.dart';
import 'package:smartlink/widgets/icon_action.dart';
import 'package:smartlink/widgets/info_tile.dart';
import 'package:smartlink/widgets/port_tile.dart';
import 'package:smartlink/widgets/section_card.dart';
import 'package:smartlink/widgets/stat_card.dart';

class OntDialog extends StatefulWidget {
    const OntDialog({
        required this.olt_id,
        required this.sn,
        required this.customer_id,
        required this.agreement,
        super.key,
        this.is_customer_active = true
    });
    final int olt_id;
    final String sn;
    final int customer_id;
    final String agreement;
    final bool is_customer_active;

    @override
    State<OntDialog> createState() => _OntDialogState();
}

class _OntDialogState extends State<OntDialog> {
    Map? data;
    bool restarting = false;
    bool rewriting_sn = false;
    bool rewriting_mac = false;

    bool get _online => data?['online'] == true;
    bool get _loaded => data != null;

    @override
    void initState() {
        super.initState();
        _load();
    }


    // ─── данные ──────────────────────────────────────────────────────────────

    Future<void> _load() async {
        data = await get_ont(widget.olt_id, widget.sn);

        if (data!['detail'] != null && mounted) {
            show_error(context, t.ont.load_error('${data!['detail']}'));
            Navigator.pop(context);
            return;
        }
        setState(() {});
    }

    /// Помечает ONT офлайн после перезагрузки, не дожидаясь опроса.
    void _mark_offline() {
        data!['last_down'] = DateTime.now().format(pattern: 'yyyy.MM.dd HH:mm:ss');
        data!['last_down_cause'] = 'reset';
        data!['rx'] = null;
        data!['tx'] = null;
        data!['temp'] = null;
        data!['online'] = false;

        for (final port in (data!['catv'] as List? ?? const [])) {
            port['actual_status'] = false;
        }
        for (final port in (data!['eth'] as List? ?? const [])) {
            port['actual_status'] = false;
        }
    }

    Future<void> _restart() async {
        if (restarting) return;
        setState(() {
            restarting = true;
        });

        try {
            final res = await restart_ont(widget.sn, widget.olt_id);

            if (res?['detail'] != null) {
                l.e('error restarting ont: ${res['detail']}');
                if (mounted) show_error(context, t.ont.restart_error('${res['detail']}'));
                return;
            }

            _mark_offline();
            if (mounted) show_success(context, t.ont.restarted);
        } catch (e) {
            l.e('error restarting ont: $e');
            if (mounted) show_error(context, t.ont.restart_failed);
        } finally {
            if (mounted) {
                setState(() {
                    restarting = false;
                });
            }
        }
    }

    Future<void> _rewrite_sn() async {
        if (rewriting_sn) return;
        setState(() {
            rewriting_sn = true;
        });

        try {
            final res = await rewrite_sn(widget.sn, widget.customer_id, widget.agreement);

            if (!mounted) return;
            if (res?['detail'] != null){
                l.e('error rewriting sn: ${res['detail']}');
                show_error(context, t.ont.rewrite_sn_error('${res['detail']}'));
            } else {
                show_success(context, t.ont.sn_rewritten);
            }
        } catch (e) {
            l.e('error rewriting sn: $e');
            if (mounted) show_error(context, t.ont.rewrite_sn_failed);
        } finally {
            if (mounted) {
                setState(() {
                    rewriting_sn = false;
                });
            }
        }
    }

    Future<void> _rewrite_mac() async {
        if (rewriting_mac) return;
        setState(() {
            rewriting_mac = true;
        });

        try {
            final res = await rewrite_mac(widget.customer_id, widget.agreement);

            if (!mounted) return;
            if (res?['detail'] != null){
                l.e('error rewriting mac: ${res['detail']}');
                show_error(context, t.ont.rewrite_mac_error('${res['detail']}'));
            } else {
                show_success(context, t.ont.mac_rewritten);
            }
        } catch (e) {
            l.e('error rewriting mac: $e');
            if (mounted) show_error(context, t.ont.rewrite_mac_failed);
        } finally {
            if (mounted) {
                setState(() {
                    rewriting_mac = false;
                });
            }
        }
    }

    Future<void> _toggle_catv(int id, bool state) async {
        final bool? toggled = await showDialog(
            context: context,
            builder: (context) => CatvToggleDialog(
                state: state,
                sn: widget.sn,
                catv_id: id,
                olt_id: data!['olt']['id'],
                is_customer_active: widget.is_customer_active
            )
        );

        if (toggled == true){
            setState(() {
                data!['catv'][id - 1]['status'] = !state;
                data!['catv'][id - 1]['actual_status'] = !state;
            });
        }
    }


    // ─── форматирование ──────────────────────────────────────────────────────

    String? _uptime() {
        if (data?['last_up'] == null || !_online) return null;

        final DateTime? last_up = parse_api_date(data!['last_up']);
        if (last_up == null) return null;

        return DateTime.now().difference(last_up).pretty(
            locale: DurationLocale.fromLanguageCode('ru')!,
            tersity: DurationTersity.minute
        );
    }

    String _relative_date(String raw) {
        final DateTime? parsed = parse_api_date(raw);
        if (parsed == null) return format_date(raw);

        return t.ont.relative_date(
            FlutterDateFormatter.formatRelativeDateTime(parsed),
            format_date(raw)
        );
    }

    String _port_tooltip(Map port) {
        return t.ont.port_tooltip(
            port['status'] == true? t.status.enabled : t.status.disabled,
            port['actual_status'] == true? t.status.online : t.status.offline
        );
    }

    String _eth_detail(Map port) {
        if (port['status'] != true) return t.ont.port_shutdown;
        if (port['actual_status'] != true) return t.ont.port_broken;

        return t.ont.port_speed(
            '${port['speed'] ?? t.common.empty}',
            '${port['duplex'] ?? '?'}'
        );
    }


    // ─── интерфейс ───────────────────────────────────────────────────────────

    Widget _olt_section() {
        return SectionCard(
            icon: Icons.dns_rounded,
            title: t.ont.section_olt,
            online: data!['olt']['online'],
            child: Column(
                children: [
                    InfoTile(title: t.ont.olt_name, value: data!['olt']['name']),
                    InfoTile(title: t.ont.olt_location, value: data!['olt']['location']),
                    const SizedBox(height: 8),
                    Row(
                        children: [
                            Expanded(child: _signal_card(t.ont.rx, data!['rx_olt'], get_rx_color)),
                            const SizedBox(width: 8),
                            Expanded(child: _signal_card(t.ont.tx, data!['tx_olt'], get_tx_color))
                        ]
                    )
                ]
            )
        );
    }

    Widget _ont_section() {
        final String? uptime = _uptime();

        return SectionCard(
            icon: Icons.memory,
            title: t.ont.section_ont,
            online: data!['online'],
            child: Column(
                children: [
                    InfoTile(title: t.ont.sn, value: widget.sn),
                    InfoTile(title: t.ont.ip, value: data!['ip']),

                    if (uptime != null)
                    InfoTile(title: t.ont.uptime, value: uptime),

                    if (data!['distance'] != null)
                    InfoTile(
                        title: t.ont.distance,
                        value: (data!['distance'] as int).meter
                            .toString(targetUnit: LengthUnit.kilometer)
                            .replaceAll('km', t.ont.kilometers)
                    ),

                    if (data!['last_up'] != null)
                    InfoTile(title: t.ont.last_up, value: _relative_date(data!['last_up'])),

                    if (data!['last_down'] != null)
                    InfoTile(title: t.ont.last_down, value: _relative_date(data!['last_down'])),

                    if (data!['last_down_cause'] != null)
                    InfoTile(title: t.ont.last_down_cause, value: '${data!['last_down_cause']}'),

                    if (data!['ping'] != null)
                    InfoTile(title: t.ont.ping, value: '${data!['ping']}'),

                    const SizedBox(height: 8),
                    Row(
                        children: [
                            Expanded(child: _signal_card(t.ont.rx, data!['rx'], get_rx_color)),
                            const SizedBox(width: 8),
                            Expanded(child: _signal_card(t.ont.tx, data!['tx'], get_tx_color)),
                            const SizedBox(width: 8),
                            Expanded(
                                child: StatCard(
                                    label: t.ont.temperature,
                                    value: '${data!['temp']?.toStringAsFixed(0) ?? t.common.empty}°C',
                                    color: get_temp_color(data!['temp'])
                                )
                            )
                        ]
                    )
                ]
            )
        );
    }

    Widget _signal_card(String label, dynamic value, Color Function(double) color_of) {
        return StatCard(
            label: label,
            value: value?.toStringAsFixed(2) ?? t.common.empty,
            color: value == null? AppColors.neo : color_of(value)
        );
    }

    Widget _ports_section() {
        final List catv = data!['catv'] as List? ?? const [];
        final List eth = data!['eth'] as List? ?? const [];

        return SelectionContainer.disabled(
            child: Row(
                spacing: 4,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Flexible(
                        child: SectionCard(
                            icon: Icons.tv,
                            title: t.ont.section_catv,
                            child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: catv.isEmpty
                                    ? [Text(t.ont.no_catv_ports, style: const TextStyle(color: AppColors.secondary))]
                                    : catv.map<Widget>((port) {
                                        final bool enabled = port['status'] == true;
                                        return PortTile(
                                            label: t.ont.port('${port['id']}'),
                                            up: port['actual_status'] == true,
                                            enabled: enabled,
                                            detail: enabled? t.status.enabled : t.status.disabled,
                                            tooltip: _port_tooltip(port),
                                            on_tap: () => _toggle_catv(port['id'], enabled)
                                        );
                                    }).toList()
                            )
                        )
                    ),
                    Flexible(
                        child: SectionCard(
                            icon: Icons.lan,
                            title: t.ont.section_eth,
                            child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: eth.isEmpty
                                    ? [Text(t.ont.no_eth_ports, style: const TextStyle(color: AppColors.secondary))]
                                    : eth.map<Widget>((port) {
                                        return PortTile(
                                            label: t.ont.port('${port['id']}'),
                                            up: port['actual_status'] == true,
                                            enabled: port['status'] == true,
                                            detail: _eth_detail(port),
                                            tooltip: _port_tooltip(port)
                                        );
                                    }).toList()
                            )
                        )
                    )
                ]
            )
        );
    }

    Widget _action_button(String label, IconData icon, bool busy, VoidCallback action) {
        return ElevatedButton.icon(
            onPressed: busy || !_loaded || !_online? null : action,
            label: busy
                ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator())
                : Text(label),
            icon: busy? null : Icon(icon)
        );
    }

    @override
    Widget build(BuildContext context) {
        final bool can_act = _loaded && _online;

        return AlertDialog(
            title: DialogHeader(
                title: t.ont.title,
                icon: Icons.router_outlined,
                actions: [
                    IconAction(
                        tooltip: t.ont.restart,
                        icon: Icons.restart_alt,
                        enabled: can_act && !restarting,
                        on_pressed: _restart
                    ),
                    IconAction(
                        tooltip: t.ont.rewrite_sn,
                        icon: Icons.save_as,
                        enabled: can_act && !rewriting_sn,
                        on_pressed: _rewrite_sn
                    ),
                    IconAction(
                        tooltip: t.ont.rewrite_mac,
                        icon: Icons.settings_ethernet,
                        enabled: can_act && !rewriting_mac,
                        on_pressed: _rewrite_mac
                    )
                ]
            ),
            content: SelectionArea(
                child: SizedBox(
                    width: 600,
                    child: !_loaded? const Center(child: AngularProgressBar()) : SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: 8,
                            children: [
                                if (data!['olt'] != null) _olt_section(),
                                _ont_section(),
                                _ports_section(),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 8,
                                    children: [
                                        _action_button(t.ont.restart, Icons.restart_alt, restarting, _restart),
                                        _action_button(t.ont.rewrite_sn, Icons.save_as, rewriting_sn, _rewrite_sn),
                                        _action_button(t.ont.rewrite_mac, Icons.settings_ethernet, rewriting_mac, _rewrite_mac)
                                    ]
                                )
                            ]
                        )
                    )
                )
            )
        );
    }
}
