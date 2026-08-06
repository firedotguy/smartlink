import 'package:duration/duration.dart';
import 'package:duration/locale.dart';
import 'package:flutter/material.dart' hide Chip;
import 'package:flutter_date_formatter/flutter_date_formatter.dart';
import 'package:quantify/quantify.dart';
import 'package:smartlink/api.dart';
import 'package:smartlink/dialogs/catvtoggle.dart';
import 'package:smartlink/main.dart';

class OntDialog extends StatefulWidget {
    const OntDialog({required this.oltId, required this.sn, required this.customerId, required this.agreement, this.isCustomerActive = true, super.key});
    final int oltId;
    final String sn;
    final int customerId;
    final String agreement;
    final bool isCustomerActive;

    @override
    State<OntDialog> createState() => _OntDialogState();
}

class _OntDialogState extends State<OntDialog> {
    Map? data;
    bool restarting = false;
    bool rewritingSN = false;
    bool rewritingMAC = false;

    void _getData() async {
        data = await getOnt(widget.oltId, widget.sn);
        if (data!['detail'] != null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка получения данных ONT: ${data!['detail']}', style: const TextStyle(color: AppColors.error))));
            Navigator.pop(context);
        }
        setState(() {});
    }

    void _restartONT() async {
        if (restarting) return;
        try {
            setState(() {
                restarting = true;
            });
            final res = await restartOnt(widget.sn, widget.oltId);
            if (res?['detail'] != null) {
                l.e('error restarting ont: ${res['detail']}');
                if (mounted){
                    // Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка перезапуска ONT: ${res['detail']}', style: const TextStyle(color: AppColors.error))));
                }
            }
            data!['last_down'] = DateTime.now().format(pattern: 'yyyy.MM.dd HH:mm:ss');
            data!['last_down_cause'] = 'reset';
            data!['rx'] = null;
            data!['tx'] = null;
            data!['temp'] = null;
            data!['online'] = false;
            data!['catv'].forEach((e) => { e['actual_status'] = false });
            data!['eth'].forEach((e) => { e['actual_status'] = false });
            setState(() {
                restarting = false;
            });
            if (mounted) {
                // Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ONT перезапущен', style: TextStyle(color: AppColors.success))));
            }
        } catch (e) {
            setState(() {
                restarting = false;
            });
            l.e('error restarting ont: $e');
            if (mounted){
                // Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка перезапуска ONT', style: TextStyle(color: AppColors.error))));
            }
        }
    }

