import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:smartlink/i18n.dart';
import 'package:smartlink/theme.dart';
import 'package:url_launcher/url_launcher.dart';

/// Общий логгер приложения.
final Logger l = Logger(printer: SimplePrinter());

const String userside_host = 'https://us.neotelecom.kg';


// снекбары

/// Показывает снекбар с текстом [message], окрашенным в [color].
void show_snack(BuildContext context, String message, Color color, {bool replace = false}) {
    final messenger = ScaffoldMessenger.of(context);
    if (replace) messenger.removeCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message, style: TextStyle(color: color))));
}

void show_error(BuildContext context, String message, {bool replace = false}) =>
    show_snack(context, message, AppColors.error, replace: replace);

void show_warning(BuildContext context, String message, {bool replace = false}) =>
    show_snack(context, message, AppColors.warning, replace: replace);

void show_success(BuildContext context, String message, {bool replace = false}) =>
    show_snack(context, message, AppColors.success, replace: replace);


// ссылки

/// Собирает ссылку на объект в UserSide.
String userside_url(String type, int id) => '$userside_host/$type/$id';

/// Открывает [link] во внешнем браузере (или в текущей вкладке на web).
Future<void> open_url(BuildContext context, String link) async {
    final Uri url = Uri.parse(link);
    if (await canLaunchUrl(url)) {
        l.i('open link: $link');
        await launchUrl(url, mode: kIsWeb? LaunchMode.platformDefault : LaunchMode.externalApplication);
        return;
    }
    l.e('unclickable link: $link');
    if (context.mounted) show_error(context, t.common.link_not_clickable);
}

/// Открывает объект UserSide во внешнем браузере.
Future<void> open_in_userside(BuildContext context, String type, int id) async {
    await open_url(context, userside_url(type, id));
}

/// Копирует ссылку на объект UserSide в буфер обмена.
Future<void> copy_userside_link(BuildContext context, String type, int id) async {
    await Clipboard.setData(ClipboardData(text: userside_url(type, id)));
    if (context.mounted) show_success(context, t.common.link_copied);
}


// форматирование

/// Форматирует дату из API (`yyyy.MM.dd` или `yyyy.MM.dd HH:mm:ss`) в читаемый вид.
String format_date(String? input) {
    if (input == null || input.isEmpty) return t.common.empty;

    if (input.contains(' ')) {
        return DateFormat('d MMM yyyy HH:mm').format(DateFormat('yyyy.MM.dd HH:mm:ss').parse(input)).replaceAll('.', '');
    }
    return DateFormat('d MMM yyyy').format(DateFormat('yyyy.MM.dd').parse(input)).replaceAll('.', '');
}

/// Парсит дату из API, где разделителем даты выступает точка.
DateTime? parse_api_date(String? input) {
    if (input == null || input.isEmpty) return null;
    return DateTime.tryParse(input.replaceAll('.', '-'));
}

/// Убирает отчество из ФИО, оставляя фамилию и имя.
String? cut_last_name(String? full_name) {
    if (full_name == null) return null;

    final String trimmed = full_name.trim();
    final List<String> parts = trimmed.split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.length <= 2) return trimmed;

    return parts.sublist(0, parts.length - 1).join(' ');
}

/// Приводит уровень сигнала к положительному числу с одним знаком после запятой.
String convert_signal(num? signal) {
    if (signal == null) return t.common.empty;
    return (-signal.toDouble()).toStringAsFixed(1);
}

/// Человекочитаемый статус абонента.
String status_label(String? status) {
    return switch (status) {
        'active' => t.status.active,
        'pause' => t.status.paused,
        _ => t.status.inactive
    };
}

/// Человекочитаемый тип строения.
String building_type_label(String? type) {
    return switch (type) {
        'multiflat' => t.building.type_multiflat,
        'private' => t.building.type_private,
        'office' => t.building.type_office,
        'new' => t.building.type_new,
        'ravshan' => t.building.type_ravshan,
        _ => t.common.empty
    };
}

/// Человекочитаемый тип ТМЦ.
String item_type_label(String? type) {
    return switch (type) {
        'cable' => t.items.type_cable,
        'olt' => t.items.type_olt,
        'edfa' => t.items.type_edfa,
        'ont' => t.items.type_ont,
        'clamp' => t.items.type_clamp,
        'commutator' => t.items.type_commutator,
        'coupling' => t.items.type_coupling,
        'odf' => t.items.type_odf,
        'patchcord' => t.items.type_patchcord,
        'other' => t.items.type_other,
        'junction' => t.items.type_junction,
        'router' => t.items.type_router,
        'splitter' => t.items.type_splitter,
        'smart_home' => t.items.type_smart_home,
        'cisco' => t.items.type_cisco,
        'cambium' => t.items.type_cambium,
        _ => t.common.empty
    };
}

