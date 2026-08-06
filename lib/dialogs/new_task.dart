import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartlink/api.dart';
import 'package:smartlink/i18n.dart';
import 'package:smartlink/theme.dart';
import 'package:smartlink/utils.dart';
import 'package:smartlink/widgets/angular_progress_bar.dart';
import 'package:smartlink/widgets/divisions_picker.dart';

/// Типы заданий на вкладке «Ремонт».
const List<(int id, Color color)> _repair_types = [
    (37, Color(0xFF999100)),
    (60, Color(0xFF60686B)),
    (46, Color(0xFF523a6a))
];

/// Типы заданий на вкладке «Магистральный ремонт».
const List<(int id, Color color)> _building_types = [
    (38, Color(0xFF860d1c)),
    (48, Color(0xFF3a538a))
];

class NewTaskDialog extends StatefulWidget {
    const NewTaskDialog({
        required this.customer_id,
        required this.address_id,
        required this.phones,
        super.key,
        this.building = false
    });
    final int customer_id;
    final int? address_id;
    final List phones;

    /// Открыть сразу на вкладке магистрального ремонта.
    final bool building;

    @override
    State<NewTaskDialog> createState() => _NewTaskDialogState();
}

class _NewTaskDialogState extends State<NewTaskDialog> {
    bool load = true;
    bool creating = false;

    int type = 37;
    int building_type = 38;

    final TextEditingController phone_controller = TextEditingController();
    final MaskTextInputFormatter phone_mask = MaskTextInputFormatter(
        mask: '+996 (###) ###-###',
        filter: {'#': RegExp(r'[0-9]')}
    );

    // TODO: справочники причин переехали в API 3.0 — заполнить из нового эндпоинта
    String? reason;
    List<String> reasons = [];

    String? appeal_type;
    List<String> appeal_types = [];

    String? building_reason;
    List<String> building_reasons = [];

    final TextEditingController description_controller = TextEditingController();
    List<Map> divisions = [];

    @override
    void initState() {
        super.initState();
        _load();
    }

    @override
    void dispose() {
        phone_controller.dispose();
        description_controller.dispose();
        super.dispose();
    }

    Future<void> _load() async {
        try {
            reason = reasons.firstOrNull;
            building_reason = building_reasons.firstOrNull;
            appeal_type = appeal_types.firstOrNull;
            divisions = List<Map>.from(await get_divisions());

            setState(() {
                load = false;
            });
        } catch (e) {
            l.e('error while loading addata/divisions: $e');
            if (!mounted) return;
            Navigator.pop(context);
            show_error(context, t.newTask.load_error);
        }
    }

    Future<void> _create(BuildContext context) async {
        setState(() {
            creating = true;
        });

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final int? author_id = prefs.getInt('userId');

        if (!context.mounted) return;

        if (author_id == null){
            l.e('error while creating task: no employeeId');
            Navigator.pop(context);
            show_error(context, t.newTask.no_author);
            return;
        }

        final bool is_building = DefaultTabController.of(context).index == 1;
        final int task_type = is_building? building_type : type;

        try {
            final int id = await create_task(
                task_type,
                is_building? null : widget.customer_id,
                author_id,
                (is_building? building_reason : reason) ?? '',
                is_building? widget.address_id : null,
                description_controller.text,
                List<int>.from(divisions.where((e) => e['checked'] ?? false).map((e) => e['id'])),
                phone_mask.unmaskText(phone_controller.text),
                appeal_type ?? ''
            );
            l.i('task created successfully, id: $id');

            if (!context.mounted) return;
            final String now = DateTime.now().toString().substring(0, 19);
            Navigator.pop(context, {
                'building': is_building,
                'id': id,
                'new': true,
                'type': {'id': task_type, 'name': task_type_label(task_type)},
                'status': {'id': 11, 'name': t.newTask.default_status, 'system_id': 4},
                'created_at': now,
                'updated_at': now,
                'planned_to': now
            });
            show_success(context, t.newTask.created);
        } catch (e){
            l.e('error while creating task: $e');
            if (!context.mounted) return;
            Navigator.pop(context);
            show_error(context, t.newTask.create_error);
        }
    }

