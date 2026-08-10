import 'package:flutter/material.dart';
import 'package:flutter_date_formatter/flutter_date_formatter.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:smartlink/api.dart';
import 'package:smartlink/i18n.dart';
import 'package:smartlink/theme.dart';
import 'package:smartlink/utils.dart';
import 'package:smartlink/widgets/angular_progress_bar.dart';
import 'package:smartlink/widgets/divisions_picker.dart';

/// Тип задания и его цвет в выпадающем списке.
typedef TaskTypeOption = (int id, Color color);

const List<TaskTypeOption> _repair_types = [
    (37, Color(0xFF999100)),
    (60, Color(0xFF60686B)),
    (46, Color(0xFF523a6a))
];

const List<TaskTypeOption> _building_types = [
    (38, Color(0xFF860d1c)),
    (48, Color(0xFF3a538a))
];

/// Набор правил видимости полей: у ремонта и магистрали они разные.
enum TaskFormVariant { repair, building }

/// Значения, собранные формой к моменту отправки.
class TaskFormValue {
    const TaskFormValue({
        required this.type,
        required this.phone,
        required this.reason,
        required this.appeal_type,
        required this.description,
        required this.divisions
    });

    final int type;
    final String phone;
    final String reason;
    final String appeal_type;
    final String description;
    final List<int> divisions;
}


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

class _NewTaskDialogState extends State<NewTaskDialog> with SingleTickerProviderStateMixin {
    late final TabController _tabs = TabController(
        length: 2,
        initialIndex: widget.building? 1 : 0,
        vsync: this
    );

    final GlobalKey<_TaskFormState> _repair_key = GlobalKey<_TaskFormState>();
    final GlobalKey<_TaskFormState> _building_key = GlobalKey<_TaskFormState>();

    bool load = true;
    bool creating = false;

    List<Map> divisions = [];
    List<String> reasons = ['Жалоба на низкую скорость', 'Низкий сигнал ОВК', 'Обрыв кабеля(ОВК)', 'Сгорел БП', 'Белый IP', 'Замена роутера', 'Замена модема', 'Пробл. в сетевых настр. оборуд.', 'Пропадает доступ к интернету', 'Переоформление договора', 'Нет раздачи wifi', 'Моргает LOS', 'Настр каналов CATV', 'Смена тарифного плана', 'Монтаж оборудования', 'Переезд на другой адрес', 'Отключение доп. точки CATV', 'Провис кабеля', 'Меняют опоры', 'Переключение на другую коробку', 'Перенос ТВ точки', 'Подключение первой точки СATV', 'Настройка ОТТ приставки', 'Выкуп оборудования', 'Устройства не видят wifi сеть', 'Подключение доп. точки  КАТВ', 'Настройка антенны', 'Настройка ресивера', 'Нет сигнала МИТРИС', 'Закодировано', 'Проблемы с приложением Youtube', 'Не показывает NeoSmart TV'];
    List<String> appeal_types = ['Вход. звонок', 'Телетайп', 'Визит в офис', 'Исх. звонок', 'По факту'];
    List<String> building_reasons = ['Нет сигнала в коробке', 'Низкий сигнал в коробке', 'Обрыв кабеля', 'Провис кабель', 'Замена опоры', 'Мешает кабель', 'Монтаж', 'Коробка упала', 'Крыша протекает', 'Другое'];

    @override
    void initState() {
        super.initState();
         _tabs.addListener(_on_tab_changed);
         WidgetsBinding.instance.addPostFrameCallback((_) => _on_tab_changed());
        _load();
    }


    @override
    void dispose() {
        _tabs.removeListener(_on_tab_changed);
        _tabs.dispose();
        super.dispose();
    }

    void _on_tab_changed() {
        if (!mounted || _tabs.indexIsChanging) return;
        if (_tabs.index != 1 || widget.address_id != null) return;

        Navigator.pop(context, {'reopen_with_building': true});
    }

    _TaskFormState? _form(bool is_building) =>
        (is_building? _building_key : _repair_key).currentState;

