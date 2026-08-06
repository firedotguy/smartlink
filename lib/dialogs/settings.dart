import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartlink/i18n.dart';
import 'package:smartlink/pages/login.dart';
import 'package:smartlink/theme.dart';
import 'package:smartlink/utils.dart';
import 'package:smartlink/widgets/app_chip.dart';
import 'package:smartlink/widgets/app_layout.dart';
import 'package:smartlink/widgets/info_tile.dart';

/// Диалог настроек SmartLink Viewer.
///
/// Открывается по кнопке «⚙️» в правом верхнем углу. Поддерживает:
///
/// - задержку перед поиском абонентов;
/// - тему оформления (в разработке);
/// - язык интерфейса (в разработке);
/// - выход из аккаунта.
class SettingsDialog extends StatefulWidget {
    const SettingsDialog({super.key});

    @override
    State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
    String theme = 'smartlink-dark';
    int debounce = 300;
    bool logined = false;

    final TextEditingController debounce_controller = TextEditingController(text: '0');
    bool debounce_error = false;
    bool changed = false;

    @override
    void initState() {
        super.initState();
        _load();
    }

    @override
    void dispose() {
        debounce_controller.dispose();
        super.dispose();
    }

    Future<void> _load() async {
        l.i('get settings');
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        l.i('available keys: ${prefs.getKeys()}');

        debounce = prefs.getInt('debounce') ?? 300;
        debounce_controller.text = debounce.toString();
        logined = (prefs.getString('login') ?? '') != '';
        setState(() {});
    }

    Future<void> _update_int(String key, int value) async {
        setState(() {
            changed = true;
        });
        l.i('update int setting $key to $value');
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt(key, value);
    }

    Future<void> _log_out() async {
        l.i('logging out');
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('login', '');
    }

    void _on_debounce_changed(String value) {
        final int? parsed = int.tryParse(value);

        if (parsed == null){
            setState(() {
                debounce_error = true;
            });
            return;
        }

        setState(() {
            debounce_error = false;
            debounce = parsed;
        });
        _update_int('debounce', parsed);
    }

    Widget _disabled_badge() => AppChip(text: t.settings.disabled, color: AppColors.error);

    @override
    Widget build(BuildContext context) {
        return AlertDialog(
            title: Text(t.settings.title),
            content: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 600),
                child: SelectionArea(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 10,
                        children: [
                            InfoTile(
                                title: t.settings.theme,
                                badge: _disabled_badge(),
                                child: IntrinsicWidth(
                                    child: DropdownButtonFormField<String>(
                                        initialValue: theme,
                                        items: const [
                                            DropdownMenuItem(value: 'smartlink-dark', child: Text('SmartLink (dark)')),
                                            DropdownMenuItem(value: 'smartlink-light', child: Text('SmartLink (light)', style: TextStyle(color: Color(0xFF121212), backgroundColor: Color(0xFFD1D5DC)))),
                                            DropdownMenuItem(value: 'smartlink-dark-high', child: Text('SmartLink (dark) high-contrast', style: TextStyle(color: Colors.white, backgroundColor: Colors.black))),
                                            DropdownMenuItem(value: 'smartlink-green', child: Text('SmartLink (green)', style: TextStyle(backgroundColor: Color(0xFF162515), color: Colors.white))),
                                            DropdownMenuItem(value: 'smartlink-red', child: Text('SmartLink (red)', style: TextStyle(backgroundColor: Color(0xFF251515), color: Colors.white))),
                                            DropdownMenuItem(value: 'userside', child: Text('UserSide', style: TextStyle(color: Colors.black, backgroundColor: Colors.white))),
                                            DropdownMenuItem(value: 'ember-dark', child: Text('Ember', style: TextStyle(color: Color(0xFFFBEADB), backgroundColor: Color(0xFF1E1C1A)))),
                                            DropdownMenuItem(value: 'dracula', child: Text('Dracula', style: TextStyle(color: Color(0xFFE3E2E9), backgroundColor: Color(0xFF0E0D11)))),
                                            DropdownMenuItem(value: 'monokai', child: Text('Monokai', style: TextStyle(color: Color(0xFFFCFCFA), backgroundColor: Color(0xFF221F22))))
                                        ],
                                        onChanged: null
                                    )
                                )
                            ),
                            InfoTile(
                                title: t.settings.language,
                                badge: _disabled_badge(),
                                child: IntrinsicWidth(
                                    child: DropdownButtonFormField<String>(
                                        initialValue: 'ru',
                                        items: [
                                            DropdownMenuItem(value: 'ru', child: Text(t.settings.language_ru)),
                                            DropdownMenuItem(value: 'ky', child: Text(t.settings.language_ky)),
                                            DropdownMenuItem(value: 'uz', child: Text(t.settings.language_uz)),
                                            DropdownMenuItem(value: 'en', child: Text(t.settings.language_en))
                                        ],
                                        onChanged: null
                                    )
                                )
                            ),
                            InfoTile(
                                title: t.settings.debounce,
                                hint: t.settings.debounce_hint,
                                child: SizedBox(
                                    width: 120,
                                    child: TextField(
                                        controller: debounce_controller,
                                        decoration: InputDecoration(
                                            hintText: t.settings.debounce_unit,
                                            errorText: debounce_error? t.settings.debounce_error : null
                                        ),
                                        onChanged: _on_debounce_changed
                                    )
                                )
                            ),
                            ElevatedButton.icon(
                                onPressed: logined? _on_log_out : null,
                                label: Text(t.settings.log_out),
                                icon: const Icon(Icons.logout)
                            ),

                            if (changed) ...[
                                const SizedBox(height: 10),
                                Text(t.settings.reload_required, style: const TextStyle(color: AppColors.warning))
                            ],
                            const SizedBox(height: 15)
                        ]
                    )
                )
            ),
            actions: [
                ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(t.common.ok)
                )
            ]
        );
    }

    void _on_log_out() async {
        await _log_out();
        if (!mounted) return;

        Navigator.pop(context);
        l.i('push to login page, reason: sign out');
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AppLayout(child: LoginPage()))
        );
        show_success(context, t.settings.logged_out);
    }
}
