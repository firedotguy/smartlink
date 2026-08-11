import 'package:smartlink/i18n/messages.i18n.dart';
import 'package:smartlink/i18n/messages_en.i18n.dart';

export 'package:smartlink/i18n/messages.i18n.dart';

/// Код языка -> название на нём же самом.
const Map<String, String> supported_locales = {
    'ru': 'Русский',
    // 'ky': 'Кыргызча',
    // 'uz': 'Uzbek',
    'en': 'English'
};

const String default_locale = 'ru';

Messages _messages = const Messages();
String current_locale = default_locale;

/// Текущие строки интерфейса.
Messages get t => _messages;

/// Применяется один раз при старте приложения.
void set_locale(String? code) {
    current_locale = supported_locales.containsKey(code)? code! : default_locale;

    _messages = switch (current_locale) {
        // 'ky' => MessagesKy(),
        'en' => const MessagesEn(),
        _ => const Messages()
    };
}
