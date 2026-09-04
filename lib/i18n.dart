import 'package:smartlink/i18n/messages.i18n.dart';
import 'package:smartlink/i18n/messages_ru.i18n.dart';

export 'package:smartlink/i18n/messages.i18n.dart';

const Map<String, String> supported_locales = {
    'ru': 'Русский',
    // 'ky': 'Кыргызча',
    // 'uz': 'Uzbek',
    'en': 'English'
};

const String default_locale = 'ru';

Messages _messages = const Messages();
String current_locale = default_locale;

Messages get t => _messages;

void set_locale(String? code) {
    current_locale = supported_locales.containsKey(code)? code! : default_locale;

    _messages = switch (current_locale) {
        // 'ky' => MessagesKy(),
        'ru' => const MessagesRu(),
        'en' => const Messages(),
        _ => const Messages()
    };
}
