import 'package:flutter/material.dart';
import 'package:smartlink/i18n.dart';
import 'package:smartlink/theme.dart';
import 'package:smartlink/utils.dart';
import 'package:smartlink/widgets/angular_progress_bar.dart';
import 'package:smartlink/widgets/data_card.dart';
import 'package:smartlink/widgets/icon_action.dart';
import 'package:smartlink/widgets/table_header.dart';

class ItemsCard extends StatelessWidget {
    const ItemsCard({
        required this.items,
        required this.on_refresh,
        required this.on_open_ont,
        super.key
    });
    final List<Map<String, dynamic>>? items;
    final VoidCallback on_refresh;
    final VoidCallback on_open_ont;

    @override
    Widget build(BuildContext context) {
        return DataCard(
            line_color: AppColors.main,
            icon: Icons.device_hub,
            title: t.items.title,
            flex: 2,
            last: true,
            mini_buttons: [
                IconAction(
                    tooltip: t.common.refresh,
                    icon: Icons.refresh,
                    on_pressed: items != null? on_refresh : null
                )
            ],
            child: items == null? const Center(child: AngularProgressBar()) : Column(
                children: [
                    if (items!.isEmpty)
                    Center(child: Text(t.items.empty, style: const TextStyle(color: AppColors.secondary)))
                    else ...[
                        TableHeader(columns: [
                            TableColumn(4, t.items.column_name),
                            TableColumn(4, t.items.column_type, align: TextAlign.center),
                            TableColumn(5, t.items.column_sn, align: TextAlign.center),
                            TableColumn(2, t.items.column_amount, align: TextAlign.right)
                        ]),
                        Expanded(
                            child: ListView.builder(
                                itemCount: items!.length,
                                itemBuilder: (context, index) => _item_row(items![index])
                            )
                        )
                    ]
                ]
            )
        );
    }

    Widget _item_row(Map<String, dynamic> item) {
        return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
                children: [
                    Expanded(
                        flex: 4,
                        child: Text(item['category']?['name'] ?? t.common.empty, softWrap: true)
                    ),
                    Expanded(
                        flex: 4,
                        child: Text(item_type_label(item['category']?['type']), softWrap: true, textAlign: TextAlign.center)
                    ),
                    Expanded(
                        flex: 5,
                        child: item['sn'] == null
                            ? Text(t.common.empty, softWrap: true, textAlign: TextAlign.center)
                            : InkWell(
                                onTap: on_open_ont,
                                child: Text(
                                    item['sn'],
                                    softWrap: true,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: AppColors.neo,
                                        decorationColor: AppColors.neo,
                                        decoration: TextDecoration.underline
                                    )
                                )
                            )
                    ),
                    Expanded(
                        flex: 2,
                        child: Text(
                            '${item['amount']} ${item['category']?['unit'] ?? ''}',
                            softWrap: true,
                            textAlign: TextAlign.right
                        )
                    )
                ]
            )
        );
    }
}
