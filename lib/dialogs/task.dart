import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartlink/api.dart';
import 'package:smartlink/main.dart';
import 'package:url_launcher/url_launcher.dart';

class TaskDialog extends StatefulWidget {
  const TaskDialog({required this.taskId, super.key});
  final int taskId;

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  Map<String, dynamic>? task;
  bool load = true;
  bool loadSend = false;
  int? employeeId;
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  DateTime _toDateTime(dynamic v) {
    if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
    if (v is DateTime) return v;
    if (v is String) return DateTime.parse(v);
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  String _formatTime(dynamic v) {
    final d = _toDateTime(v).toLocal();
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    if (d.year == 1970) return '';
    return '$hh:$mm';
  }

  Future<void> _load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    employeeId = prefs.getInt('userId');
    try {
      final data = await getTask(widget.taskId);
      setState(() {
        task = data['data'];
        load = false;
      });
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки задания: $e', style: const TextStyle(color: AppColors.error)))
      );
    }
  }

  Future<void> _openUrl(link) async {
    final url = Uri.parse(link);
    if (await canLaunchUrl(url)) {
      l.i('open link: $link');
      await launchUrl(url, mode: kIsWeb? LaunchMode.platformDefault : LaunchMode.externalApplication);
    } else {
      l.e('unclickable link: $link');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка открытия ссылки: Ссылка некликабельна', style: TextStyle(color: AppColors.error)))
        );
      }
    }
  }

  Future<void> _send() async {
    final text = commentController.text.trim();
    if (text.isEmpty || loadSend) return;
    setState(() => loadSend = true);
    try {
      final String content = commentController.text;
      commentController.clear();
      await addComent(task!['id'], content, employeeId ?? 0);
      task!['comments'].add({'id': 0, 'content': content, 'author_id': employeeId, 'created_at': DateTime.now()});
    } catch (e) {
      l.e('error adding comment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка отправки комментария: $e', style: const TextStyle(color: AppColors.error)))
        );
      }
    } finally {
      if (mounted) setState(() => loadSend = false);
    }
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
              Icon(Icons.assignment_outlined),
              Text('Задание')
            ]
          ),
          Row(
            spacing: 4,
            children: [
              Tooltip(
                message: 'Скопировать ссылку на задание в UserSide',
                child: IconButton(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: 'https://us.neotelecom.kg/task/${widget.taskId}'));
                    if (context.mounted){
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ссылка скопирована', style: TextStyle(color: AppColors.success)))
                      );
                    }
                  },
                  icon: const Icon(Icons.copy, size: 16, color: AppColors.neo),
                  splashRadius: 14
                )
              ),
              Tooltip(
                message: 'Открыть в UserSide',
                child: IconButton(
                  onPressed: () async {
                    await _openUrl('https://us.neotelecom.kg/task/${widget.taskId}');
                  },
                  icon: const Icon(Icons.open_in_new, size: 16, color: AppColors.neo),
                  splashRadius: 14
                )
              ),
              Tooltip(
                message: 'Закрыть диалог',
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close, size: 16, color: AppColors.error),
                  splashRadius: 14
                )
              )
            ]
          )
        ]
      ),
      content: SizedBox(
        width: 640,
        child: load? const Center(child: AngularProgressBar()) : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _KV('Тип', task?['type']?['name']),
              _KV('Адрес', task?['address']),
              _KV('Клиент', task?['customer']?.toString()),
              _KV('Автор', task?['author_id']?.toString()),
              const SizedBox(height: 8),
              _Section(
                title: 'Детали',
                child: Column(
                  children: [
                    if (task?['addata']?['reason'] != null)
                    _KV('Причина', task!['addata']['reason']),

                    if (task?['addata']?['solve'] != null)
                    _KV('Решение', task!['addata']['solve']),

                    if (task?['addata']?['appeal']?['phone'] != null)
                    _KV('Телефон обратившегося', task!['addata']['appeal']['phone']),

                    if (task?['addata']?['appeal']?['type'] != null)
                    _KV('Тип обращения', task!['addata']['appeal']['type']),

                    if (task?['addata']?['cost'] != null)
                    _KV('Стоимость работ', task!['addata']['cost']),

                    if (task?['addata']?['info'] != null)
                    _KV('Суть обращения', task!['addata']['info']),

                    if (task?['addata']?['tariff'] != null)
                    _KV('Тариф', task!['addata']['tariff']),

                    if (task?['addata']?['coord'] != null)
                    _KV('Коордианты', task!['addata']['coord'].join(',')),

                    if (task?['addata']?['connect_type'] != null)
                    _KV('Тип подключения', task!['addata']['connect_type']),

                    const Divider(),
                    _KV('Создано', formatDate(task?['timestamps']?['created_at'])),
                    _KV('Запланировано', formatDate(task?['timestamps']?['planned_at'])),
                    _KV('Обновлено', formatDate(task?['timestamps']?['updated_at'])),
                    // _KV('Дедлайн (ч)', task?['timestamps']?['deadline']?.toString())
                  ]
                )
              ),
              const SizedBox(height: 8),
              _Section(
                title: 'Комментарии',
                child: (task?['comments'] ?? []).isEmpty? const Align(
                  alignment: Alignment.topCenter,
                  child: Text('Комментариев нет', style: TextStyle(color: Colors.grey)),
                ) : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: task!['comments'].length,
                  itemBuilder: (_, i) {
                    final message = task!['comments'][i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Align(
                        alignment: employeeId != message!['author_id']? Alignment.topLeft : Alignment.topRight,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                          decoration: BoxDecoration(
                            color: employeeId != message['author_id']? AppColors.bg2 : AppColors.neo,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.04))
                          ),
                          child: IntrinsicWidth(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 4,
                              children: [
                                if (employeeId != message['author_id'] && message['author_id'] != null)
                                Text(message['author_id'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(message['content']),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    _formatTime(message['created_at']),
                                    style: TextStyle(color: employeeId != message['author_id']? AppColors.secondary : AppColors.main, fontSize: 10)
                                  )
                                )
                              ],
                            ),
                          )
                        )
                      ),
                    );
                  }
                )
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Написать комментарий...',
                        isDense: true,
                        border: OutlineInputBorder()
                      )
                    )
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _send,
                    icon: loadSend? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator()) : const Icon(Icons.send, size: 18),
                    label: const Text('Отправить')
                  )
                ]
              )
            ]
          )
        )
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Закрыть'))
      ]
    );
  }
}

class _KV extends StatelessWidget {
  const _KV(this.k, this.v);
  final String k;
  final dynamic v;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(k, style: const TextStyle(color: AppColors.secondary))),
          Flexible(child: Text('${v ?? "-"}', textAlign: TextAlign.right))
        ]
      )
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200)
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            child
          ]
        )
      )
    );
  }
}