/// Человекочитаемое название типа задания.
String task_type_label(int type) {
    return switch (type) {
        37 => t.newTask.type_repair,
        60 => t.newTask.type_uninstall,
        46 => t.newTask.type_inactive,
        53 => t.newTask.type_ravshan,
        38 => t.newTask.type_building_repair,
        48 => t.newTask.type_building_mount,
        _ => t.common.empty
    };
}


// цвета по данным

Color get_task_status_color(int? status) {
    return switch (status) {
        18 => const Color(0xFFfff100),
        12 || 20 => const Color(0xFF00a650),
        3 || 17 => const Color(0xFF438ccb),
        15 => const Color(0xFFee1d24),
        14 || 11 => AppColors.secondary,
        1 => const Color(0xFFf7941d),
        10 => const Color(0xFFef6ea8),
        16 => const Color(0xFF00aeef),
        9 => const Color(0xFF00f000),

        _ => AppColors.main
    };
}

Color get_activity_color(String? last_activity) {
    final DateTime? parsed = parse_api_date(last_activity);
    if (parsed == null) return AppColors.secondary;

    return DateTime.now().difference(parsed).inMinutes <= 15? AppColors.success : AppColors.error;
}

Color get_disconnect_date_color(String? date) {
    final DateTime? parsed = parse_api_date(date);
    if (parsed == null) return AppColors.secondary;

    final int days = parsed.difference(DateTime.now()).inDays;
    if (days < 3) return AppColors.error;
    if (days < 10) return AppColors.warning;
    return AppColors.success;
}

Color get_status_color(String? status) {
    return switch (status) {
        'active' => AppColors.success,
        'pause' => AppColors.warning,
        'inactive' => AppColors.error,
        _ => AppColors.secondary
    };
}

Color get_signal_color(num? signal) {
    if (signal == null) return AppColors.main;
    if (signal > -25) return AppColors.success;
    if (signal > -27) return AppColors.warning;
    return AppColors.error;
}

Color get_balance_color(num balance) {
    if (balance > 0) return AppColors.success;
    if (balance < 0) return AppColors.error;
    return AppColors.main;
}

Color get_customer_border_color(Map? customer) {
    if (customer?['status'] == null) return AppColors.main;

    if (customer!['status'] == 'inactive' || get_activity_color(customer['last_active_at']) == AppColors.error) {
        return AppColors.error;
    }
    if (customer['status'] == 'pause') return AppColors.warning;
    return AppColors.success;
}

Color get_building_border_color(List<dynamic>? neighbours) {
    if (neighbours == null) return AppColors.main;
    if (neighbours.isEmpty) return AppColors.success;

    final bool all_inactive = neighbours.every((n) => get_activity_color(n['last_active_at']) == AppColors.error);
    return all_inactive? AppColors.error : AppColors.success;
}

Color get_task_border_color(List<Map>? tasks) {
    if (tasks == null) return AppColors.main;

    for (final Map task in tasks) {
        if (task['created_at'] == null || task['status']['id'] == 12 || task['status']['id'] == 10) continue;

        final DateTime? parsed = DateTime.tryParse(task['created_at']);
        if (parsed != null && DateTime.now().difference(parsed).inDays > 2) return AppColors.error;
    }
    return AppColors.success;
}

Color get_task_date_color(String? date, int? task_status) {
    if (task_status == 12 || task_status == 10) return AppColors.success;

    final DateTime? parsed = date == null? null : DateTime.tryParse(date);
    if (parsed == null) return AppColors.secondary;

    return DateTime.now().difference(parsed).inDays > 2? AppColors.error : AppColors.success;
}

/// Цвет уровня RX на ONT/OLT.
Color get_rx_color(double rx) {
    if (rx > -12) return AppColors.error;
    if (rx > -17) return AppColors.warning;
    if (rx > -25) return AppColors.success;
    if (rx > -27) return AppColors.warning;
    return AppColors.error;
}

/// Цвет уровня TX на ONT/OLT.
Color get_tx_color(double tx) {
    if (tx > 10) return AppColors.error;
    if (tx > 7) return AppColors.warning;
    if (tx >= -3) return AppColors.success;
    if (tx > -8) return AppColors.warning;
    return AppColors.error;
}

/// Цвет температуры ONT.
Color get_temp_color(int? temp) {
    if (temp == null) return AppColors.secondary;
    if (temp < 50) return AppColors.success;
    if (temp < 65) return AppColors.warning;
    return AppColors.error;
}