    /// Кнопка «Создать» неактивна, пока не заполнено обязательное.
    bool _create_disabled(bool is_building) {
        if (is_building && widget.address_id == null) return true;
        if (phone_controller.text.isNotEmpty) return false;

        return !is_building || building_type != 38;
    }

    @override
    Widget build(BuildContext context) {
        return DefaultTabController(
            initialIndex: widget.building? 1 : 0,
            length: 2,
            child: AlertDialog(
                title: Text(t.newTask.title),
                content: load? const Center(child: AngularProgressBar()) : SizedBox(
                    width: 600,
                    child: SelectionArea(
                        child: Column(
                            children: [
                                TabBar(
                                    tabs: [
                                        Tab(text: t.newTask.tab_repair, icon: const Icon(Icons.home_repair_service)),
                                        IgnorePointer(
                                            ignoring: widget.address_id == null,
                                            child: Opacity(
                                                opacity: widget.address_id == null? 0.3 : 1.0,
                                                child: Tab(
                                                    text: t.newTask.tab_building,
                                                    icon: const Icon(Icons.cable)
                                                )
                                            )
                                        )
                                    ]
                                ),
                                Expanded(
                                    child: TabBarView(
                                        children: [
                                            _repair_tab(),
                                            _building_tab()
                                        ]
                                    )
                                )
                            ]
                        )
                    )
                ),
                actions: [
                    Builder(
                        builder: (actions_context) {
                            return AnimatedBuilder(
                                animation: DefaultTabController.of(actions_context),
                                builder: (context, child) {
                                    final bool is_building = DefaultTabController.of(actions_context).index == 1;

                                    return ElevatedButton(
                                        onPressed: _create_disabled(is_building)
                                            ? null
                                            : () => _create(actions_context),
                                        child: creating
                                            ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator())
                                            : Text(t.common.create)
                                    );
                                }
                            );
                        }
                    )
                ]
            )
        );
    }

    Widget _repair_tab() {
        return _TaskForm(
            types: _repair_types,
            type: type,
            on_type_changed: (value) => setState(() => type = value),
            show_phone: true,
            show_reason: type != 60,
            show_appeal_type: type != 60,
            phone_controller: phone_controller,
            phone_mask: phone_mask,
            phones: widget.phones,
            reason: reason,
            reasons: reasons,
            on_reason_changed: (value) => setState(() => reason = value),
            appeal_type: appeal_type,
            appeal_types: appeal_types,
            on_appeal_type_changed: (value) => setState(() => appeal_type = value),
            description_controller: description_controller,
            divisions: divisions,
            on_changed: () => setState(() {})
        );
    }

    Widget _building_tab() {
        if (widget.address_id == null) {
            return Column(
                children: [
                    const SizedBox(height: 5),
                    Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 5,
                        children: [
                            const Icon(Icons.warning_amber_outlined, color: AppColors.error),
                            Text(t.newTask.no_building, style: const TextStyle(color: AppColors.error))
                        ]
                    ),
                    Text(t.newTask.no_building_hint, style: const TextStyle(color: AppColors.secondary))
                ]
            );
        }

        return _TaskForm(
            types: _building_types,
            type: building_type,
            on_type_changed: (value) => setState(() => building_type = value),
            show_phone: building_type != 38,
            show_reason: true,
            show_appeal_type: building_type != 48,
            phone_controller: phone_controller,
            phone_mask: phone_mask,
            phones: widget.phones,
            reason: building_reason,
            reasons: building_reasons,
            on_reason_changed: (value) => setState(() => building_reason = value),
            appeal_type: appeal_type,
            appeal_types: appeal_types,
            on_appeal_type_changed: (value) => setState(() => appeal_type = value),
            description_controller: description_controller,
            divisions: divisions,
            on_changed: () => setState(() {})
        );
    }
}


/// Тело вкладки диалога — одинаковое для обычного и магистрального ремонта.
class _TaskForm extends StatelessWidget {
    const _TaskForm({
        required this.types,
        required this.type,
        required this.on_type_changed,
        required this.show_phone,
        required this.show_reason,
        required this.show_appeal_type,
        required this.phone_controller,
        required this.phone_mask,
        required this.phones,
        required this.reason,
        required this.reasons,
        required this.on_reason_changed,
        required this.appeal_type,
        required this.appeal_types,
        required this.on_appeal_type_changed,
        required this.description_controller,
        required this.divisions,
        required this.on_changed
    });

