import 'package:flutter/material.dart';
import 'package:smartlink/i18n.dart';
import 'package:smartlink/theme.dart';
import 'package:smartlink/widgets/tappable.dart';

/// Сворачиваемый список бригад с чекбоксами.
///
/// Раньше этот блок был дважды скопирован в диалоге создания задания —
/// отдельно для вкладки ремонта и отдельно для магистрального ремонта.
class DivisionsPicker extends StatefulWidget {
    const DivisionsPicker({required this.divisions, required this.on_changed, super.key});

    /// Список бригад; выбранные помечаются ключом `checked`.
    final List<Map> divisions;

    final VoidCallback on_changed;

    @override
    State<DivisionsPicker> createState() => _DivisionsPickerState();
}

class _DivisionsPickerState extends State<DivisionsPicker> {
    bool expanded = false;

    void _toggle(Map division) {
        setState(() {
            division['checked'] = !(division['checked'] ?? false);
        });
        widget.on_changed();
    }

    @override
    Widget build(BuildContext context) {
        return Column(
            children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        Text(t.newTask.executors, style: const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                            onPressed: () {
                                setState(() {
                                    expanded = !expanded;
                                });
                            },
                            icon: Icon(
                                expanded? Icons.arrow_drop_down_sharp : Icons.arrow_drop_up_sharp,
                                color: AppColors.secondary
                            )
                        )
                    ]
                ),
                if (expanded)
                ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.divisions.length,
                    itemBuilder: (context, index) {
                        final Map division = widget.divisions[index];
                        division['checked'] ??= false;

                        return Row(
                            spacing: 5,
                            children: [
                                Checkbox(
                                    value: division['checked'],
                                    onChanged: (_) => _toggle(division),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4)
                                ),
                                Expanded(
                                    child: Tappable(
                                        on_tap: () => _toggle(division),
                                        child: Text(division['name'])
                                    )
                                )
                            ]
                        );
                    }
                )
            ]
        );
    }
}