    Future<void> _load() async {
        try {
            divisions = await get_divisions();
            if (!mounted) return;
            setState(() {
                load = false;
            });
        } catch (e) {
            l.e('error while loading divisions: $e');
            if (!mounted) return;
            Navigator.pop(context);
            show_error(context, t.newTask.load_error);
        }
    }

    Future<void> _create() async {
        final bool is_building = _tabs.index == 1;
        final TaskFormValue? value = _form(is_building)?.value;
        if (value == null) return;

        setState(() {
            creating = true;
        });

        if (!mounted) return;


        try {
            final int id = await create_task(
                value.type,
                is_building? null : widget.customer_id,
                value.reason,
                is_building? widget.address_id : null,
                value.description,
                value.divisions,
                value.phone,
                value.appeal_type
            );
            l.i('task created successfully, id: $id');

            if (!mounted) return;
            final String now = DateTime.now().format(pattern: 'yyyy.MM.dd HH:mm:ss').replaceAll('-', '.');
            Navigator.pop(context, {
                'building': is_building,
                'id': id,
                'new': true,
                'type': {'id': value.type, 'name': task_type_label(value.type)},
                'status': {'id': 11, 'name': t.newTask.default_status, 'system_id': 4},
                'created_at': now,
                'updated_at': now,
                'planned_to': now
            });
            show_success(context, t.newTask.created);
        } catch (e){
            l.e('error while creating task: $e');
            Navigator.pop(context);
            show_error(context, t.newTask.create_error);
        }
    }

    @override
    Widget build(BuildContext context) {
        return AlertDialog(
            title: Text(t.newTask.title),
            content: load? const Center(child: AngularProgressBar()) : SizedBox(
                width: 600,
                child: SelectionArea(
                    child: Column(
                        children: [
                            TabBar(
                                controller: _tabs,
                                tabs: [
                                    Tab(text: t.newTask.tab_repair, icon: const Icon(Icons.home_repair_service)),
                                    Tab(text: t.newTask.tab_building, icon: const Icon(Icons.cable))
                                ]
                            ),
                            Expanded(
                                child: TabBarView(
                                    controller: _tabs,
                                    children: [
                                        _TaskForm(
                                            key: _repair_key,
                                            variant: TaskFormVariant.repair,
                                            types: _repair_types,
                                            phones: widget.phones,
                                            reasons: reasons,
                                            appeal_types: appeal_types,
                                            divisions: divisions,
                                            on_changed: () => setState(() {})
                                        ),
                                        widget.address_id == null
                                            ? const SizedBox()
                                            : _TaskForm(
                                                key: _building_key,
                                                variant: TaskFormVariant.building,
                                                types: _building_types,
                                                phones: widget.phones,
                                                reasons: building_reasons,
                                                appeal_types: appeal_types,
                                                divisions: divisions,
                                                on_changed: () => setState(() {})
                                            )
                                    ]
                                )
                            )
                        ]
                    )
                )
            ),
            actions: [
                ListenableBuilder(
                    listenable: _tabs,
                    builder: (context, child) {
                        final bool ready = _form(_tabs.index == 1)?.is_valid ?? false;

                        return ElevatedButton(
                            onPressed: ready && !creating? _create : null,
                            child: creating? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator()) : Text(t.common.create)
                        );
                    }
                )
            ]
        );
    }
}


/// Тело вкладки: само хранит выбранные значения и правила видимости полей.
///
/// Родитель читает результат через `GlobalKey<_TaskFormState>().currentState.value`
/// и готовность к отправке через `.is_valid`.
class _TaskForm extends StatefulWidget {
    const _TaskForm({
        required this.variant,
        required this.types,
        required this.phones,
        required this.reasons,
        required this.appeal_types,
        required this.divisions,
        required this.on_changed,
        super.key
    });

    final TaskFormVariant variant;
    final List<TaskTypeOption> types;
    final List phones;
    final List<String> reasons;
    final List<String> appeal_types;
    final List<Map> divisions;

    final VoidCallback on_changed;