    final List<(int, Color)> types;
    final int type;
    final ValueChanged<int> on_type_changed;

    final bool show_phone;
    final bool show_reason;
    final bool show_appeal_type;

    final TextEditingController phone_controller;
    final MaskTextInputFormatter phone_mask;
    final List phones;

    final String? reason;
    final List<String> reasons;
    final ValueChanged<String?> on_reason_changed;

    final String? appeal_type;
    final List<String> appeal_types;
    final ValueChanged<String?> on_appeal_type_changed;

    final TextEditingController description_controller;
    final List<Map> divisions;
    final VoidCallback on_changed;

    @override
    Widget build(BuildContext context) {
        return SingleChildScrollView(
            child: Column(
                spacing: 5,
                children: [
                    const SizedBox(height: 5),

                    _Label(t.newTask.type),
                    _Field(
                        child: DropdownButtonFormField<int>(
                            style: const TextStyle(
                                fontSize: 13,
                                fontFamily: 'Jost',
                                color: AppColors.main,
                                fontWeight: FontWeight.bold
                            ),
                            initialValue: type,
                            items: types.map((item) {
                                return DropdownMenuItem(
                                    value: item.$1,
                                    child: Text(task_type_label(item.$1), style: TextStyle(color: item.$2))
                                );
                            }).toList(),
                            onChanged: (value) => on_type_changed(value!)
                        )
                    ),

                    if (show_phone) ...[
                        _Label(t.newTask.phone),
                        _Field(
                            child: TextField(
                                style: const TextStyle(fontSize: 13),
                                decoration: InputDecoration(hintText: t.newTask.phone_hint),
                                controller: phone_controller,
                                inputFormatters: [phone_mask],
                                onChanged: (value) {
                                    l.i('phone value changed to $value');
                                    on_changed();
                                }
                            )
                        ),

                        if (phones.isNotEmpty) ...[
                            _Label(t.newTask.phone_choose, bold: false),
                            Row(
                                spacing: 5,
                                children: phones.map<Widget>((raw) {
                                    final String phone = phone_mask.maskText(raw);
                                    return ChoiceChip(
                                        label: Text(phone),
                                        selected: phone == phone_controller.text,
                                        onSelected: (_) {
                                            l.i('select phone $raw using ChoiceChip');
                                            phone_controller.text = phone;
                                            on_changed();
                                        }
                                    );
                                }).toList()
                            )
                        ]
                    ],

                    if (show_reason) ...[
                        _Label(t.newTask.reason),
                        _Field(
                            child: DropdownButtonFormField<String>(
                                style: const TextStyle(fontSize: 13, fontFamily: 'Jost', color: AppColors.main),
                                initialValue: reason,
                                items: reasons.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                onChanged: on_reason_changed
                            )
                        )
                    ],

                    if (show_appeal_type) ...[
                        _Label(t.newTask.appeal_type),
                        _Field(
                            child: DropdownButtonFormField<String>(
                                style: const TextStyle(fontSize: 13, fontFamily: 'Jost', color: AppColors.main),
                                initialValue: appeal_type,
                                items: appeal_types.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                onChanged: on_appeal_type_changed
                            )
                        )
                    ],

                    _Label(t.newTask.description),
                    TextField(
                        controller: description_controller,
                        maxLines: 3,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(hintText: t.newTask.description_hint)
                    ),

                    DivisionsPicker(divisions: divisions, on_changed: on_changed)
                ]
            )
        );
    }
}

/// Подпись над полем формы.
class _Label extends StatelessWidget {
    const _Label(this.text, {this.bold = true});
    final String text;
    final bool bold;

    @override
    Widget build(BuildContext context) {
        return Align(
            alignment: Alignment.topLeft,
            child: Text(
                text,
                style: bold
                    ? const TextStyle(fontWeight: FontWeight.bold)
                    : const TextStyle(color: AppColors.secondary)
            )
        );
    }
}

/// Поле формы фиксированной высоты.
class _Field extends StatelessWidget {
    const _Field({required this.child});
    final Widget child;

    @override
    Widget build(BuildContext context) => SizedBox(height: 40, child: child);
}
