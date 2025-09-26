import 'package:flutter/material.dart';
import 'package:smartlink/api.dart';
import 'package:smartlink/main.dart';

class OntDialog extends StatefulWidget {
  const OntDialog({required this.oltId, required this.sn, super.key});
  final int oltId;
  final String sn;

  @override
  State<OntDialog> createState() => _OntDialogState();
}

class _OntDialogState extends State<OntDialog> {
  Map? data;
  bool restarting = false;

  void getData() async {
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
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка перезапуска ONT: $res', style: const TextStyle(color: AppColors.error))));
        }
      }
      setState(() {
        restarting = false;
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ONT перезапущен', style: TextStyle(color: AppColors.success))));
      }
    } catch (e) {
      setState(() {
        restarting = false;
      });
      l.e('error restarting ont: $e');
      if (mounted){
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка перезапуска ONT', style: TextStyle(color: AppColors.error))));
      }
    }
  }

  Color _statusColor(String? s) {
    switch (s) {
      case 'online': return AppColors.success;
      case 'offline': return AppColors.error;
      default: return Colors.grey;
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

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: SelectionArea(
        child: Row(
          children: [
            const Icon(Icons.router_outlined),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'ONT / OLT',
                style: TextStyle(fontWeight: FontWeight.w600)
              )
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor(data?['data']?['status']).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _statusColor(data?['data']?['status']))
              ),
              child: Text(data?['data']?['status']?.toUpperCase() ?? 'Загрузка',
                style: TextStyle(color: _statusColor(data?['data']?['status']), fontWeight: FontWeight.w600, fontSize: 12)
              )
            )
          ]
        ),
      ),
      content: SizedBox(
        width: 600,
        child: data == null? const Center(child: AngularProgressBar()) :
        !data!.containsKey('data')? const Center(child: Text('У абонента нет коммутации', style: TextStyle(color: AppColors.error))) : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10,
            children: [
              _Section(
                icon: Icons.dns_rounded,
                title: 'OLT',
                child: Column(
                  children: [
                    _KV('Имя', data!['olt']['name'] ?? '-'),
                    _KV('Девайс', data!['olt']['device'] ?? '-'),
                    // _KV('IP', data!['olt']['ip']),
                    _KV('Локация', data!['olt']?['location'] ?? '-'),
                  ]
                )
              ),
              _Section(
                icon: Icons.memory,
                title: 'ONT',
                child: data?['data'] == null?
                const Text('ONT не найден', style: TextStyle(color: AppColors.error)) : data?['data']?['error'] != null?
                Text('Ошибка подключения к OLT: ${data!['data']?['error']}', style: const TextStyle(color: AppColors.error)) :
                Column(
                  children: [
                    _KV('SN', data!['sn'] ?? '-'),
                    _KV('IP', data!['data']['ip'] ?? '-'),
                    _KV('ONT ID', data!['data']['ont_id'] ?? '-'),
                    _KV('Интерфейс', data!['data']['interface']?['name'] ?? '-'),
                    Row(
                      spacing: 8,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (data!['data']?['ping'] != null)
                        _Chip(icon: Icons.speed, text: 'Ping ${data!['data']['ping'].toStringAsFixed(1)} ms'),
                        if ((data!['data']?['last_down_cause'] ?? '').isNotEmpty && data!['data']['last_down'] != null)
                        _Chip(icon: Icons.report_gmailerrorred, text: 'Last down: ${data!['data']['last_down_cause']} (${data!['data']['last_down']})'),
                        if ((data!['data']?['last_down_cause'] ?? '').isNotEmpty && data!['data']['last_down'] == null)
                        _Chip(icon: Icons.report_gmailerrorred, text: 'Last down: ${data!['data']['last_down_cause']}')
                      ]
                    ),
                    const SizedBox(height: 8),
                    _KV('Аптайм', data!['data']?['uptime'] == null? '-' : '${data!['data']['uptime']['days']} дней ${data!['data']['uptime']['hours'].toString().padLeft(2, '0')}:${data!['data']['uptime']['minutes'].toString().padLeft(2, '0')}:${data!['data']['uptime']['seconds'].toString().padLeft(2, '0')}')
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
                        value: '${data!['data']?['optical']?['temp']?.toStringAsFixed(0) ?? '-'}°C'
                      )
                    )
                  ]
                )
              ),
              _Section(
                icon: Icons.tv,
                title: 'CATV',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Chip(
                      icon: Icons.circle,
                      text: 'Port 1: ${data!['data']?['catv']?[0] ?? false? "Вкл" : "Выкл"}',
                      color: data!['data']?['catv']?[0] ?? false? AppColors.success : AppColors.error
                    ),
                    _Chip(
                      icon: Icons.circle,
                      text: 'Port 2: ${data!['data']?['catv']?[1] ?? false? "Вкл" : "Выкл"}',
                      color: data!['data']?['catv']?[1] ?? false? AppColors.success : AppColors.error
                    )
                  ]
                )
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 200,
                    child: ElevatedButton.icon(
                      onPressed: _restartONT,
                      label: restarting? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator()) : const Text('Перезагрузить ONT'),
                      icon: restarting? null : const Icon(Icons.restart_alt),
                    ),
                  ),
                  // more buttons soon
                ],
              )
            ]
          )
        )
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Закрыть')
        )
      ]
    );
  }
}


class _Section extends StatelessWidget {
  const _Section({required this.icon, required this.title, required this.child});
  final IconData icon;
  final String title;
  final Widget child;

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
              spacing: 4,
              children: [
                Icon(icon, size: 18, color: AppColors.neo),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600))
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

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.text, this.color});
  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.neo;
    return Container(
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: c.withValues(alpha: .45))
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: c),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w600))
      ])
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
