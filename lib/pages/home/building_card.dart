import 'package:flutter/material.dart';
import 'package:smartlink/i18n.dart';
import 'package:smartlink/theme.dart';
import 'package:smartlink/utils.dart';
import 'package:smartlink/widgets/angular_progress_bar.dart';
import 'package:smartlink/widgets/data_card.dart';
import 'package:smartlink/widgets/icon_action.dart';
import 'package:smartlink/widgets/info_tile.dart';
import 'package:smartlink/widgets/sub_heading.dart';
import 'package:smartlink/widgets/table_header.dart';

/// Карточка «Коробка» со списком соседей.
class BuildingCard extends StatelessWidget {
    const BuildingCard({
        required this.building,
        required this.not_found,
        required this.on_refresh,
        required this.on_new_task,
        required this.on_open_tasks,
        super.key
    });
    final Map? building;

    /// Коробка не найдена — данные загружены, но их нет.
    final bool not_found;

    final VoidCallback on_refresh;
    final VoidCallback on_new_task;

    /// Открывает список заданий коробки.
    final void Function(List<int> ids) on_open_tasks;

    String _map_url() {
        return '$userside_host/map/show?opt_wh=1&by_building=${building!['building_id']}'
            '&is_show_center_marker=1';
    }

    @override
    Widget build(BuildContext context) {
        final List? tasks = building?['tasks'];

        return DataCard(
            line_color: get_building_border_color(building?['customers']),
            icon: Icons.dns,
            title: t.building.title,
            mini_buttons: [
                IconAction(
                    tooltip: t.building.new_task_tooltip,
                    icon: Icons.assignment_add,
                    on_pressed: building != null? on_new_task : null
                ),
                IconAction(
                    tooltip: t.building.show_on_map,
                    icon: Icons.map,
                    on_pressed: building?['coordinates'] != null? () => open_url(context, _map_url()) : null
                ),
                IconAction(
                    tooltip: t.building.open_tooltip,
                    icon: Icons.open_in_browser,
                    on_pressed: building != null
                        ? () => open_in_userside(context, 'building', building!['building_id'])
                        : null
                ),
                IconAction(
                    tooltip: t.building.copy_tooltip,
                    icon: Icons.copy,
                    on_pressed: building != null
                        ? () => copy_userside_link(context, 'building', building!['building_id'])
                        : null
                ),
                IconAction(
                    tooltip: t.common.refresh,
                    icon: Icons.refresh,
                    on_pressed: building != null? on_refresh : null
                )
            ],
            child: building == null && !not_found
                ? const Center(child: AngularProgressBar())
                : Column(
                    children: [
                        if (not_found)
                        Center(
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                spacing: 5,
                                children: [
                                    const Icon(Icons.warning_amber_outlined, color: AppColors.error),
                                    Text(t.building.not_found, style: const TextStyle(color: AppColors.error))
                                ]
                            )
                        )
                        else ...[
                            InfoTile(title: t.building.name, value: building?['name']),
                            InfoTile(title: t.building.type, value: building_type_label(building?['type'])),

                            if (building?['coordinates'] != null)
                            InfoTile(title: t.building.coordinates, value: building!['coordinates'].join(', ')),

                            if (building?['install_type'] != null)
                            InfoTile(title: t.building.install_type, value: building!['install_type']),

                            if (building?['build_status'] != null)
                            InfoTile(title: t.building.build_status, value: building!['build_status']),

                            InfoTile(
                                title: t.building.open_tasks,
                                value: tasks?.length.toString() ?? '0',
                                value_color: tasks == null
                                    ? AppColors.main
                                    : tasks.isEmpty? AppColors.success : AppColors.error,
                                on_tap: tasks == null || tasks.isEmpty
                                    ? null
                                    : () => on_open_tasks(List<int>.from(tasks))
                            ),

                            const SizedBox(height: 6),
                            SubHeading(icon: Icons.group, title: t.building.neighbours),
                            const SizedBox(height: 8),
                            TableHeader(columns: [
                                TableColumn(2, t.building.column_agreement),
                                TableColumn(7, t.building.column_name),
                                TableColumn(4, t.building.column_activity, align: TextAlign.center),
                                TableColumn(3, t.building.column_status, align: TextAlign.center),
                                TableColumn(1, t.building.column_rx, align: TextAlign.right)
                            ]),
                            const SizedBox(height: 8),

                            if (building?['customers']?.isNotEmpty ?? false)
                            Expanded(
                                child: ListView.builder(
                                    itemCount: building!['customers'].length,
                                    itemBuilder: (context, index) => _neighbour_row(building!['customers'][index])
                                )
                            )
                            else
                            Text(t.building.no_neighbours, style: const TextStyle(color: AppColors.secondary))
                        ]
                    ]
                )
        );
    }

    Widget _neighbour_row(Map neighbour) {
        return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
                children: [
                    Expanded(
                        flex: 2,
                        child: Text(neighbour['agreement'] ?? t.common.empty, softWrap: true)
                    ),
                    Expanded(
                        flex: 7,
                        child: Text(neighbour['name'], softWrap: true)
                    ),
                    Expanded(
                        flex: 4,
                        child: Text(
                            format_date(neighbour['last_active_at']),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: get_activity_color(neighbour['last_active_at']))
                        )
                    ),
                    Expanded(
                        flex: 3,
                        child: Text(
                            status_label(neighbour['status']),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: get_status_color(neighbour['status']))
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: Text(
                            convert_signal(neighbour['onu_level']),
                            textAlign: TextAlign.end,
                            style: TextStyle(color: get_signal_color(neighbour['onu_level']))
                        )
                    )
                ]
            )
        );
    }
}
