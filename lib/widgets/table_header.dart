import 'package:flutter/material.dart';

class TableColumn {
    const TableColumn(this.flex, this.label, {this.align = TextAlign.left});
    final int flex;
    final String? label;
    final TextAlign align;
}

class TableHeader extends StatelessWidget {
    const TableHeader({required this.columns, super.key});
    final List<TableColumn> columns;

    @override
    Widget build(BuildContext context) {
        return Row(
            children: columns.map((column) {
                return Expanded(
                    flex: column.flex,
                    child: column.label == null? const SizedBox() : Text(
                        column.label!,
                        textAlign: column.align,
                        style: const TextStyle(fontWeight: FontWeight.bold)
                    )
                );
            }).toList()
        );
    }
}
