import 'package:flutter/material.dart';
import 'package:smartlink/api.dart';
import 'package:smartlink/main.dart';

class CatvToggleDialog extends StatefulWidget{
  const CatvToggleDialog({
    required this.state,
    required this.interface,
    required this.ontID,
    required this.catvID,
    required this.host,
    this.isCustomerActive = false,
    super.key
  });
  final bool state;
  final Map interface;
  final int ontID;
  final int catvID;
  final String host;
  final bool isCustomerActive;

  @override
  State<CatvToggleDialog> createState() => _CatvToggleDialogState();
}

class _CatvToggleDialogState extends State<CatvToggleDialog> {
  bool toggling = false;

  void _close() {
    Navigator.pop(context);
  }

  void _toggle() async {
    if (toggling) return;
    setState(() {
      toggling = true;
    });
    bool toggled = false;
    try{
      final Map res = await toggleCATV(widget.host, widget.interface['fibre'], widget.interface['service'], widget.interface['port'], widget.ontID, widget.catvID, !widget.state);
      if (res['status'] != 'success'){
        l.e('error toggling catv: ${res['detail']}');
        if (mounted){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошбика переключения CATV: ${res['detail']}',
            style: const TextStyle(color: AppColors.error)
          )));
        }
      } else {
        l.i('catv toggled');
        toggled = true;
        if (mounted){
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CATV успешно переключен', style: TextStyle(color: AppColors.success))));
        }
      }
    } catch (e) {
      l.e('error toggling catv: $e');
      if (mounted){
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошбика переключения CATV', style: TextStyle(color: AppColors.error))));
      }
    } finally {
      if (mounted){
        Navigator.pop(context, toggled);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.state? 'Выключение CATV' : 'Включение CATV'),
          Row(
            children: [
              Tooltip(
                message: 'Переключить состояние',
                child: IconButton(
                  onPressed: !widget.isCustomerActive? null : _toggle,
                  icon: Icon(widget.state? Icons.toggle_off : Icons.toggle_on, color: toggling || !widget.isCustomerActive? AppColors.secondary : AppColors.neo, size: 18),
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36)
                ),
              ),
              Tooltip(
                message: 'Закрыть диалог',
                child: IconButton(
                  onPressed: _close,
                  icon: const Icon(Icons.close, color: AppColors.error, size: 18),
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36)
                ),
              )
            ],
          )
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.state? 'Вы уверены что хотите выключить CATV?' : 'Вы уверены что хотите включить CATV?', style: const TextStyle(fontSize: 16)),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Состояние порта: ', style: TextStyle(color: AppColors.secondary)),
                TextSpan(text: widget.state? 'Включен' : 'Выключен', style: TextStyle(color: widget.state? AppColors.success : AppColors.error))
              ]
            )
          ),
          // Text.rich(
          //   TextSpan(
          //     children: [
          //       const TextSpan(text: 'Состояние порта после переключения: ', style: TextStyle(color: AppColors.secondary)),
          //       TextSpan(text: !widget.state? 'Включен' : 'Выключен', style: TextStyle(color: !widget.state? AppColors.success : AppColors.error))
          //     ]
          //   )
          // ),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Интерфейс: ', style: TextStyle(color: AppColors.secondary)),
                TextSpan(text: widget.interface['name'])
              ]
            )
          ),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'ONT ID: ', style: TextStyle(color: AppColors.secondary)),
                TextSpan(text: widget.ontID.toString())
              ]
            )
          ),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'CATV ID: ', style: TextStyle(color: AppColors.secondary)),
                TextSpan(text: widget.catvID.toString())
              ]
            )
          ),
          if (!widget.isCustomerActive)
          const SizedBox(height: 5),
          if (!widget.isCustomerActive)
          const Text('Невозможно включить CATV: Абонент неактивный.', style: TextStyle(color: AppColors.error, fontSize: 15))
        ]
      ),
      actions: [
        TextButton(
          onPressed: _close,
          child: const Text('Нет')
        ),
        ElevatedButton(
          onPressed: widget.isCustomerActive? _toggle : null,
          child: toggling? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator()) : const Text('Да')
        )
      ],
    );
  }
}