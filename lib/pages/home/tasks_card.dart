import 'package:flutter/material.dart';
import 'package:smartlink/i18n.dart';
import 'package:smartlink/theme.dart';
import 'package:smartlink/utils.dart';
import 'package:smartlink/widgets/angular_progress_bar.dart';
import 'package:smartlink/widgets/data_card.dart';
import 'package:smartlink/widgets/icon_action.dart';
import 'package:smartlink/widgets/table_header.dart';

/// Карточка «Задания абонента».
class TasksCard extends StatelessWidget {
    const TasksCard({
        required this.tasks,
        required this.on_refresh,
        required this.on_open_task,
        super.key
    });
    final List<Map>? tasks;
    final VoidCallback on_refresh;
    final void Function(Map task) on_open_task;

    @override
    Widget build(BuildContext context) {
        return DataCard(
            line_color: get_task_border_color(tasks),
            icon: Icons.assignment,
            title: t.tasksCard.title,
            flex: 3,
            last: true,
            mini_buttons: [
                IconAction(
                    tooltip: t.common.refresh,
                    icon: Icons.refresh,
                    on_pressed: tasks != null? on_refresh : null
                )
            ],
            child: tasks == null? const Center(child: AngularProgressBar()) : Column(
                children: [
                    if (tasks!.isEmpty)
                    Center(child: Text(t.tasksCard.empty, style: const TextStyle(color: AppColors.secondary)))
                    else ...[
                        TableHeader(columns: [
                            TableColumn(3, t.tasksCard.column_id),
                            TableColumn(7, t.tasksCard.column_type, align: TextAlign.center),
                            TableColumn(6, t.tasksCard.column_created, align: TextAlign.center),
                            TableColumn(5, t.tasksCard.column_status, align: TextAlign.center),
                            const TableColumn(2, null) // место под кнопку «открыть»
                        ]),
                        Expanded(
                            child: ListView.builder(
                                itemCount: tasks!.length,
                                itemBuilder: (context, index) => _task_row(tasks![index])
                            )
                        )
                    ]
                ]
            )
        );
    }

    Widget _task_row(Map task) {
        final int? status_id = task['status']?['id'];

        return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
                children: [
                    Expanded(
                        flex: 3,
                        child: Text(task['id'].toString(), style: const TextStyle(fontSize: 13))
                    ),
                    Expanded(
                        flex: 7,
                        child: Text(task['type']?['name'] ?? t.common.empty, softWrap: true)
                    ),
                    Expanded(
                        flex: 6,
                        child: Text(
                            format_date(task['created_at']),
                            softWrap: true,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: get_task_date_color(task['created_at'], status_id), fontSize: 13)
                        )
                    ),
                    Expanded(
                        flex: 5,
                        child: Text(
                            task['status']?['name'] ?? t.common.empty,
                            softWrap: true,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: get_task_status_color(status_id))
                        )
                    ),
                    Flexible(
                        flex: 2,
                        child: IconButton(
                            onPressed: () => on_open_task(task),
                            icon: const Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.neo)
                        )
                    )
                ]
            )
        );
    }
}
