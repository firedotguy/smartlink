import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartlink/api.dart';
import 'package:smartlink/exception.dart';
import 'package:smartlink/i18n.dart';
import 'package:smartlink/theme.dart';
import 'package:smartlink/utils.dart';
import 'package:smartlink/widgets/angular_progress_bar.dart';
import 'package:smartlink/widgets/dialog_header.dart';
import 'package:smartlink/widgets/icon_action.dart';
import 'package:smartlink/widgets/info_tile.dart';
import 'package:smartlink/widgets/section_card.dart';

class TaskDialog extends StatefulWidget {
    const TaskDialog({super.key, this.task, this.id});
    final Map<String, dynamic>? task;
    final int? id;

    @override
    State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
    Map<String, dynamic>? task;
    bool load = true;
    bool sending = false;
    int? employee_id;
    final TextEditingController comment_controller = TextEditingController();

    int? get _task_id => widget.id ?? task?['id'];

    @override
    void initState() {
        super.initState();
        task = widget.task;
        _load();
    }

    @override
    void dispose() {
        comment_controller.dispose();
        super.dispose();
    }

    Future<void> _load() async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        employee_id = prefs.getInt('userId');
        if (!mounted) return;

        setState(() => load = true);
        task = await guard(context, () => get_task(widget.id!));
        setState(() => load = false);
    }

    Future<void> _add_comment() async {
        final String content = comment_controller.text.trim();
        if (content.isEmpty || sending) return;

        setState(() {
            sending = true;
        });
        try {
            comment_controller.clear();
            final int id = await add_comment(task!['id'], content);
            task!['comments'].add({
                'id': id,
                'content': content,
                'author': {'id': employee_id, 'name': null},
                'created_at': null
            });
        } catch (e) {
            l.e('error adding comment: $e');
            if (mounted) show_error(context, t.task.comment_error('$e'));
        } finally {
            if (mounted) {
                setState(() {
                    sending = false;
                });
            }
        }
    }

    Widget _main_section() {
        final List employees = task?['employees'] ?? const [];
        final List divisions = task?['divisions'] ?? const [];

        return SectionCard(
            title: t.task.section_main,
            child: Column(
                children: [
                    InfoTile(title: t.task.type, value: task?['type']?['name']),
                    InfoTile(
                        title: t.task.status,
                        child: Text(
                            task?['status']?['name'] ?? t.common.empty,
                            textAlign: TextAlign.right,
                            style: TextStyle(color: get_task_status_color(task?['status']?['id']))
                        )
                    ),
                    InfoTile(title: t.task.address, value: task?['address']?['label']),
                    InfoTile(title: t.task.author, value: task?['author']?['name']),

                    if (employees.isNotEmpty)
                    InfoTile(title: t.task.employees, value: employees.map((e) => e['name']).join(', ')),

                    if (divisions.isNotEmpty)
                    InfoTile(title: t.task.divisions, value: divisions.map((e) => e['name']).join(', ')),

                    const Divider(),

                    if (task?['appeal_reason'] != null)
                    InfoTile(title: t.task.appeal_reason, value: task!['appeal_reason']),

                    if (task?['solve'] != null)
                    InfoTile(title: t.task.solve, value: task!['solve']),

                    if (task?['appeal_phone'] != null)
                    InfoTile(
                        title: t.task.appeal_phone,
                        child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                                const Icon(Icons.phone, size: 18, color: AppColors.neo),
                                const SizedBox(width: 8),
                                Text(task!['appeal_phone'].toString())
                            ]
                        )
                    ),

                    if (task?['appeal_type'] != null)
                    InfoTile(title: t.task.appeal_type, value: task!['appeal_type']),

                    if (task?['price'] != null)
                    InfoTile(title: t.task.price, value: t.common.som('${task!['price'].round()}')),

                    if (task?['tariff'] != null)
                    InfoTile(title: t.task.tariff, value: task!['tariff']),

                    if (task?['coordinates'] != null)
                    InfoTile(title: t.task.coordinates, value: task!['coordinates'].join(', ')),

                    if (task?['connect_type'] != null)
                    InfoTile(title: t.task.connect_type, value: task!['connect_type']),

                    const Divider(),
                    InfoTile(title: t.task.created_at, value: format_date(task?['created_at'])),
                    InfoTile(title: t.task.updated_at, value: format_date(task?['updated_at'])),
                    InfoTile(title: t.task.planned_to, value: format_date(task?['planned_to'])),
                    InfoTile(title: t.task.completed_at, value: format_date(task?['completed_at']))
                ]
            )
        );
    }

    Widget _comments_section() {
        final List comments = task?['comments'] ?? const [];

        return SectionCard(
            title: t.task.section_comments,
            child: comments.isEmpty
                ? Align(
                    alignment: Alignment.topCenter,
                    child: Text(t.task.no_comments, style: const TextStyle(color: AppColors.secondary))
                )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: comments.length,
                    itemBuilder: (context, index) => _comment(comments[index])
                )
        );
    }

    Widget _comment(Map message) {
        final bool is_mine = employee_id == message['author']?['id'];

        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Align(
                alignment: is_mine? Alignment.topRight : Alignment.topLeft,
                child: Container(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                    decoration: BoxDecoration(
                        color: is_mine? AppColors.neo : AppColors.bg,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(is_mine? 12 : 0),
                            bottomRight: Radius.circular(is_mine? 0 : 12),
                            topLeft: const Radius.circular(12),
                            topRight: const Radius.circular(12)
                        ),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.04))
                    ),
                    child: IntrinsicWidth(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 4,
                            children: [
                                if (!is_mine && message['author']?['id'] != null)
                                Text(
                                    message['author']['name'] ?? t.common.empty,
                                    style: const TextStyle(fontWeight: FontWeight.bold)
                                ),
                                Text(message['content']),
                                Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                        message['created_at'] == null
                                            ? t.task.just_now
                                            : format_date(message['created_at']),
                                        style: const TextStyle(fontSize: 11)
                                    )
                                )
                            ]
                        )
                    )
                )
            )
        );
    }

    Widget _comment_field() {
        return Row(
            children: [
                Expanded(
                    child: TextField(
                        controller: comment_controller,
                        minLines: 1,
                        maxLines: 4,
                        decoration: InputDecoration(
                            hintText: t.task.comment_hint,
                            isDense: true,
                            border: const OutlineInputBorder()
                        ),
                        onSubmitted: (_) => _add_comment(),
                    )
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                    onPressed: _add_comment,
                    icon: sending
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator())
                        : const Icon(Icons.send, size: 18),
                    label: Text(t.task.send)
                )
            ]
        );
    }

    @override
    Widget build(BuildContext context) {
        return AlertDialog(
            title: DialogHeader(
                title: t.task.title,
                icon: Icons.assignment_outlined,
                actions: [
                    IconAction(
                        tooltip: t.task.copy_tooltip,
                        icon: Icons.copy,
                        on_pressed: _task_id == null
                            ? null
                            : () => copy_userside_link(context, 'task', _task_id!)
                    ),
                    IconAction(
                        tooltip: t.common.open_in_userside,
                        icon: Icons.open_in_browser,
                        on_pressed: _task_id == null
                            ? null
                            : () => open_in_userside(context, 'task', _task_id!)
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
                                _main_section(),
                                const SizedBox(height: 8),
                                _comments_section(),
                                const SizedBox(height: 8),
                                _comment_field()
                            ]
                        )
                    )
                )
            ),
            actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text(t.common.close))
            ]
        );
    }
}