    @override
    State<_TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<_TaskForm> with AutomaticKeepAliveClientMixin {
    late int type = widget.types.first.$1;

    String? reason;
    String? appeal_type;

    final TextEditingController phone_controller = TextEditingController();
    final TextEditingController description_controller = TextEditingController();

    final MaskTextInputFormatter phone_mask = MaskTextInputFormatter(
        mask: '+996 (###) ###-###',
        filter: {'#': RegExp(r'[0-9]')}
    );

    @override
    bool get wantKeepAlive => true;

    @override
    void initState() {
        super.initState();
        reason = widget.reasons.firstOrNull;
        appeal_type = widget.appeal_types.firstOrNull;
    }

    @override
    void dispose() {
        phone_controller.dispose();
        description_controller.dispose();
        super.dispose();
    }

    bool get _show_phone => switch (widget.variant) {
        TaskFormVariant.repair => true,
        TaskFormVariant.building => type != 38
    };

    bool get _show_reason => switch (widget.variant) {
        TaskFormVariant.repair => type != 60,
        TaskFormVariant.building => true
    };

    bool get _show_appeal_type => switch (widget.variant) {
        TaskFormVariant.repair => type != 60,
        TaskFormVariant.building => type != 48
    };

    /// Телефон обязателен везде, где он показан.
    bool get is_valid => !_show_phone || phone_controller.text.isNotEmpty;

    TaskFormValue get value => TaskFormValue(
        type: type,
        phone: phone_mask.unmaskText(phone_controller.text),
        reason: reason ?? '',
        appeal_type: appeal_type ?? '',
        description: description_controller.text,
        divisions: List<int>.from(
            widget.divisions.where((e) => e['checked'] ?? false).map((e) => e['id'])
        )
    );

    void _changed(VoidCallback change) {
        setState(change);
        widget.on_changed();
    }


    @override
    Widget build(BuildContext context) {
        super.build(context);
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
                            items: widget.types.map((item) {
                                return DropdownMenuItem(
                                    value: item.$1,
                                    child: Text(task_type_label(item.$1), style: TextStyle(color: item.$2))
                                );
                            }).toList(),
                            onChanged: (value) => _changed(() => type = value!)
                        )
                    ),

                    if (_show_phone) ..._phone_fields(),

                    if (_show_reason) ...[
                        _Label(t.newTask.reason),
                        _Field(
                            child: DropdownButtonFormField<String>(
                                style: const TextStyle(fontSize: 13, fontFamily: 'Jost', color: AppColors.main),
                                initialValue: reason,
                                items: widget.reasons
                                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                    .toList(),
                                onChanged: (value) => _changed(() => reason = value)
                            )
                        )
                    ],

                    if (_show_appeal_type) ...[
                        _Label(t.newTask.appeal_type),
                        _Field(
                            child: DropdownButtonFormField<String>(
                                style: const TextStyle(fontSize: 13, fontFamily: 'Jost', color: AppColors.main),
                                initialValue: appeal_type,
                                items: widget.appeal_types
                                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                    .toList(),
                                onChanged: (value) => _changed(() => appeal_type = value)
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

                    DivisionsPicker(divisions: widget.divisions, on_changed: widget.on_changed)
                ]
            )
        );
    }

    List<Widget> _phone_fields() {
        return [
            _Label(t.newTask.phone),
            _Field(
                child: TextField(
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(hintText: t.newTask.phone_hint),
                    controller: phone_controller,
                    inputFormatters: [phone_mask],
                    onChanged: (value) {
                        l.i('phone value changed to $value');
                        _changed(() {});
                    }
                )
            ),

            if (widget.phones.isNotEmpty) ...[
                _Label(t.newTask.phone_choose, bold: false),
                Row(
                    spacing: 5,
                    children: widget.phones.map<Widget>((raw) {
                        final String phone = phone_mask.maskText(raw.toString());
                        return ChoiceChip(
                            label: Text(phone),
                            selected: phone == phone_controller.text,
                            onSelected: (_) {
                                l.i('select phone $raw using ChoiceChip');
                                _changed(() => phone_controller.text = phone);
                            }
                        );
                    }).toList()
                )
            ]
        ];
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
