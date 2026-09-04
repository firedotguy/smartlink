import 'package:duration/duration.dart';
import 'package:duration/locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_formatter/flutter_date_formatter.dart';
import 'package:quantify/quantify.dart';
import 'package:smartlink/api.dart';
import 'package:smartlink/dialogs/catv_toggle.dart';
import 'package:smartlink/exception.dart';
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
        this.is_customer_active = true,
        this.neighbour_id
    });
    final int olt_id;
    final String sn;
    final int customer_id;
    final String agreement;
    final bool is_customer_active;
    final int? neighbour_id;

    @override
    State<OntDialog> createState() => _OntDialogState();
}

class _OntDialogState extends State<OntDialog> {
    Map? ont;
    int? olt_ping;
    int? neighbour_ping;
    int? my_ping;
    bool restarting = false;
    bool rewriting_sn = false;
    bool rewriting_mac = false;

    bool get _online => ont?['online'] == true;

    @override
    void initState() {
        super.initState();
        _load();
    }

    Future _ping_olt() async {
        final pings = await guard(context, () => ping(ont!['olt']['ip']));
        if (pings != null){
            olt_ping = average(List<double>.from(pings));
            if (!mounted) return;
            setState(() {});
        }
    }
    Future _ping_neighbour() async {
        if (widget.neighbour_id == null) {
            l.e('no neighbour');
            show_error(context, t.ont.neighbour_not_found);
            return;
        }
        final neighbour = await guard(context, () => get_customer(widget.neighbour_id!, full: false));
        if (neighbour?['ip'] == null) {
            l.e('neighbour has not ip');
            if (!mounted) return;
            show_error(context, t.ont.neighbour_has_not_ip);
            return;
        }
        if (!mounted) return;
        final pings = await guard(context, () => ping(neighbour!['ip']));
        if (pings != null) {
            neighbour_ping = average(List<double>.from(pings));
            if (!mounted) return;
            setState(() {});
        }
    }
    Future _ping_me() async {
        if (ont?['ip'] == null) {
            l.e('ont has not ip');
            return;
        }
        final pings = await guard(context, () => ping(ont!['ip']));
        if (pings != null) {
            my_ping = average(List<double>.from(pings));
            if (!mounted) return;
            setState(() {});
        }
    }

    Future _ping() async {
        _ping_neighbour();
        _ping_me();
        _ping_olt();
    }

    Future _load() async {
        ont = await guard(context, () => get_ont(widget.olt_id, widget.sn));
        if (!mounted) return;
        if (ont == null) {
            Navigator.pop(context);
        }
        setState(() {});
        if (_online) {
            await _ping();
        }
    }

    void _mark_offline() {
        ont!['last_down'] = DateTime.now().format(pattern: 'yyyy.MM.dd HH:mm:ss');
        ont!['last_down_cause'] = 'reset';
        ont!['rx'] = null;
        ont!['tx'] = null;
        ont!['temp'] = null;
        ont!['online'] = false;

        for (final port in (ont!['catv'] as List? ?? const [])) {
            port['actual_status'] = false;
        }
        for (final port in (ont!['eth'] as List? ?? const [])) {
            port['actual_status'] = false;
        }
    }

    Future _restart() async {
        setState(() => restarting = true);

        final res = await guard(context, () => restart_ont(widget.sn, widget.olt_id));
        if (!mounted) return;
        setState(() => restarting = false);
        if (res == null) return;

        _mark_offline();
        show_success(context, t.ont.restarted);
    }

    Future _rewrite_sn() async {
        setState(() => rewriting_sn = true);

        final res = await guard(context, () => rewrite_sn(widget.sn, widget.customer_id, widget.agreement));
        if (!mounted) return;
        setState(() => rewriting_sn = false);
        if (res == null) return;

        show_success(context, t.ont.sn_rewritten);
    }

    Future _rewrite_mac() async {
        setState(() => rewriting_mac = true);

        final res = await guard(context, () => rewrite_mac(widget.customer_id, widget.agreement));
        if (!mounted) return;
        setState(() => rewriting_mac = false);
        if (res == null) return;

        show_success(context, t.ont.mac_rewritten);
    }

    Future _toggle_catv(int id, bool state) async {
        final bool? toggled = await showDialog(
            context: context,
            builder: (context) => CatvToggleDialog(
                state: state,
                sn: widget.sn,
                catv_id: id,
                olt_id: ont!['olt']['id'],
                is_customer_active: widget.is_customer_active
            )
        );

        if (toggled == true){
            setState(() {
                ont!['catv'][id - 1]['status'] = !state;
                ont!['catv'][id - 1]['actual_status'] = !state;
            });
        }
    }


