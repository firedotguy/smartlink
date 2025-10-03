import 'package:flutter/material.dart' hide Chip;
import 'package:smartlink/api.dart';
import 'package:smartlink/dialogs/task.dart';
import 'package:smartlink/main.dart';

class TasksDialog extends StatefulWidget{
  const TasksDialog({required this.tasks, super.key});
  final List<int> tasks;

  @override
  State<TasksDialog> createState() => _TasksDialogState();
}

class _TasksDialogState extends State<TasksDialog> {
  // tasks
  List<Map<String, dynamic>> tasks = [];

  void _getTasks() async {
    tasks.clear();
    for (int task in widget.tasks){
      tasks.add(await getTask(task));
    }
    setState(() {});
  }

  void _checkCount() {
    if (widget.tasks.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Нет заданий', style: TextStyle(color: AppColors.warning))));
      Navigator.pop(context);
    } else if (widget.tasks.length == 1){ // replace to single task dialog
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context){
          return TaskDialog(taskId: widget.tasks.first);
        }
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _checkCount();
    _getTasks();
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
              Text('Задания')
            ]
          ),
          Tooltip(
            message: 'Закрыть диалог',
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close, size: 16, color: AppColors.error),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36)
            )
          )
        ]
      ),
      content: SizedBox(
        width: 550,
        child: tasks.isEmpty? const Center(child: AngularProgressBar()) : ListView.builder(
          shrinkWrap: true,
          itemCount: tasks.length,
          itemBuilder: (c, i) {
            final task = tasks[i]['data'];

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.assignment_outlined, color: AppColors.neo),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.secondary),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        task['type']?['name'] ?? '-',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis
                      )
                    ),
                    Chip(
                      text: task['status']?['name'] ?? '-',
                      color: getTaskStatusColor(task['status']?['id'])
                    )
                  ]
                ),
                subtitle: Text.rich(
                  TextSpan(
                    style: const TextStyle(fontSize: 12, color: AppColors.secondary),
                    children: [
                      TextSpan(text: 'ID: ${task['id'] ?? '-'}'),
                      const TextSpan(text: '  •  '),
                      TextSpan(text: 'Создано: ${formatDate(task['timestamps']?['created_at'])}'),
                      if (task['timestamps']?['completed_at'] != null) ...[
                      const TextSpan(text: '  •  '),
                      TextSpan(text: 'Выполнено: ${formatDate(task['timestamps']?['completed_at'])}')
                      ],
                      const TextSpan(text: '  •  '),
                      TextSpan(text: 'Автор: ${task['author_id'] ?? '-'}')
                    ]
                  )
                ),
                onTap: () {
                  // Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (_) => TaskDialog(taskId: task['id'])
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              )
            );
          }
        )
      )
    );
  }
}
