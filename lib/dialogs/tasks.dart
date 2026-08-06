import 'package:flutter/material.dart';
import 'package:smartlink/api.dart';
import 'package:smartlink/dialogs/task.dart';
import 'package:smartlink/i18n.dart';
import 'package:smartlink/theme.dart';
import 'package:smartlink/utils.dart';
import 'package:smartlink/widgets/angular_progress_bar.dart';
import 'package:smartlink/widgets/app_chip.dart';
import 'package:smartlink/widgets/dialog_header.dart';

/// Список заданий: открывается, когда у объекта их несколько.
class TasksDialog extends StatefulWidget {
    const TasksDialog({required this.tasks, super.key});
    final List<int> tasks;

    @override
    State<TasksDialog> createState() => _TasksDialogState();
}

class _TasksDialogState extends State<TasksDialog> {
    List<Map<String, dynamic>> tasks = [];

    @override
    void initState() {
        super.initState();
        _check_count();
        _load();
    }

    /// Пустой список закрывает диалог, единственное задание открывается напрямую.
    void _check_count() {
        if (widget.tasks.isEmpty){
            show_warning(context, t.tasks.empty);
            Navigator.pop(context);
            return;
        }

        if (widget.tasks.length == 1){
            Navigator.pop(context);
            showDialog(
                context: context,
                builder: (context) => TaskDialog(id: widget.tasks.first)
            );
        }
    }

    Future<void> _load() async {
        tasks.clear();
        for (final int id in widget.tasks){
            tasks.add(await get_task(id));
        }
        if (mounted) setState(() {});
    }

    Widget _task_card(Map<String, dynamic> task) {
        return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
                leading: const Icon(Icons.assignment_outlined, color: AppColors.neo),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: AppColors.secondary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        Expanded(
                            child: Text(
                                task['type']?['name'] ?? t.common.empty,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis
                            )
                        ),
                        AppChip(
                            text: task['status']?['name'] ?? t.common.empty,
                            color: get_task_status_color(task['status']?['id'])
                        )
                    ]
                ),
                subtitle: Text.rich(
                    TextSpan(
                        style: const TextStyle(fontSize: 12, color: AppColors.secondary),
                        children: [
                            TextSpan(text: t.tasks.id('${task['id'] ?? t.common.empty}')),
                            const TextSpan(text: '    •    '),
                            TextSpan(text: t.tasks.created(format_date(task['created_at']))),
                            if (task['completed_at'] != null) ...[
                                const TextSpan(text: '    •    '),
                                TextSpan(text: t.tasks.completed(format_date(task['completed_at'])))
                            ],
                            const TextSpan(text: '    •    '),
                            TextSpan(text: t.tasks.author(cut_last_name(task['author']?['name']) ?? t.common.empty))
                        ]
                    )
                ),
                onTap: () => showDialog(
                    context: context,
                    builder: (context) => TaskDialog(task: task)
                )
            )
        );
    }

    @override
    Widget build(BuildContext context) {
        return AlertDialog(
            title: DialogHeader(title: t.tasks.title, icon: Icons.assignment_outlined),
            content: SizedBox(
                width: 600,
                child: tasks.isEmpty? const Center(child: AngularProgressBar()) : SelectionArea(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: tasks.length,
                        itemBuilder: (context, index) => _task_card(tasks[index])
                    )
                )
            )
        );
    }
}