    String? _uptime() {
        if (ont?['last_up'] == null || !_online) return null;

        final DateTime? last_up = parse_api_date(ont!['last_up']);
        if (last_up == null) return null;

        return DateTime.now().difference(last_up).pretty(
            locale: DurationLocale.fromLanguageCode(current_locale)!,
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


    @override
    Widget build(BuildContext context) {
        final bool can_act = ont != null && _online;
        final online_stops = ont != null? get_ont_online_stops(parse_api_date(ont!['last_down']), parse_api_date(ont!['last_up'])) : null;

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
                    child: ont == null? const Center(child: AngularProgressBar()) : SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: 8,
                            children: [
                                if (ont!['olt'] != null)
                                SectionCard(
                                    icon: Icons.dns_rounded,
                                    title: t.ont.section_olt,
                                    online: ont!['olt']['online'],
                                    child: Column(
                                        children: [
                                            InfoTile(title: t.ont.olt_name, value: ont!['olt']['name']),
                                            InfoTile(title: t.ont.olt_location, value: ont!['olt']['location']),
                                            const SizedBox(height: 8),
                                            Row(
                                                children: [
                                                    Expanded(
                                                        child: StatCard(
                                                            label: t.ont.rx,
                                                            value: ont!['rx_olt']?.toStringAsFixed(2) ?? t.common.empty,
                                                            color: ont!['rx_olt'] == null? AppColors.neo : get_rx_color(ont!['rx_olt'])
                                                        )
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                        child: StatCard(
                                                            label: t.ont.tx,
                                                            value: ont!['tx_olt']?.toStringAsFixed(2) ?? t.common.empty,
                                                            color: ont!['tx_olt'] == null? AppColors.neo : get_tx_color(ont!['tx_olt'])
                                                        )
                                                    ),
                                                ]
                                            )
                                        ]
                                    )
                                ),
                                SectionCard(
                                    title: t.ont.ping,
                                    child: olt_ping == null? const Center(child: AngularProgressBar()) : Row(
                                        spacing: 8,
                                        children: [
                                            Expanded(
                                                child: StatCard(
                                                    label: t.ont.this_ont,
                                                    value: my_ping != null? '${my_ping!.toString()}${t.ont.milliseconds}' : '-',
                                                    color: get_ping_color(my_ping)
                                                )
                                            ),
                                            Expanded(
                                                child: StatCard(
                                                    label: t.ont.neighbour_ont,
                                                    value: neighbour_ping != null? '${neighbour_ping!.toString()}${t.ont.milliseconds}' : '-',
                                                    color: get_ping_color(neighbour_ping)
                                                )
                                            ),
                                            Expanded(
                                                child: StatCard(
                                                    label: t.ont.olt,
                                                    value: olt_ping != null? '${olt_ping!.toString()}${t.ont.milliseconds}' : '-',
                                                    color: get_ping_color(olt_ping)
                                                )
                                            )
                                        ]
                                    )
                                ),
                                SectionCard(
                                    icon: Icons.memory,
                                    title: t.ont.section_ont,
                                    online: ont!['online'],
                                    child: Column(
                                        children: [
                                            InfoTile(title: t.ont.sn, value: widget.sn),
                                            InfoTile(title: t.ont.ip, value: ont!['ip']),

                                            if (_uptime() != null)
                                            InfoTile(title: t.ont.uptime, value: _uptime()),

                                            if (ont!['distance'] != null)
                                            InfoTile(
                                                title: t.ont.distance,
                                                value: (ont!['distance'] as int).meter
                                                    .toString(targetUnit: LengthUnit.kilometer, format: const QuantityFormat(fractionDigits: 3))
                                                    .replaceAll('km', t.ont.kilometers)
                                            ),

                                            if (ont!['online'] && ont!['last_up'] != null)
                                            InfoTile(title: t.ont.last_up, value: _relative_date(ont!['last_up'])),

                                            if (!ont!['online'] && ont!['last_down'] != null)
                                            InfoTile(title: t.ont.last_down, value: _relative_date(ont!['last_down'])),

                                            if (!ont!['online'] && ont!['last_down_cause'] != null)
                                            InfoTile(title: t.ont.last_down_cause, value: '${ont!['last_down_cause']}'),

                                            Container(
                                                decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                        colors: online_stops!.$1,
                                                        stops: online_stops.$2
                                                    ),
                                                    borderRadius: BorderRadius.circular(4)
                                                ),
                                                width: double.maxFinite,
                                                height: 10,
                                                margin: const EdgeInsets.only(top: 10, bottom: 8),
                                                child: Row(
                                                    children: List.generate(168, (i) => Tooltip(
                                                        message: online_stops.$3[i],
                                                        child: const SizedBox(height: 10, width: 3.45)
                                                    ))
                                                )
                                            ),

                                            if (ont!['ping'] != null)
                                            InfoTile(title: t.ont.ping, value: '${ont!['ping']}'),
                                            const SizedBox(height: 8),
                                            Row(
                                                spacing: 8,
                                                children: [
                                                    Expanded(
                                                        child: StatCard(
                                                            label: t.ont.rx,
                                                            value: ont!['rx']?.toStringAsFixed(2) ?? t.common.empty,
                                                            color: ont!['rx'] == null? AppColors.neo : get_rx_color(ont!['rx'])
                                                        )
                                                    ),
                                                    Expanded(
                                                        child: StatCard(
                                                            label: t.ont.tx,
                                                            value: ont!['tx']?.toStringAsFixed(2) ?? t.common.empty,
                                                            color: ont!['tx'] == null? AppColors.neo : get_tx_color(ont!['tx'])
                                                        )
                                                    ),
                                                    Expanded(
                                                        child: StatCard(
                                                            label: t.ont.temperature,
                                                            value: '${ont!['temp']?.toStringAsFixed(0) ?? t.common.empty}°C',
                                                            color: get_temp_color(ont!['temp'])
                                                        )
                                                    )
                                                ]
                                            )
                                        ]
                                    )
                                ),
                                SelectionContainer.disabled(
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
                                                        children: ont!['catv'].isEmpty? [Text(t.ont.no_catv_ports, style: const TextStyle(color: AppColors.secondary))] :
                                                        ont!['catv'].map<Widget>((port) {
                                                            final bool enabled = port['status'] == true;
                                                            return PortTile(
                                                                label: t.ont.port('${port['id']}'),
                                                                up: port['actual_status'] == true,
                                                                enabled: enabled,
                                                                detail: enabled? t.status.enabled : t.status.disabled,
                                                                tooltip: t.ont.catv_tooltip(
                                                                    port['status'] == true? t.status.enabled : t.status.disabled,
                                                                    port['actual_status'] == true? t.status.online : t.status.offline
                                                                ),
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
                                                        children: ont!['eth'].isEmpty? [Text(t.ont.no_eth_ports, style: const TextStyle(color: AppColors.secondary))] :
                                                        ont!['eth'].map<Widget>((port) {
                                                            return PortTile(
                                                                label: t.ont.port('${port['id']}'),
                                                                up: port['actual_status'] == true,
                                                                enabled: port['status'] == true,
                                                                duplex: port['duplex'],
                                                                detail: port['status'] != true? t.ont.port_shutdown : port['actual_status'] != true? t.ont.port_broken : t.ont.port_speed(
                                                                    '${port['speed'] ?? t.common.empty}', '${port['duplex'] ?? '?'}'
                                                                ),
                                                                tooltip: t.ont.eth_tooltip(
                                                                    port['status'] == true? t.status.enabled : t.status.disabled,
                                                                    port['actual_status'] == true? t.status.online : t.status.offline,
                                                                    port['speed'].toString(),
                                                                    port['duplex'] == 'half'? t.ont.eth_duplex_half : port['duplex'] == 'full'? t.ont.eth_duplex_full : t.ont.eth_duplex_neg,
                                                                )
                                                            );
                                                        }).toList()
                                                    )
                                                )
                                            )
                                        ]
                                    )
                                ),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 8,
                                    children: [
                                        ElevatedButton.icon(
                                            onPressed: restarting || ont == null || !_online? null : _restart,
                                            label: restarting? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator()) : Text(t.ont.restart),
                                            icon: restarting? null : const Icon(Icons.restart_alt)
                                        ),
                                        ElevatedButton.icon(
                                            onPressed: rewriting_sn || ont == null || !_online? null : _rewrite_sn,
                                            label: rewriting_sn? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator()) : Text(t.ont.rewrite_sn),
                                            icon: rewriting_sn? null : const Icon(Icons.save_as)
                                        ),
                                        ElevatedButton.icon(
                                            onPressed: rewriting_sn || ont == null || !_online? null : _rewrite_mac,
                                            label: rewriting_sn? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator()) : Text(t.ont.rewrite_mac),
                                            icon: rewriting_sn? null : const Icon(Icons.settings_ethernet)
                                        )
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