    void _rewriteSN() async {
        if (rewritingSN) return;
        try {
            setState(() {
                rewritingSN = true;
            });
            final res = await rewriteSN(widget.sn, widget.customerId, widget.agreement);
            if (res?['detail'] != null){
                l.e('error rewriting sn: ${res['detail']}');
                if (mounted){
                    // Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка перезаписи SN: ${res['detail']}',
                        style: const TextStyle(color: AppColors.error)
                    )));
                    setState(() {
                        rewritingSN = false;
                    });
                }
            } else {
                if (mounted) {
                    // Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('SN перезаписан',
                        style: TextStyle(color: AppColors.success)
                    )));
                    setState(() {
                        rewritingSN = false;
                    });
                }
            }
        } catch (e) {
            l.e('error rewriting sn: $e');
            if (mounted){
                // Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка перезаписи SN',
                    style: TextStyle(color: AppColors.error)
                )));
                setState(() {
                    rewritingSN = false;
                });
            }
        }
    }

    void _rewriteMAC() async {
        if (rewritingMAC) return;
        try {
            setState(() {
                rewritingMAC = true;
            });
            final res = await rewriteMAC(widget.customerId, widget.agreement);
            if (res?['detail'] != null){
                l.e('error rewriting mac: ${res['detail']}');
                if (mounted){
                    // Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка перезаписи MAC: ${res['detail']}',
                        style: const TextStyle(color: AppColors.error)
                    )));
                    setState(() {
                        rewritingMAC = false;
                    });
                }
            } else {
                if (mounted) {
                    // Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('MAC перезаписан',
                        style: TextStyle(color: AppColors.success)
                    )));
                    setState(() {
                        rewritingMAC = false;
                    });
                }
            }
        } catch (e) {
            l.e('error rewriting mac: $e');
            if (mounted){
                // Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка перезаписи MAC',
                    style: TextStyle(color: AppColors.error)
                )));
                setState(() {
                    rewritingMAC = false;
                });
            }
        }
    }

    Color _rxColor(double rx) {
        if (rx > -12) return AppColors.error;
        if (rx > -17) return AppColors.warning;
        if (rx > -25) return AppColors.success;
        if (rx > -27) return AppColors.warning;
        return AppColors.error;
    }

    Color _txColor(double tx) {
        if (tx > 10) return AppColors.error;
        if (tx > 7) return AppColors.warning;
        if (tx >= -3) return AppColors.success;
        if (tx > -8) return AppColors.warning;
        return AppColors.error;
    }

    Color _tempColor(int? temp) {
        if (temp == null) return AppColors.secondary;
        if (temp < 50) return AppColors.success;
        if (temp < 65) return AppColors.warning;
        return AppColors.error;
    }



    void _toggleCATV(int id, bool state) async {
        final bool? res = await showDialog(
            context: context,
            builder: (context){
                return CatvToggleDialog(state: state, sn: widget.sn, catvId: id, oltId: data!['olt']['id'], isCustomerActive: widget.isCustomerActive);
            }
        );
        if (res == true){
            data!['catv'][id - 1]['status'] = !state;
            setState(() {});
        }
    }

    @override
    void initState() {
        super.initState();
        _getData();
    }

    @override
    Widget build(BuildContext context) {
        Duration? uptime;
        if (data?['last_up'] == null || !data?['online']) {
            uptime = null;
        } else {
            uptime = DateTime.now().difference(DateTime.parse(data?['last_up'].replaceAll('.', '-')));
        }
        return AlertDialog(
            title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    const Row(
                        spacing: 8,
                        children: [
                            Icon(Icons.router_outlined),
                            Text(
                                'ONT / OLT',
                                style: TextStyle(fontWeight: FontWeight.w600)
                            )
                        ]
                    ),
                    Row(
                        spacing: 2,
                        children: [
                            Tooltip(
                                message: 'Перезагрузить ONT',
                                child: IconButton(
                                    onPressed: restarting || data == null || !(data?['online'] ?? false) ? null : _restartONT,
                                    icon: Icon(Icons.restart_alt, color: restarting || data == null || !(data?['online'] ?? false)? AppColors.secondary : AppColors.neo, size: 18),
                                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36)
                                )
                            ),
                            Tooltip(
                                message: 'Перезаписать SN',
                                child: IconButton(
                                    onPressed: rewritingSN || data == null || !(data?['online'] ?? false)? null : _rewriteSN,
                                    icon: Icon(Icons.save_as, color: rewritingSN || data == null || !(data?['online'] ?? false)? AppColors.secondary : AppColors.neo, size: 18),
                                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36)
                                )
                            ),
                            Tooltip(
                                message: 'Перезаписать MAC',
                                child: IconButton(
                                    onPressed: rewritingMAC || data == null || !(data?['online'] ?? false)? null : _rewriteMAC,
                                    icon: Icon(Icons.settings_ethernet, color: rewritingMAC || data == null || !(data?['online'] ?? false)? AppColors.secondary : AppColors.neo, size: 18),
                                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36)
                                )
                            ),
                            Tooltip(
                                message: 'Закрыть диалог',
                                child: IconButton(
                                    onPressed: (){
                                        Navigator.pop(context);
                                    },
                                    icon: const Icon(Icons.close, color: AppColors.error, size: 18),
                                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36)
                                )
                            )
                        ]
                    )
                ]
            ),
            content: SelectionArea(
                child: SizedBox(
                    width: 600,
                    child: data == null? const Center(child: AngularProgressBar()) : SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: 8,
                            children: [
                                if (data!['olt'] != null)
                                _Section(
                                    icon: Icons.dns_rounded,
                                    title: 'OLT',
                                    online: data!['olt']['online'],
                                    child: Column(
                                        children: [
                                            _KV('Имя', data!['olt']['name'] ?? '-'),
                                            // _KV('IP', data!['olt']['ip']),
                                            _KV('Локация', data!['olt']?['location'] ?? '-'),
                                            const SizedBox(height: 8),
                                            Row(
                                                children: [
                                                    Expanded(
                                                        child: _StatCard(
                                                            label: 'RX (dBm)',
                                                            value: data!['rx_olt']?.toStringAsFixed(2) ?? '-',
                                                            color: data!['rx_olt'] == null? AppColors.neo : _rxColor(data!['rx_olt'])
                                                        )
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                        child: _StatCard(
                                                            label: 'TX (dBm)',
                                                            value: data!['tx_olt']?.toStringAsFixed(2) ?? '-',
                                                            color: data!['tx_olt'] == null? AppColors.neo : _txColor(data!['tx_olt'])
                                                        )
                                                    ),
                                                    // const SizedBox(width: 8),
                                                    // Expanded(
                                                    //     child: _StatCard(
                                                    //         label: 'Tемпература (dBm)',
                                                    //         value: data!['temp_olt']?.toStringAsFixed(2) ?? '-',
                                                    //         color: data!['temp_olt'] == null? AppColors.neo : _txColor(data!['temp_olt'])
                                                    //     )
                                                    // ),
                                                ]
                                            )
                                        ]
                                    )
                                ),
                                _Section(
                                    icon: Icons.memory,
                                    title: 'ONT',
                                    online: data?['online'],
                                    child: Column(
                                        children: [
                                            _KV('SN', widget.sn),
                                            _KV('IP', data!['ip'] ?? '-'),
                                            // _KV('MAC', data!['mac'] ?? '-'),
                                            if (uptime != null)
                                            _KV('Аптайм', uptime.pretty(locale: DurationLocale.fromLanguageCode('ru')!, tersity: DurationTersity.minute)),
                                            if(data!['distance'] != null)
                                            _KV('Дистанция', (data!['distance'] as int).meter.toString(targetUnit: LengthUnit.kilometer).replaceAll('km', 'км')),
                                            if (data!['last_up'] != null)
                                            _KV('Последнее включение', '${FlutterDateFormatter.formatRelativeDateTime(DateTime.parse(data!['last_up'].replaceAll('.', '-')))} (${formatDate(data!['last_up'])})'),
                                            if (data!['last_down'] != null)
                                            _KV('Последнее отключение', '${FlutterDateFormatter.formatRelativeDateTime(DateTime.parse(data!['last_down'].replaceAll('.', '-')))} (${formatDate(data!['last_down'])})'),
                                            if (data!['last_down_cause'] != null)
                                            _KV('Причина отключения', data!['last_down_cause']),
                                            if (data!['ping'] != null)
                                            _KV('Пинг', data!['ping']),
                                            const SizedBox(height: 8),
                                            Row(
                                                children: [
                                                    Expanded(
                                                        child: _StatCard(
                                                            label: 'RX (dBm)',
                                                            value: data!['rx']?.toStringAsFixed(2) ?? '-',
                                                            color: data!['rx'] == null? AppColors.neo : _rxColor(data!['rx'])
                                                        )
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                        child: _StatCard(
                                                            label: 'TX (dBm)',
                                                            value: data!['tx']?.toStringAsFixed(2) ?? '-',
                                                            color: data!['tx'] == null? AppColors.neo : _txColor(data!['tx'])
                                                        )
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                        child: _StatCard(
                                                            label: 'Температура',
                                                            value: '${data!['temp']?.toStringAsFixed(0) ?? '-'}°C',
                                                            color: _tempColor(data!['temp']),
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
                                        children: [
                                            Flexible(
                                                child: _Section(
                                                    icon: Icons.tv,
                                                    title: 'CATV',
                                                    child: Wrap(
                                                        spacing: 8,
                                                        runSpacing: 4,
                                                        children: data!['catv']?.map<Widget>((e) {
                                                            return _PortTile(
                                                                label: 'Порт ${e['id']}',
                                                                up: e['actual_status'] == true,
                                                                enabled: e['status'],
                                                                detail: e['status']? 'Включен' : 'Выключен',
                                                                tooltip: 'Состояние: ${e['status'] ? "Включен" : "Выключен"}\nСтатус: ${e['actual_status']? "Онлайн" : "Оффлайн"}',
                                                                onTap: () => _toggleCATV(e['id'], e['status'])
                                                            );
                                                        }).toList() ?? [const Text('Нет CATV портов', style: TextStyle(color: AppColors.error))]
                                                    )
                                                )
                                            ),
                                            Flexible(
                                                child: _Section(
                                                    icon: Icons.lan,
                                                    title: 'ETH/LAN',
                                                    child: Wrap(
                                                        spacing: 8,
                                                        runSpacing: 8,
                                                        children: (data!['eth'] as List? ?? []).isEmpty?
                                                            [const Text('Нет ETH портов', style: TextStyle(color: AppColors.secondary))]
                                                            : (data!['eth'] as List).map<Widget>((e) {
                                                                return _PortTile(
                                                                    label: 'Порт ${e['id']}',
                                                                    up: e['actual_status'],
                                                                    enabled: e['status'],
                                                                    detail: !e['status']? 'Отключен' : e['actual_status']? '${e['speed'] ?? '-'} МБит/c - ${e['duplex'] ?? '?'}' : 'Не работает',
                                                                    tooltip: 'Состояние: ${e['status'] ? "Включен" : "Выключен"}\nСтатус: ${e['actual_status']? "Онлайн" : "Оффлайн"}'
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
                                            onPressed: restarting || data == null || !(data?['online'] ?? false)? null : _restartONT,
                                            label: restarting? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator()) : const Text('Перезагрузить ONT'),
                                            icon: restarting? null : const Icon(Icons.restart_alt)
                                        ),
                                        ElevatedButton.icon(
                                            onPressed: rewritingSN || data == null || !(data?['online'] ?? false)? null : _rewriteSN,
                                            label: rewritingSN? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator()) : const Text('Перезаписать SN'),
                                            icon: rewritingSN? null : const Icon(Icons.save_as)
                                        ),
                                        ElevatedButton.icon(
                                            onPressed: rewritingMAC || data == null || !(data?['online'] ?? false)? null : _rewriteMAC,
                                            label: rewritingMAC? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator()) : const Text('Перезаписать MAC'),
                                            icon: rewritingMAC? null : const Icon(Icons.settings_ethernet)
                                        ),
                                    ]
                                )
                            ]
                        )
                    )
                )
            ),
            // actions: [
            //     TextButton(
            //         onPressed: () => Navigator.pop(context),
            //         child: const Text('Закрыть')
            //     )
            // ]
        );
    }
}


class _Section extends StatelessWidget {
    const _Section({required this.icon, required this.title, required this.child, this.online});
    final IconData icon;
    final String title;
    final Widget child;
    final bool? online;

    @override
    Widget build(BuildContext context) {
        return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
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
                                        Icon(icon, size: 18, color: AppColors.neo),
                                        Text(title, style: const TextStyle(fontWeight: FontWeight.w600))
                                    ]
                                ),
                                if (online != null)
                                Chip(
                                    text: online!? 'ONLINE' : 'OFFLINE',
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

class _KV extends StatelessWidget {
    const _KV(this.k, this.v);
    final String k;
    final dynamic v;

    @override
    Widget build(BuildContext context) {
        return Row(
            children: [
                Text(k, style: const TextStyle(color: AppColors.secondary)),
                Expanded(child: Text('${v ?? "-"}', textAlign: TextAlign.right))
            ]
        );
    }
}

class _StatCard extends StatelessWidget {
    const _StatCard({required this.label, required this.value, this.color});
    final String label;
    final String value;
    final Color? color;

    @override
    Widget build(BuildContext context) {
        final c = color ?? Theme.of(context).colorScheme.primary;
        return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                border: Border.all(color: AppColors.main),
                borderRadius: BorderRadius.circular(10),
                color: AppColors.bg.withValues(alpha: 0.4)
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: const TextStyle(color: AppColors.secondary, fontSize: 12)),
                const SizedBox(height: 6),
                Text(value, style: TextStyle(fontWeight: FontWeight.w700, color: c)),
            ])
        );
    }
}

class _PortTile extends StatelessWidget {
    const _PortTile({
        required this.label,
        required this.up,
        required this.tooltip,
        this.enabled = true,
        this.detail,
        this.onTap
    });

    final String label;
    final bool up;
    final bool enabled;
    final String? detail;
    final String tooltip;
    final VoidCallback? onTap;

    @override
    Widget build(BuildContext context) {
        final Color color = !enabled?  AppColors.secondary: up? AppColors.success : AppColors.error;

        return Tooltip(
            message: tooltip,
            child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: onTap,
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
                                detail ?? (up? 'Включен' : 'Выключен'),
                                style: TextStyle(fontSize: 12, color: AppColors.main.withValues(alpha: 0.7))
                            )
                        ]
                    )
                )
            )
        );
    }
}
