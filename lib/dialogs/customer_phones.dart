import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:smartlink/api.dart';
import 'package:smartlink/exception.dart';
import 'package:smartlink/i18n.dart';

class CustomerPhonesDialog extends StatefulWidget {
    const CustomerPhonesDialog({required this.customer_id, required this.phones, super.key});

    final int customer_id;
    final List<int> phones;

    @override
    State<CustomerPhonesDialog> createState() => _CustomerPhonesDialogState();
}

class _CustomerPhonesDialogState extends State<CustomerPhonesDialog> {
    bool saving = false;

    final TextEditingController phone_1 = TextEditingController();
    final TextEditingController phone_2 = TextEditingController();
    final TextEditingController phone_3 = TextEditingController();

    late final MaskTextInputFormatter phone_mask_1;
    late final MaskTextInputFormatter phone_mask_2;
    late final MaskTextInputFormatter phone_mask_3;

    Future _save() async {
        setState(() => saving = true);
        final phones = [
            phone_mask_1.unmaskText(phone_1.text),
            phone_mask_2.unmaskText(phone_2.text),
            phone_mask_3.unmaskText(phone_3.text)
        ].where((e) => e.isNotEmpty).map(int.parse).toList();

        await guard(context, () => update_customers(widget.customer_id, phones));
        if (!mounted) return;
        Navigator.pop(context, phones);
    }

    @override
    void initState() {
        phone_mask_1 = MaskTextInputFormatter(
            mask: '+996 (###) ###-###',
            filter: {'#': RegExp(r'[0-9]')},
            initialText: widget.phones[0].toString()
        );
        phone_mask_2 = MaskTextInputFormatter(
            mask: '+996 (###) ###-###',
            filter: {'#': RegExp(r'[0-9]')},
            initialText: widget.phones.length > 1? widget.phones[1].toString() : null
        );
        phone_mask_3 = MaskTextInputFormatter(
            mask: '+996 (###) ###-###',
            filter: {'#': RegExp(r'[0-9]')},
            initialText: widget.phones.length > 2? widget.phones[2].toString() : null
        );

        phone_1.text = phone_mask_1.maskText(widget.phones[0].toString());
        if (widget.phones.length > 1) {
            phone_2.text = phone_mask_2.maskText(widget.phones[1].toString());
        }
        if (widget.phones.length > 2) {
            phone_3.text = phone_mask_3.maskText(widget.phones[2].toString());
        }

        super.initState();
    }

    @override
    Widget build(BuildContext context) {
        return AlertDialog(
            title: Text(t.customerPhones.title),
            content: SizedBox(
                width: 400,
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 10,
                    children: [
                        TextField(
                            decoration: InputDecoration(labelText: t.customerPhones.main),
                            controller: phone_1,
                            inputFormatters: [phone_mask_1],
                            onChanged: (_) => setState(() {})
                        ),
                        TextField(
                            decoration: InputDecoration(labelText: t.customerPhones.additional),
                            controller: phone_2,
                            inputFormatters: [phone_mask_2],
                            onChanged: (_) => setState(() {})
                        ),
                        TextField(
                            decoration: InputDecoration(labelText: t.customerPhones.additional),
                            controller: phone_3,
                            inputFormatters: [phone_mask_3],
                            onChanged: (_) => setState(() {})
                        )
                    ]
                )
            ),
            actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(t.common.cancel),
                ),
                ElevatedButton(
                    onPressed: !saving && phone_1.text.length == 18 && phone_2.text.length == 18? _save : null,
                    child: saving? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator()) : Text(t.customerPhones.save),
                )
            ]
        );
    }
}
