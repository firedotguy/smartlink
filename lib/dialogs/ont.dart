import 'package:flutter/material.dart' hide Chip;
import 'package:smartlink/api.dart';
import 'package:smartlink/dialogs/catvtoggle.dart';
import 'package:smartlink/main.dart';

class OntDialog extends StatefulWidget {
  const OntDialog({required this.oltId, required this.sn, required this.customerId, required this.ls, this.isCustomerActive = true, super.key});
  final int oltId;
  final String sn;
  final int customerId;
  final int ls;
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
    try{
      data = await getOnt(widget.oltId, widget.sn);
      setState(() {});
    } catch (e) {
      l.e('error getting ont data: $e');
      if (mounted){
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка получения данных ONT', style: TextStyle(color: AppColors.error))));
      }
    }
  }

  void _restartONT() async {
    if (restarting) return;
    try {
      setState(() {
        restarting = true;
      });
      final String? res = await restartOnt(data!['data']['ont_id'], data!['olt']['host'], data!['data']['interface']);
      if (res != null) {
        l.e('error restarting ont: $res');
        if (mounted){
          // Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка перезапуска ONT: $res', style: const TextStyle(color: AppColors.error))));
        }
      }
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
      final Map res = await rewriteSN(widget.sn, widget.customerId, widget.ls);
      if (res['status'] == 'fail'){
        l.e('error rewritingSN sn: ${res['detail']}');
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('SN перезаписан: ${res['message']}',
            style: const TextStyle(color: AppColors.success)
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
      final Map res = await rewriteMAC(widget.customerId, widget.ls);
      if (res['status'] == 'fail'){
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('MAC перезаписан: ${res['message']}',
            style: const TextStyle(color: AppColors.success)
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
    if (rx > -25) return AppColors.success;
    if (rx > -27) return AppColors.warning;
    return AppColors.error;
  }

  Color _txColor(double tx) {
    if (tx > 7) return AppColors.warning; // overload
    if (tx >= -3) return AppColors.success;
    if (tx > -8) return AppColors.warning;
    return AppColors.error;
  }

  Color _tempColor(int temp) {
    if (temp < 50) return AppColors.success;
    if (temp < 65) return AppColors.warning;
    return AppColors.error;
  }

  void _toggleCATV(int id, bool state) async {
    final bool? res = await showDialog(
      context: context,
      builder: (context){
        return CatvToggleDialog(state: state, interface: data!['data']['interface'], ontID: data!['data']['ont_id'], catvID: id, host: data!['olt']['host'], isCustomerActive: widget.isCustomerActive);
      }
    );
    if (res == true){
      data!['data']['catv'][id - 1] = !state;
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
                  onPressed: restarting || data == null || !data?['data']?['online']? null : _restartONT,
                  icon: Icon(Icons.restart_alt, color: restarting || data == null || !data?['data']?['online']? AppColors.secondary : AppColors.neo, size: 18),
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36)
                )
              ),
              Tooltip(
                message: 'Перезаписать SN',
                child: IconButton(
                  onPressed: rewritingSN || data == null || !data?['data']?['online']? null : _rewriteSN,
                  icon: Icon(Icons.save_as, color: rewritingSN || data == null || !data?['data']?['online']? AppColors.secondary : AppColors.neo, size: 18),
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36)
                )
              ),
              Tooltip(
                message: 'Перезаписать MAC',
                child: IconButton(
                  onPressed: rewritingMAC || data == null || !data?['data']?['online']? null : _rewriteMAC,
                  icon: Icon(Icons.settings_ethernet, color: rewritingMAC || data == null || !data?['data']?['online']? AppColors.secondary : AppColors.neo, size: 18),
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
          child: data == null? const Center(child: AngularProgressBar()) :
          !data!.containsKey('data')? const Center(child: Text('У абонента нет коммутации', style: TextStyle(color: AppColors.error))) : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                _Section(
                  icon: Icons.dns_rounded,
                  title: 'OLT',
                  online: data!['olt']['online'],
                  child: Column(
                    children: [
                      _KV('Имя', data!['olt']['name'] ?? '-'),
                      _KV('Девайс', data!['olt']['device'] ?? '-'),
                      // _KV('IP', data!['olt']['ip']),
                      _KV('Локация', data!['olt']?['location'] ?? '-')
                    ]
                  )
                ),
                _Section(
                  icon: Icons.memory,
                  title: 'ONT',
                  online: data?['data']?['online'],
                  child: data?['data'] == null?
                    const Text('ONT не найден', style: TextStyle(color: AppColors.error)) : data?['data']?['error'] != null?
                    Text('Ошибка подключения к OLT: ${data!['data']?['error']}', style: const TextStyle(color: AppColors.error)) :
                  Column(
                    children: [
                      _KV('SN', data!['sn'] ?? '-'),
                      _KV('Интерфейс', data!['data']['interface']?['name'] ?? '-'),
                      _KV('ONT ID', data!['data']['ont_id'] ?? '-'),
                      _KV('IP', data!['data']['ip'] ?? '-'),
                      _KV('MAC', data!['data']['mac'] ?? '-'),
                      _KV('Аптайм', data!['data']?['uptime'] == null? '-' : '${data!['data']['uptime']['days']} дней ${data!['data']['uptime']['hours'].toString().padLeft(2, '0')}:${data!['data']['uptime']['minutes'].toString().padLeft(2, '0')}:${data!['data']['uptime']['seconds'].toString().padLeft(2, '0')}'),
                      Row(
                        spacing: 8,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (data!['data']?['ping'] != null)
                          Chip(
                            icon: Icons.speed,
                            text: 'Ping ${data!['data']['ping'].toStringAsFixed(1)} ms',
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
                          ),
                          if ((data!['data']?['last_down_cause'] ?? '').isNotEmpty && data!['data']['last_down'] != null)
                          Chip(
                            icon: Icons.report_gmailerrorred,
                            text: 'Last down: ${data!['data']['last_down_cause']} (${formatDate(data!['data']['last_down'])})',
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
                          ),
                          if ((data!['data']?['last_down_cause'] ?? '').isNotEmpty && data!['data']['last_down'] == null)
                          Chip(
                            icon: Icons.report_gmailerrorred,
                            text: 'Last down: ${data!['data']['last_down_cause']}',
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
                          )
                        ]
                      )
                    ]
                  )
                ),
                _Section(
                  icon: Icons.wifi_tethering,
                  title: 'Оптические параметры',
                  child: data!['data']?['optical'] == null?
                    const Text('Нет оптических параметров', style: TextStyle(color: AppColors.error)) : Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'RX (dBm)',
                          value: data!['data']?['optical']?['rx']?.toStringAsFixed(2) ?? '-',
                          color: data!['data']?['optical']?['rx'] == null? AppColors.neo : _rxColor(data!['data']['optical']['rx'])
                        )
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatCard(
                          label: 'TX (dBm)',
                          value: data!['data']?['optical']?['tx']?.toStringAsFixed(2) ?? '-',
                          color: data!['data']?['optical']?['tx'] == null? AppColors.neo : _txColor(data!['data']['optical']['tx'])
                        )
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatCard(
                          label: 'ONT T°',
                          value: '${data!['data']?['optical']?['temp']?.toStringAsFixed(0) ?? '-'}°C',
                          color: _tempColor(data!['data']?['optical']?['temp']),
                        )
                      )
                    ]
                  )
                ),
                Row(
                  spacing: 4,
                  children: [
                    Flexible(
                      child: _Section(
                        icon: Icons.tv,
                        title: 'CATV',
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: data!['data']?['catv']?.asMap().entries.map((e) => (e.key + 1, e.value)).map<Widget>((e) {
                            return Chip(
                              icon: Icons.circle,
                              text: 'Port ${e.$1}: ${e.$2 ?? false? "Вкл" : "Выкл"}',
                              color: e.$2 ?? false? AppColors.success : AppColors.error,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              iconTooltip: e.$2 ?? false? 'Выключить CATV' : 'Включить CATV',
                              onIconTap: () => _toggleCATV(e.$1, e.$2),
                            );
                          }).toList() ?? [const Text('Нет CATV портов', style: TextStyle(color: AppColors.error))]
                        )
                      ),
                    ),
                    Flexible(
                      child: _Section(
                        icon: Icons.lan,
                        title: 'ETH/LAN',
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: data!['data']?['eth']?.map<Widget>((e) {
                            return Chip(
                              icon: Icons.circle,
                              text: 'Port ${e['id']}: ${e['status'] ?? false? "Up" : "Down"}${e['speed'] != null? ' (${e['speed']} Mbps)' : ''}',
                              color: e['status'] ?? false? AppColors.success : AppColors.error,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            );
                          }).toList() ?? [const Text('Нет ETH портов', style: TextStyle(color: AppColors.error))]
                        )
                      ),
                    )
                  ]
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: restarting || data == null || !data?['data']?['online']? null : _restartONT,
                      label: restarting? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator()) : const Text('Перезагрузить ONT'),
                      icon: restarting? null : const Icon(Icons.restart_alt)
                    ),
                    ElevatedButton.icon(
                      onPressed: rewritingSN || data == null || !data?['data']?['online']? null : _rewriteSN,
                      label: rewritingSN? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator()) : const Text('Перезаписать SN'),
                      icon: rewritingSN? null : const Icon(Icons.save_as)
                    ),
                    ElevatedButton.icon(
                      onPressed: rewritingMAC || data == null || !data?['data']?['online']? null : _rewriteMAC,
                      label: rewritingMAC? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator()) : const Text('Перезаписать MAC'),
                      icon: rewritingMAC? null : const Icon(Icons.settings_ethernet)
                    ),
                  ]
                )
              ]
            )
          )
        ),
      ),
      // actions: [
      //   TextButton(
      //     onPressed: () => Navigator.pop(context),
      //     child: const Text('Закрыть')
      //   )
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
        borderRadius: BorderRadius.circular(10)
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: AppColors.secondary, fontSize: 12)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontWeight: FontWeight.w700, color: c))
      ])
    );
  }
}


