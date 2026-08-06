import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartlink/api.dart';
import 'package:smartlink/main.dart';
import 'package:url_launcher/url_launcher.dart';

class TaskDialog extends StatefulWidget {
    const TaskDialog({this.task, this.id, super.key});
    final Map<String, dynamic>? task;
    final int? id;

    @override
    State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
    Map<String, dynamic>? task;
    bool load = true;
    bool sending = false;
    int? employeeId;
    final TextEditingController commentController = TextEditingController();

    Future<void> _load() async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        employeeId = prefs.getInt('userId');
        if (task == null){
            try {
                final data = await getTask(widget.id!);
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
        } else {
            setState(() {
                load = false;
            });
        }
    }

    Future<void> _openUrl(String link) async {
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

    Future<void> _addComment() async {
        final text = commentController.text.trim();
        if (text.isEmpty || sending) return;
        setState(() => sending = true);
        try {
            final String content = commentController.text;
            commentController.clear();
            final id = await addComment(task!['id'], content);
            task!['comments'].add({'id': id, 'content': content, 'author': {'id': employeeId, 'name': null}, 'created_at': null});
        } catch (e) {
            l.e('error adding comment: $e');
            if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ошибка отправки комментария: $e', style: const TextStyle(color: AppColors.error)))
                );
            }
        } finally {
            if (mounted) setState(() => sending = false);
        }
    }

    @override
    void initState() {
        super.initState();
        task = widget.task;
        _load();
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
                                        await Clipboard.setData(ClipboardData(text: 'https://us.neotelecom.kg/task/${widget.id ?? task!['id']}'));
                                        if (context.mounted){
                                            ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Ссылка скопирована', style: TextStyle(color: AppColors.success)))
                                            );
                                        }
                                    },
                                    icon: const Icon(Icons.copy, size: 18, color: AppColors.neo),
                                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36)
                                )
                            ),
                            Tooltip(
                                message: 'Открыть в UserSide',
                                child: IconButton(
                                    onPressed: () async {
                                        await _openUrl('https://us.neotelecom.kg/task/${widget.id ?? task!['id']}');
                                    },
                                    icon: const Icon(Icons.open_in_browser, size: 18, color: AppColors.neo),
                                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36)
                                )
                            ),
                            Tooltip(
                                message: 'Закрыть диалог',
                                child: IconButton(
                                    onPressed: () {
                                        Navigator.pop(context);
                                    },
                                    icon: const Icon(Icons.close, size: 18, color: AppColors.error),
                                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36)
                                )
                            )
                        ]
                    )
                ]
            ),
            content: SizedBox(
                width: 640,
                child: load? const Center(child: AngularProgressBar()) : SingleChildScrollView(
                    child: SelectionArea(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                _Section(
                                    title: 'Основные данные',
                                    child: Column(
                                        children: [
                                            _KV('Тип', task?['type']?['name']),
                                            _KV('Статус', Text(task?['status']['name'], style: TextStyle(color: getTaskStatusColor(task!['status']['id'] ?? 0)))),
                                            _KV('Адрес', task?['address']?['label']),
                                            // _KV('Абонент', task?['customer_id']?.toString()),
                                            _KV('Автор задания', task?['author']['name']),
                                            if (task?['employees'].isNotEmpty)
                                            _KV('Назначенные сотрудники', task?['employees'].map((e) => e['name']).toList().join(', ')),
                                            if (task?['divisions'].isNotEmpty)
                                            _KV('Назначенные бригады', task?['divisions'].map((e) => e['name']).toList().join(', ')),
                                            const Divider(),
                                            if (task?['appeal_reason'] != null)
                                            _KV('Причина', task!['appeal_reason']),

                                            if (task?['solve'] != null)
                                            _KV('Решение', task!['solve']),

                                            if (task?['appeal_phone'] != null)
                                            _KV(
                                                'Телефон обратившегося',
                                                Row(
                                                    children: [
                                                        const Icon(Icons.phone, size: 18, color: AppColors.neo),
                                                        const SizedBox(width: 8),
                                                        Text(task!['appeal_phone'].toString())
                                                    ]
                                                )
                                            ),

                                            if (task?['appeal_type'] != null)
                                            _KV('Тип обращения', task!['appeal_type']),

                                            if (task?['price'] != null)
                                            _KV('Стоимость работ', '${task!['price'].round()} сом'),

                                            // if (task?['addata']?['info'] != null)
                                            // _KV('Суть обращения', task!['addata']['info']),

                                            if (task?['tariff'] != null)
                                            _KV('Тариф', task!['tariff']),

                                            if (task?['coordinates'] != null)
                                            _KV('Коордианты', task!['coordinates'].join(', ')),

                                            if (task?['connect_type'] != null)
                                            _KV('Тип подключения', task!['connect_type']),

                                            const Divider(),
                                            _KV('Дата создания', formatDate(task?['created_at'])),
                                            _KV('Дата обновления', formatDate(task?['updated_at'])),
                                            _KV('Плановая дата выполнения', formatDate(task?['planned_to'])),
                                            _KV('Дата выполнения', formatDate(task?['completed_at'])),

                                            // _KV('Дедлайн (ч)', task?['deadline']?.toString())
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
                                            final isMine = employeeId == message['author']?['id'];
                                            return Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 4),
                                                child: Align(
                                                    alignment: !isMine? Alignment.topLeft : Alignment.topRight,
                                                    child: Container(
                                                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                                                        decoration: BoxDecoration(
                                                            color: !isMine? AppColors.bg : AppColors.neo,
                                                            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(isMine? 12 : 0), bottomRight: Radius.circular(isMine? 0 : 12), topLeft: const Radius.circular(12), topRight: const Radius.circular(12)),
                                                            border: Border.all(color: Colors.white.withValues(alpha: 0.04))
                                                        ),
                                                        child: IntrinsicWidth(
                                                            child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                spacing: 4,
                                                                children: [
                                                                    if (!isMine && message['author']?['id'] != null)
                                                                    Text(message['author']['name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                                                                    Text(message['content']),
                                                                    Align(
                                                                        alignment: Alignment.bottomRight,
                                                                        child: Text(
                                                                            message['created_at'] == null? 'только что' : formatDate(message['created_at']),
                                                                            style: const TextStyle(fontSize: 11)
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
                                                ),
                                                onSubmitted: (v) => _addComment,
                                            )
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton.icon(
                                            onPressed: _addComment,
                                            icon: sending? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator()) : const Icon(Icons.send, size: 18),
                                            label: const Text('Отправить')
                                        )
                                    ]
                                )
                            ]
                        ),
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
                    if (v is String)
                    Flexible(child: Text('${v ?? "-"}', textAlign: TextAlign.right))
                    else
                    v
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
