// GENERATED FILE, do not edit!
// ignore_for_file: annotate_overrides, non_constant_identifier_names, prefer_single_quotes, unused_element, unused_field
import 'package:i18n/i18n.dart' as i18n;
import 'messages.i18n.dart';

String get _languageCode => 'ru';
String _plural(
  int count, {
  String? zero,
  String? one,
  String? two,
  String? few,
  String? many,
  String? other,
}) => i18n.plural(
  count,
  _languageCode,
  zero: zero,
  one: one,
  two: two,
  few: few,
  many: many,
  other: other,
);
String _ordinal(
  int count, {
  String? zero,
  String? one,
  String? two,
  String? few,
  String? many,
  String? other,
}) => i18n.ordinal(
  count,
  _languageCode,
  zero: zero,
  one: one,
  two: two,
  few: few,
  many: many,
  other: other,
);
String _cardinal(
  int count, {
  String? zero,
  String? one,
  String? two,
  String? few,
  String? many,
  String? other,
}) => i18n.cardinal(
  count,
  _languageCode,
  zero: zero,
  one: one,
  two: two,
  few: few,
  many: many,
  other: other,
);

class MessagesRu extends Messages {
  const MessagesRu();
  String get locale => "ru";
  String get languageCode => "ru";
  AppMessagesRu get app => AppMessagesRu(this);
  CommonMessagesRu get common => CommonMessagesRu(this);
  IncompatibleVersionMessagesRu get incompatibleVersion =>
      IncompatibleVersionMessagesRu(this);
  StatusMessagesRu get status => StatusMessagesRu(this);
  LoginMessagesRu get login => LoginMessagesRu(this);
  HomeMessagesRu get home => HomeMessagesRu(this);
  BuildingMessagesRu get building => BuildingMessagesRu(this);
  CustomerMessagesRu get customer => CustomerMessagesRu(this);
  TasksCardMessagesRu get tasksCard => TasksCardMessagesRu(this);
  ItemsMessagesRu get items => ItemsMessagesRu(this);
  OntMessagesRu get ont => OntMessagesRu(this);
  CatvMessagesRu get catv => CatvMessagesRu(this);
  TaskMessagesRu get task => TaskMessagesRu(this);
  TasksMessagesRu get tasks => TasksMessagesRu(this);
  NewTaskMessagesRu get newTask => NewTaskMessagesRu(this);
  SettingsMessagesRu get settings => SettingsMessagesRu(this);
  CustomerPhonesMessagesRu get customerPhones => CustomerPhonesMessagesRu(this);
}

class AppMessagesRu extends AppMessages {
  final MessagesRu _parent;
  const AppMessagesRu(this._parent) : super(_parent);

  /// ```dart
  /// "SmartLink"
  /// ```
  String get title => """SmartLink""";

  /// ```dart
  /// "SmartLinkViewer"
  /// ```
  String get name => """SmartLinkViewer""";

  /// ```dart
  /// "© 2026 «НеоТелеком»"
  /// ```
  String get legalese => """© 2026 «НеоТелеком»""";

  /// ```dart
  /// "WASM движок включен"
  /// ```
  String get renderer_warning => """WASM движок включен""";

  /// ```dart
  /// "Исходный код"
  /// ```
  String get source_code => """Исходный код""";

  /// ```dart
  /// "Исходный код API"
  /// ```
  String get api_source_code => """Исходный код API""";

  /// ```dart
  /// "v$version (API $api)"
  /// ```
  String version(String version, String api) => """v$version (API $api)""";

  /// ```dart
  /// "SmartLinkViewer v$version [γ]"
  /// ```
  String version_badge(String version) => """SmartLinkViewer v$version [γ]""";

  /// ```dart
  /// "Настройки"
  /// ```
  String get settings_tooltip => """Настройки""";
}

class CommonMessagesRu extends CommonMessages {
  final MessagesRu _parent;
  const CommonMessagesRu(this._parent) : super(_parent);

  /// ```dart
  /// "-"
  /// ```
  String get empty => """-""";

  /// ```dart
  /// "Ок"
  /// ```
  String get ok => """Ок""";

  /// ```dart
  /// "Отмена"
  /// ```
  String get cancel => """Отмена""";

  /// ```dart
  /// "Закрыть"
  /// ```
  String get close => """Закрыть""";

  /// ```dart
  /// "Закрыть диалог"
  /// ```
  String get close_dialog => """Закрыть диалог""";

  /// ```dart
  /// "Создать"
  /// ```
  String get create => """Создать""";

  /// ```dart
  /// "Обновить данные"
  /// ```
  String get refresh => """Обновить данные""";

  /// ```dart
  /// "Открыть в UserSide"
  /// ```
  String get open_in_userside => """Открыть в UserSide""";

  /// ```dart
  /// "Скопировать ссылку в UserSide"
  /// ```
  String get copy_userside_link => """Скопировать ссылку в UserSide""";

  /// ```dart
  /// "Ссылка скопирована"
  /// ```
  String get link_copied => """Ссылка скопирована""";

  /// ```dart
  /// "Preview"
  /// ```
  String get preview => """Preview""";

  /// ```dart
  /// "Функция в разработке"
  /// ```
  String get preview_tooltip => """Функция в разработке""";

  /// ```dart
  /// "$amount сом"
  /// ```
  String som(String amount) => """$amount сом""";

  /// ```dart
  /// "Ошибка открытия ссылки: Ссылка некликабельна"
  /// ```
  String get link_not_clickable =>
      """Ошибка открытия ссылки: Ссылка некликабельна""";

  /// ```dart
  /// "Нет соединения с сервером. Перезагрузите страницу."
  /// ```
  String get no_connection =>
      """Нет соединения с сервером. Перезагрузите страницу.""";

  /// ```dart
  /// "Технические работы. Часть функционала может не работать."
  /// ```
  String get dev_warning =>
      """Технические работы. Часть функционала может не работать.""";

  /// ```dart
  /// "Нестабильная версия. Возможны ошибки или неправильная работа части функционала."
  /// ```
  String get unstable_warning =>
      """Нестабильная версия. Возможны ошибки или неправильная работа части функционала.""";

  /// ```dart
  /// "На сайте проходят технические работы. Зайдите позже."
  /// ```
  String get force_dev =>
      """На сайте проходят технические работы. Зайдите позже.""";

  /// ```dart
  /// "Тех. работы"
  /// ```
  String get force_dev_title => """Тех. работы""";

  /// ```dart
  /// "Ошибка: $error"
  /// ```
  String error(String error) => """Ошибка: $error""";
}

class IncompatibleVersionMessagesRu extends IncompatibleVersionMessages {
  final MessagesRu _parent;
  const IncompatibleVersionMessagesRu(this._parent) : super(_parent);

  /// ```dart
  /// "Несовместимая версия"
  /// ```
  String get title => """Несовместимая версия""";

  /// ```dart
  /// "Обнаружена несовместимая версия API.\nЧтобы обновить версию, нажмите Ctrl+F5. Если это не помогло, сообщите админстратору."
  /// ```
  String get description =>
      """Обнаружена несовместимая версия API.\nЧтобы обновить версию, нажмите Ctrl+F5. Если это не помогло, сообщите админстратору.""";

  /// ```dart
  /// "Текущая версия"
  /// ```
  String get current => """Текущая версия""";

  /// ```dart
  /// "Требуемая версия"
  /// ```
  String get compatible => """Требуемая версия""";
}

class StatusMessagesRu extends StatusMessages {
  final MessagesRu _parent;
  const StatusMessagesRu(this._parent) : super(_parent);

  /// ```dart
  /// "Активен"
  /// ```
  String get active => """Активен""";

  /// ```dart
  /// "Пауза"
  /// ```
  String get paused => """Пауза""";

  /// ```dart
  /// "Отключен"
  /// ```
  String get inactive => """Отключен""";

  /// ```dart
  /// "Включен"
  /// ```
  String get enabled => """Включен""";

  /// ```dart
  /// "Выключен"
  /// ```
  String get disabled => """Выключен""";

  /// ```dart
  /// "Онлайн"
  /// ```
  String get online => """Онлайн""";

  /// ```dart
  /// "Оффлайн"
  /// ```
  String get offline => """Оффлайн""";

  /// ```dart
  /// "ONLINE"
  /// ```
  String get online_badge => """ONLINE""";

  /// ```dart
  /// "OFFLINE"
  /// ```
  String get offline_badge => """OFFLINE""";
}

class LoginMessagesRu extends LoginMessages {
  final MessagesRu _parent;
  const LoginMessagesRu(this._parent) : super(_parent);

  /// ```dart
  /// "Авторизация"
  /// ```
  String get title => """Авторизация""";

  /// ```dart
  /// "Логин"
  /// ```
  String get username => """Логин""";

  /// ```dart
  /// "Пароль"
  /// ```
  String get password => """Пароль""";

  /// ```dart
  /// "Войти"
  /// ```
  String get submit => """Войти""";

  /// ```dart
  /// "Успешная авторизация"
  /// ```
  String get success => """Успешная авторизация""";

  /// ```dart
  /// "Ошибка авторизации: неверный логин или пароль"
  /// ```
  String get wrong_credentials =>
      """Ошибка авторизации: неверный логин или пароль""";

  /// ```dart
  /// "Ошибка авторизации"
  /// ```
  String get error => """Ошибка авторизации""";
}

class HomeMessagesRu extends HomeMessages {
  final MessagesRu _parent;
  const HomeMessagesRu(this._parent) : super(_parent);

  /// ```dart
  /// "ФИО, ЛС, SN или телефон абонента"
  /// ```
  String get search_hint => """ФИО, ЛС, SN или телефон абонента""";

  /// ```dart
  /// "Нет результатов"
  /// ```
  String get no_results => """Нет результатов""";

  /// ```dart
  /// "Абонент не выбран"
  /// ```
  String get customer_not_selected => """Абонент не выбран""";

  /// ```dart
  /// "Ошибка получения абонентов"
  /// ```
  String get customers_error => """Ошибка получения абонентов""";

  /// ```dart
  /// "Ошибка: user id не найден"
  /// ```
  String get user_id_missing => """Ошибка: user id не найден""";

  /// ```dart
  /// "Ошибка получения данных абонента: $error"
  /// ```
  String customer_error(String error) =>
      """Ошибка получения данных абонента: $error""";

  /// ```dart
  /// "Ошибка получения данных коробки: $error"
  /// ```
  String building_error(String error) =>
      """Ошибка получения данных коробки: $error""";

  /// ```dart
  /// "Ошибка получения данных задания: $error"
  /// ```
  String tasks_error(String error) =>
      """Ошибка получения данных задания: $error""";

  /// ```dart
  /// "Ошибка получения данных оборудования: $error"
  /// ```
  String items_error(String error) =>
      """Ошибка получения данных оборудования: $error""";

  /// ```dart
  /// "Дождитесь загрузки абонента"
  /// ```
  String get wait_customer => """Дождитесь загрузки абонента""";

  /// ```dart
  /// "Абонент не загружен"
  /// ```
  String get customer_not_loaded => """Абонент не загружен""";

  /// ```dart
  /// "У абонента нет ТМЦ с SN"
  /// ```
  String get no_sn => """У абонента нет ТМЦ с SN""";

  /// ```dart
  /// "OLT не найден"
  /// ```
  String get no_olt => """OLT не найден""";
}

class BuildingMessagesRu extends BuildingMessages {
  final MessagesRu _parent;
  const BuildingMessagesRu(this._parent) : super(_parent);

  /// ```dart
  /// "Коробка"
  /// ```
  String get title => """Коробка""";

  /// ```dart
  /// "Коробка не найдена"
  /// ```
  String get not_found => """Коробка не найдена""";

  /// ```dart
  /// "Название"
  /// ```
  String get name => """Название""";

  /// ```dart
  /// "Тип"
  /// ```
  String get type => """Тип""";

  /// ```dart
  /// "Координаты"
  /// ```
  String get coordinates => """Координаты""";

  /// ```dart
  /// "Тип установки"
  /// ```
  String get install_type => """Тип установки""";

  /// ```dart
  /// "Статус строительства"
  /// ```
  String get build_status => """Статус строительства""";

  /// ```dart
  /// "Открытые задания"
  /// ```
  String get open_tasks => """Открытые задания""";

  /// ```dart
  /// "Создать задание (Магистральный ремонт)"
  /// ```
  String get new_task_tooltip => """Создать задание (Магистральный ремонт)""";

  /// ```dart
  /// "Показать на карте"
  /// ```
  String get show_on_map => """Показать на карте""";

  /// ```dart
  /// "Открыть коробку в UserSide"
  /// ```
  String get open_tooltip => """Открыть коробку в UserSide""";

  /// ```dart
  /// "Копировать ссылку на коробку в UserSide"
  /// ```
  String get copy_tooltip => """Копировать ссылку на коробку в UserSide""";

  /// ```dart
  /// "Многоквартирный дом"
  /// ```
  String get type_multiflat => """Многоквартирный дом""";

  /// ```dart
  /// "Частный дом"
  /// ```
  String get type_private => """Частный дом""";

  /// ```dart
  /// "Офисное здание"
  /// ```
  String get type_office => """Офисное здание""";

  /// ```dart
  /// "Новостройки"
  /// ```
  String get type_new => """Новостройки""";

  /// ```dart
  /// "Равшан"
  /// ```
  String get type_ravshan => """Равшан""";

  /// ```dart
  /// "Соседи"
  /// ```
  String get neighbours => """Соседи""";

  /// ```dart
  /// "У абонента нет соседей"
  /// ```
  String get no_neighbours => """У абонента нет соседей""";

  /// ```dart
  /// "ЛС"
  /// ```
  String get column_agreement => """ЛС""";

  /// ```dart
  /// "Имя"
  /// ```
  String get column_name => """Имя""";

  /// ```dart
  /// "Активность"
  /// ```
  String get column_activity => """Активность""";

  /// ```dart
  /// "Статус"
  /// ```
  String get column_status => """Статус""";

  /// ```dart
  /// "rx"
  /// ```
  String get column_rx => """rx""";
}

class CustomerMessagesRu extends CustomerMessages {
  final MessagesRu _parent;
  const CustomerMessagesRu(this._parent) : super(_parent);

  /// ```dart
  /// "Абонент"
  /// ```
  String get title => """Абонент""";

  /// ```dart
  /// "Открыть данные по ONT"
  /// ```
  String get ont_tooltip => """Открыть данные по ONT""";

  /// ```dart
  /// "Открыть вложения абонента и его заданий"
  /// ```
  String get attachs_tooltip => """Открыть вложения абонента и его заданий""";

  /// ```dart
  /// "Создать задание (Выезд на ремонт)"
  /// ```
  String get new_task_tooltip => """Создать задание (Выезд на ремонт)""";

  /// ```dart
  /// "Открыть абонента в UserSide"
  /// ```
  String get open_tooltip => """Открыть абонента в UserSide""";

  /// ```dart
  /// "Копировать ссылку на абонента в UserSide"
  /// ```
  String get copy_tooltip => """Копировать ссылку на абонента в UserSide""";

  /// ```dart
  /// "Потенциальный абонент"
  /// ```
  String get is_potential => """Потенциальный абонент""";

  /// ```dart
  /// "Юридическое лицо"
  /// ```
  String get is_corporate => """Юридическое лицо""";

  /// ```dart
  /// "Нет в биллинге"
  /// ```
  String get no_billing => """Нет в биллинге""";

  /// ```dart
  /// "Абонент не коммутирован"
  /// ```
  String get not_switched => """Абонент не коммутирован""";

  /// ```dart
  /// "Абонент отключен"
  /// ```
  String get is_inactive => """Абонент отключен""";

  /// ```dart
  /// "Абонент на паузе"
  /// ```
  String get is_paused => """Абонент на паузе""";

  /// ```dart
  /// "Последняя активность $when"
  /// ```
  String last_activity_warning(String when) => """Последняя активность $when""";

  /// ```dart
  /// "Проблемы в коробке"
  /// ```
  String get building_problems => """Проблемы в коробке""";

  /// ```dart
  /// "ФИО"
  /// ```
  String get name => """ФИО""";

  /// ```dart
  /// "Лицевой счёт"
  /// ```
  String get agreement => """Лицевой счёт""";

  /// ```dart
  /// "Баланс"
  /// ```
  String get balance => """Баланс""";

  /// ```dart
  /// "Статус"
  /// ```
  String get status => """Статус""";

  /// ```dart
  /// "Дата подключения"
  /// ```
  String get connected_at => """Дата подключения""";

  /// ```dart
  /// "Группа"
  /// ```
  String get group => """Группа""";

  /// ```dart
  /// "Последняя активность"
  /// ```
  String get last_activity => """Последняя активность""";

  /// ```dart
  /// "Номер телефона"
  /// ```
  String get phone => """Номер телефона""";

  /// ```dart
  /// "Номера телефонов"
  /// ```
  String get phones => """Номера телефонов""";

  /// ```dart
  /// "Тариф"
  /// ```
  String get tariff => """Тариф""";

  /// ```dart
  /// "Тарифы"
  /// ```
  String get tariffs => """Тарифы""";

  /// ```dart
  /// "Плановая дата отключения"
  /// ```
  String get will_disconnect_at => """Плановая дата отключения""";

  /// ```dart
  /// "Геоданные"
  /// ```
  String get geodata => """Геоданные""";

  /// ```dart
  /// "Адрес"
  /// ```
  String get address => """Адрес""";

  /// ```dart
  /// "Открыть в 2GIS"
  /// ```
  String get open_in_2gis => """Открыть в 2GIS""";

  /// ```dart
  /// "Открыть на карте Neotelecom"
  /// ```
  String get map_neotelecom => """Открыть на карте Neotelecom""";

  /// ```dart
  /// "Открыть на карте 2GIS"
  /// ```
  String get map_2gis => """Открыть на карте 2GIS""";

  /// ```dart
  /// "Координаты"
  /// ```
  String get coordinates => """Координаты""";

  /// ```dart
  /// "Подъезд"
  /// ```
  String get entrance => """Подъезд""";

  /// ```dart
  /// "Этаж"
  /// ```
  String get floor => """Этаж""";

  /// ```dart
  /// "Квартира"
  /// ```
  String get apartment => """Квартира""";
}

class TasksCardMessagesRu extends TasksCardMessages {
  final MessagesRu _parent;
  const TasksCardMessagesRu(this._parent) : super(_parent);

  /// ```dart
  /// "Задания абонента"
  /// ```
  String get title => """Задания абонента""";

  /// ```dart
  /// "У абонента нет заданий"
  /// ```
  String get empty => """У абонента нет заданий""";

  /// ```dart
  /// "ID"
  /// ```
  String get column_id => """ID""";

  /// ```dart
  /// "Тип задания"
  /// ```
  String get column_type => """Тип задания""";

  /// ```dart
  /// "Дата создания"
  /// ```
  String get column_created => """Дата создания""";

  /// ```dart
  /// "Статус"
  /// ```
  String get column_status => """Статус""";
}

class ItemsMessagesRu extends ItemsMessages {
  final MessagesRu _parent;
  const ItemsMessagesRu(this._parent) : super(_parent);

  /// ```dart
  /// "Оборудование"
  /// ```
  String get title => """Оборудование""";

  /// ```dart
  /// "У абонента нет оборудования"
  /// ```
  String get empty => """У абонента нет оборудования""";

  /// ```dart
  /// "Название"
  /// ```
  String get column_name => """Название""";

  /// ```dart
  /// "Тип"
  /// ```
  String get column_type => """Тип""";

  /// ```dart
  /// "SN"
  /// ```
  String get column_sn => """SN""";

  /// ```dart
  /// "Количество"
  /// ```
  String get column_amount => """Количество""";

  /// ```dart
  /// "Кабель"
  /// ```
  String get type_cable => """Кабель""";

  /// ```dart
  /// "OLT"
  /// ```
  String get type_olt => """OLT""";

  /// ```dart
  /// "EDFA"
  /// ```
  String get type_edfa => """EDFA""";

  /// ```dart
  /// "ONT"
  /// ```
  String get type_ont => """ONT""";

  /// ```dart
  /// "Зажим"
  /// ```
  String get type_clamp => """Зажим""";

  /// ```dart
  /// "Коммутатор"
  /// ```
  String get type_commutator => """Коммутатор""";

  /// ```dart
  /// "Муфта"
  /// ```
  String get type_coupling => """Муфта""";

  /// ```dart
  /// "ODF"
  /// ```
  String get type_odf => """ODF""";

  /// ```dart
  /// "Патчкорд"
  /// ```
  String get type_patchcord => """Патчкорд""";

  /// ```dart
  /// "Прочее"
  /// ```
  String get type_other => """Прочее""";

  /// ```dart
  /// "Распред. коробка"
  /// ```
  String get type_junction => """Распред. коробка""";

  /// ```dart
  /// "Роутер"
  /// ```
  String get type_router => """Роутер""";

  /// ```dart
  /// "Разделитель"
  /// ```
  String get type_splitter => """Разделитель""";

  /// ```dart
  /// "Умный дом"
  /// ```
  String get type_smart_home => """Умный дом""";

  /// ```dart
  /// "Cisco"
  /// ```
  String get type_cisco => """Cisco""";

  /// ```dart
  /// "Cambium"
  /// ```
  String get type_cambium => """Cambium""";
}

class OntMessagesRu extends OntMessages {
  final MessagesRu _parent;
  const OntMessagesRu(this._parent) : super(_parent);

  /// ```dart
  /// "ONT / OLT"
  /// ```
  String get title => """ONT / OLT""";

  /// ```dart
  /// "OLT"
  /// ```
  String get section_olt => """OLT""";

  /// ```dart
  /// "ONT"
  /// ```
  String get section_ont => """ONT""";

  /// ```dart
  /// "CATV"
  /// ```
  String get section_catv => """CATV""";

  /// ```dart
  /// "ETH/LAN"
  /// ```
  String get section_eth => """ETH/LAN""";

  /// ```dart
  /// "Перезагрузить ONT"
  /// ```
  String get restart => """Перезагрузить ONT""";

  /// ```dart
  /// "Перезаписать SN"
  /// ```
  String get rewrite_sn => """Перезаписать SN""";

  /// ```dart
  /// "Перезаписать MAC"
  /// ```
  String get rewrite_mac => """Перезаписать MAC""";

  /// ```dart
  /// "Ошибка получения данных ONT: $error"
  /// ```
  String load_error(String error) => """Ошибка получения данных ONT: $error""";

  /// ```dart
  /// "Ошибка перезапуска ONT: $error"
  /// ```
  String restart_error(String error) => """Ошибка перезапуска ONT: $error""";

  /// ```dart
  /// "Ошибка перезапуска ONT"
  /// ```
  String get restart_failed => """Ошибка перезапуска ONT""";

  /// ```dart
  /// "ONT перезапущен"
  /// ```
  String get restarted => """ONT перезапущен""";

  /// ```dart
  /// "Ошибка перезаписи SN: $error"
  /// ```
  String rewrite_sn_error(String error) => """Ошибка перезаписи SN: $error""";

  /// ```dart
  /// "Ошибка перезаписи SN"
  /// ```
  String get rewrite_sn_failed => """Ошибка перезаписи SN""";

  /// ```dart
  /// "SN перезаписан"
  /// ```
  String get sn_rewritten => """SN перезаписан""";

  /// ```dart
  /// "Ошибка перезаписи MAC: $error"
  /// ```
  String rewrite_mac_error(String error) => """Ошибка перезаписи MAC: $error""";

  /// ```dart
  /// "Ошибка перезаписи MAC"
  /// ```
  String get rewrite_mac_failed => """Ошибка перезаписи MAC""";

  /// ```dart
  /// "MAC перезаписан"
  /// ```
  String get mac_rewritten => """MAC перезаписан""";

  /// ```dart
  /// "Имя"
  /// ```
  String get olt_name => """Имя""";

  /// ```dart
  /// "Локация"
  /// ```
  String get olt_location => """Локация""";

  /// ```dart
  /// "SN"
  /// ```
  String get sn => """SN""";

  /// ```dart
  /// "IP"
  /// ```
  String get ip => """IP""";

  /// ```dart
  /// "Аптайм"
  /// ```
  String get uptime => """Аптайм""";

  /// ```dart
  /// "Дистанция"
  /// ```
  String get distance => """Дистанция""";

  /// ```dart
  /// "Последнее включение"
  /// ```
  String get last_up => """Последнее включение""";

  /// ```dart
  /// "Последнее отключение"
  /// ```
  String get last_down => """Последнее отключение""";

  /// ```dart
  /// "Причина отключения"
  /// ```
  String get last_down_cause => """Причина отключения""";

  /// ```dart
  /// "RX (dBm)"
  /// ```
  String get rx => """RX (dBm)""";

  /// ```dart
  /// "TX (dBm)"
  /// ```
  String get tx => """TX (dBm)""";

  /// ```dart
  /// "Температура"
  /// ```
  String get temperature => """Температура""";

  /// ```dart
  /// "км"
  /// ```
  String get kilometers => """км""";

  /// ```dart
  /// "мс"
  /// ```
  String get milliseconds => """мс""";

  /// ```dart
  /// "Нет CATV портов"
  /// ```
  String get no_catv_ports => """Нет CATV портов""";

  /// ```dart
  /// "Нет ETH портов"
  /// ```
  String get no_eth_ports => """Нет ETH портов""";

  /// ```dart
  /// "Порт $id"
  /// ```
  String port(String id) => """Порт $id""";

  /// ```dart
  /// "Не работает"
  /// ```
  String get port_broken => """Не работает""";

  /// ```dart
  /// "Отключен"
  /// ```
  String get port_shutdown => """Отключен""";

  /// ```dart
  /// "$speed МБит/c  $duplex"
  /// ```
  String port_speed(String speed, String duplex) =>
      """$speed МБит/c  $duplex""";

  /// ```dart
  /// """
  /// Состояние: $state
  /// Статус: $actual
  /// """
  /// ```
  String catv_tooltip(String state, String actual) => """Состояние: $state
Статус: $actual""";

  /// ```dart
  /// """
  /// Состояние: $state
  /// Статус: $actual
  /// Скорость: $speed Мбит/c
  /// Дуплекс: $duplex
  /// """
  /// ```
  String eth_tooltip(
    String state,
    String actual,
    String speed,
    String duplex,
  ) =>
      """Состояние: $state
Статус: $actual
Скорость: $speed Мбит/c
Дуплекс: $duplex""";

  /// ```dart
  /// "Двойной"
  /// ```
  String get eth_duplex_full => """Двойной""";

  /// ```dart
  /// "Одинарный"
  /// ```
  String get eth_duplex_half => """Одинарный""";

  /// ```dart
  /// "Неизвестно"
  /// ```
  String get eth_duplex_neg => """Неизвестно""";

  /// ```dart
  /// "$relative ($absolute)"
  /// ```
  String relative_date(String relative, String absolute) =>
      """$relative ($absolute)""";

  /// ```dart
  /// "Невозможно пингануть соседа: Коробка не найдена или в ней нету активных абонентов"
  /// ```
  String get neighbour_not_found =>
      """Невозможно пингануть соседа: Коробка не найдена или в ней нету активных абонентов""";

  /// ```dart
  /// "Невозможно пингануть соседа: IP не найден"
  /// ```
  String get neighbour_has_not_ip =>
      """Невозможно пингануть соседа: IP не найден""";

  /// ```dart
  /// "Пинг"
  /// ```
  String get ping => """Пинг""";

  /// ```dart
  /// "Этот ONT"
  /// ```
  String get this_ont => """Этот ONT""";

  /// ```dart
  /// "Соседский ONT"
  /// ```
  String get neighbour_ont => """Соседский ONT""";

  /// ```dart
  /// "OLT"
  /// ```
  String get olt => """OLT""";
}

class CatvMessagesRu extends CatvMessages {
  final MessagesRu _parent;
  const CatvMessagesRu(this._parent) : super(_parent);

  /// ```dart
  /// "Включение CATV"
  /// ```
  String get enable_title => """Включение CATV""";

  /// ```dart
  /// "Выключение CATV"
  /// ```
  String get disable_title => """Выключение CATV""";

  /// ```dart
  /// "Вы уверены что хотите включить CATV?"
  /// ```
  String get enable_confirm => """Вы уверены что хотите включить CATV?""";

  /// ```dart
  /// "Вы уверены что хотите выключить CATV?"
  /// ```
  String get disable_confirm => """Вы уверены что хотите выключить CATV?""";

  /// ```dart
  /// "Переключить состояние"
  /// ```
  String get toggle_tooltip => """Переключить состояние""";

  /// ```dart
  /// "Состояние порта"
  /// ```
  String get port_state => """Состояние порта""";

  /// ```dart
  /// "SN"
  /// ```
  String get sn => """SN""";

  /// ```dart
  /// "OLT ID"
  /// ```
  String get olt_id => """OLT ID""";

  /// ```dart
  /// "CATV ID"
  /// ```
  String get catv_id => """CATV ID""";

  /// ```dart
  /// "Невозможно включить CATV: Абонент неактивный."
  /// ```
  String get customer_inactive =>
      """Невозможно включить CATV: Абонент неактивный.""";

  /// ```dart
  /// "Включить"
  /// ```
  String get enable => """Включить""";

  /// ```dart
  /// "Выключить"
  /// ```
  String get disable => """Выключить""";

  /// ```dart
  /// "CATV успешно переключен"
  /// ```
  String get toggled => """CATV успешно переключен""";

  /// ```dart
  /// "Ошибка переключения CATV: $error"
  /// ```
  String toggle_error(String error) => """Ошибка переключения CATV: $error""";

  /// ```dart
  /// "Ошибка переключения CATV"
  /// ```
  String get toggle_failed => """Ошибка переключения CATV""";
}

class TaskMessagesRu extends TaskMessages {
  final MessagesRu _parent;
  const TaskMessagesRu(this._parent) : super(_parent);

  /// ```dart
  /// "Задание"
  /// ```
  String get title => """Задание""";

  /// ```dart
  /// "Скопировать ссылку на задание в UserSide"
  /// ```
  String get copy_tooltip => """Скопировать ссылку на задание в UserSide""";

  /// ```dart
  /// "Ошибка загрузки задания: $error"
  /// ```
  String load_error(String error) => """Ошибка загрузки задания: $error""";

  /// ```dart
  /// "Ошибка отправки комментария: $error"
  /// ```
  String comment_error(String error) =>
      """Ошибка отправки комментария: $error""";

  /// ```dart
  /// "Основные данные"
  /// ```
  String get section_main => """Основные данные""";

  /// ```dart
  /// "Комментарии"
  /// ```
  String get section_comments => """Комментарии""";

  /// ```dart
  /// "Тип"
  /// ```
  String get type => """Тип""";

  /// ```dart
  /// "Статус"
  /// ```
  String get status => """Статус""";

  /// ```dart
  /// "Адрес"
  /// ```
  String get address => """Адрес""";

  /// ```dart
  /// "Автор задания"
  /// ```
  String get author => """Автор задания""";

  /// ```dart
  /// "Назначенные сотрудники"
  /// ```
  String get employees => """Назначенные сотрудники""";

  /// ```dart
  /// "Назначенные бригады"
  /// ```
  String get divisions => """Назначенные бригады""";

  /// ```dart
  /// "Причина"
  /// ```
  String get appeal_reason => """Причина""";

  /// ```dart
  /// "Решение"
  /// ```
  String get solve => """Решение""";

  /// ```dart
  /// "Телефон обратившегося"
  /// ```
  String get appeal_phone => """Телефон обратившегося""";

  /// ```dart
  /// "Тип обращения"
  /// ```
  String get appeal_type => """Тип обращения""";

  /// ```dart
  /// "Стоимость работ"
  /// ```
  String get price => """Стоимость работ""";

  /// ```dart
  /// "Тариф"
  /// ```
  String get tariff => """Тариф""";

  /// ```dart
  /// "Координаты"
  /// ```
  String get coordinates => """Координаты""";

  /// ```dart
  /// "Тип подключения"
  /// ```
  String get connect_type => """Тип подключения""";

  /// ```dart
  /// "Дата создания"
  /// ```
  String get created_at => """Дата создания""";

  /// ```dart
  /// "Дата обновления"
  /// ```
  String get updated_at => """Дата обновления""";

  /// ```dart
  /// "Плановая дата выполнения"
  /// ```
  String get planned_to => """Плановая дата выполнения""";

  /// ```dart
  /// "Дата выполнения"
  /// ```
  String get completed_at => """Дата выполнения""";

  /// ```dart
  /// "Комментариев нет"
  /// ```
  String get no_comments => """Комментариев нет""";

  /// ```dart
  /// "Написать комментарий..."
  /// ```
  String get comment_hint => """Написать комментарий...""";

  /// ```dart
  /// "Отправить"
  /// ```
  String get send => """Отправить""";

  /// ```dart
  /// "только что"
  /// ```
  String get just_now => """только что""";
}

class TasksMessagesRu extends TasksMessages {
  final MessagesRu _parent;
  const TasksMessagesRu(this._parent) : super(_parent);

  /// ```dart
  /// "Задания"
  /// ```
  String get title => """Задания""";

  /// ```dart
  /// "Нет заданий"
  /// ```
  String get empty => """Нет заданий""";

  /// ```dart
  /// "ID: $id"
  /// ```
  String id(String id) => """ID: $id""";

  /// ```dart
  /// "Создано: $date"
  /// ```
  String created(String date) => """Создано: $date""";

  /// ```dart
  /// "Выполнено: $date"
  /// ```
  String completed(String date) => """Выполнено: $date""";

  /// ```dart
  /// "Автор: $name"
  /// ```
  String author(String name) => """Автор: $name""";
}

class NewTaskMessagesRu extends NewTaskMessages {
  final MessagesRu _parent;
  const NewTaskMessagesRu(this._parent) : super(_parent);

  /// ```dart
  /// "Создать задание"
  /// ```
  String get title => """Создать задание""";

  /// ```dart
  /// "Ремонт"
  /// ```
  String get tab_repair => """Ремонт""";

  /// ```dart
  /// "Магистральный ремонт"
  /// ```
  String get tab_building => """Магистральный ремонт""";

  /// ```dart
  /// "Ошибка загрузки данных"
  /// ```
  String get load_error => """Ошибка загрузки данных""";

  /// ```dart
  /// "Задание создано"
  /// ```
  String get created => """Задание создано""";

  /// ```dart
  /// "Ошибка при создании задания"
  /// ```
  String get create_error => """Ошибка при создании задания""";

  /// ```dart
  /// "Тип задания"
  /// ```
  String get type => """Тип задания""";

  /// ```dart
  /// "Выезд на ремонт"
  /// ```
  String get type_repair => """Выезд на ремонт""";

  /// ```dart
  /// "Демонтаж оборудование"
  /// ```
  String get type_uninstall => """Демонтаж оборудование""";

  /// ```dart
  /// "Выезд к неактивным абонентам"
  /// ```
  String get type_inactive => """Выезд к неактивным абонентам""";

  /// ```dart
  /// "Выезд на ремонт (Равшан)"
  /// ```
  String get type_ravshan => """Выезд на ремонт (Равшан)""";

  /// ```dart
  /// "Магистраль выезд на ремонт"
  /// ```
  String get type_building_repair => """Магистраль выезд на ремонт""";

  /// ```dart
  /// "Магистраль-демонтаж/монтаж"
  /// ```
  String get type_building_mount => """Магистраль-демонтаж/монтаж""";

  /// ```dart
  /// "Номер телефона обратившегося"
  /// ```
  String get phone => """Номер телефона обратившегося""";

  /// ```dart
  /// "Введите номер телефона"
  /// ```
  String get phone_hint => """Введите номер телефона""";

  /// ```dart
  /// "или выберите из следующих"
  /// ```
  String get phone_choose => """или выберите из следующих""";

  /// ```dart
  /// "Причина обращения"
  /// ```
  String get reason => """Причина обращения""";

  /// ```dart
  /// "Тип обращения"
  /// ```
  String get appeal_type => """Тип обращения""";

  /// ```dart
  /// "Описание"
  /// ```
  String get description => """Описание""";

  /// ```dart
  /// "Введите описание (необязательно)"
  /// ```
  String get description_hint => """Введите описание (необязательно)""";

  /// ```dart
  /// "Исполнители"
  /// ```
  String get executors => """Исполнители""";

  /// ```dart
  /// "Коробка не найдена"
  /// ```
  String get no_building => """Коробка не найдена""";

  /// ```dart
  /// "Если коробка существует, дождитесь загрузки данных и переоткройте диалог"
  /// ```
  String get no_building_hint =>
      """Если коробка существует, дождитесь загрузки данных и переоткройте диалог""";

  /// ```dart
  /// "Не выполнено"
  /// ```
  String get default_status => """Не выполнено""";
}

class SettingsMessagesRu extends SettingsMessages {
  final MessagesRu _parent;
  const SettingsMessagesRu(this._parent) : super(_parent);

  /// ```dart
  /// "Настройки"
  /// ```
  String get title => """Настройки""";

  /// ```dart
  /// "Тема"
  /// ```
  String get theme => """Тема""";

  /// ```dart
  /// "Язык"
  /// ```
  String get language => """Язык""";

  /// ```dart
  /// "Отключено"
  /// ```
  String get disabled => """Отключено""";

  /// ```dart
  /// "Задержка при вводе"
  /// ```
  String get debounce => """Задержка при вводе""";

  /// ```dart
  /// "Время ожидания после поиска перед загрузкой абонентов"
  /// ```
  String get debounce_hint =>
      """Время ожидания после поиска перед загрузкой абонентов""";

  /// ```dart
  /// "мс"
  /// ```
  String get debounce_unit => """мс""";

  /// ```dart
  /// "Неправильное значение"
  /// ```
  String get debounce_error => """Неправильное значение""";

  /// ```dart
  /// "Выйти из аккаунта"
  /// ```
  String get log_out => """Выйти из аккаунта""";

  /// ```dart
  /// "Вы вышли из аккаунта"
  /// ```
  String get logged_out => """Вы вышли из аккаунта""";

  /// ```dart
  /// "Для применения изменений перезагрузите страницу"
  /// ```
  String get reload_required =>
      """Для применения изменений перезагрузите страницу""";
}

class CustomerPhonesMessagesRu extends CustomerPhonesMessages {
  final MessagesRu _parent;
  const CustomerPhonesMessagesRu(this._parent) : super(_parent);

  /// ```dart
  /// "Телефоны абонента"
  /// ```
  String get title => """Телефоны абонента""";

  /// ```dart
  /// "Основной номер телефона"
  /// ```
  String get main => """Основной номер телефона""";

  /// ```dart
  /// "Дополнительный номер телефона"
  /// ```
  String get additional => """Дополнительный номер телефона""";

  /// ```dart
  /// "Сохранить"
  /// ```
  String get save => """Сохранить""";
}

Map<String, String> get messagesRuMap => {
  """app.title""": """SmartLink""",
  """app.name""": """SmartLinkViewer""",
  """app.legalese""": """© 2026 «НеоТелеком»""",
  """app.renderer_warning""": """WASM движок включен""",
  """app.source_code""": """Исходный код""",
  """app.api_source_code""": """Исходный код API""",
  """app.settings_tooltip""": """Настройки""",
  """common.empty""": """-""",
  """common.ok""": """Ок""",
  """common.cancel""": """Отмена""",
  """common.close""": """Закрыть""",
  """common.close_dialog""": """Закрыть диалог""",
  """common.create""": """Создать""",
  """common.refresh""": """Обновить данные""",
  """common.open_in_userside""": """Открыть в UserSide""",
  """common.copy_userside_link""": """Скопировать ссылку в UserSide""",
  """common.link_copied""": """Ссылка скопирована""",
  """common.preview""": """Preview""",
  """common.preview_tooltip""": """Функция в разработке""",
  """common.link_not_clickable""":
      """Ошибка открытия ссылки: Ссылка некликабельна""",
  """common.no_connection""":
      """Нет соединения с сервером. Перезагрузите страницу.""",
  """common.dev_warning""":
      """Технические работы. Часть функционала может не работать.""",
  """common.unstable_warning""":
      """Нестабильная версия. Возможны ошибки или неправильная работа части функционала.""",
  """common.force_dev""":
      """На сайте проходят технические работы. Зайдите позже.""",
  """common.force_dev_title""": """Тех. работы""",
  """incompatibleVersion.title""": """Несовместимая версия""",
  """incompatibleVersion.description""":
      """Обнаружена несовместимая версия API.\nЧтобы обновить версию, нажмите Ctrl+F5. Если это не помогло, сообщите админстратору.""",
  """incompatibleVersion.current""": """Текущая версия""",
  """incompatibleVersion.compatible""": """Требуемая версия""",
  """status.active""": """Активен""",
  """status.paused""": """Пауза""",
  """status.inactive""": """Отключен""",
  """status.enabled""": """Включен""",
  """status.disabled""": """Выключен""",
  """status.online""": """Онлайн""",
  """status.offline""": """Оффлайн""",
  """status.online_badge""": """ONLINE""",
  """status.offline_badge""": """OFFLINE""",
  """login.title""": """Авторизация""",
  """login.username""": """Логин""",
  """login.password""": """Пароль""",
  """login.submit""": """Войти""",
  """login.success""": """Успешная авторизация""",
  """login.wrong_credentials""":
      """Ошибка авторизации: неверный логин или пароль""",
  """login.error""": """Ошибка авторизации""",
  """home.search_hint""": """ФИО, ЛС, SN или телефон абонента""",
  """home.no_results""": """Нет результатов""",
  """home.customer_not_selected""": """Абонент не выбран""",
  """home.customers_error""": """Ошибка получения абонентов""",
  """home.user_id_missing""": """Ошибка: user id не найден""",
  """home.wait_customer""": """Дождитесь загрузки абонента""",
  """home.customer_not_loaded""": """Абонент не загружен""",
  """home.no_sn""": """У абонента нет ТМЦ с SN""",
  """home.no_olt""": """OLT не найден""",
  """building.title""": """Коробка""",
  """building.not_found""": """Коробка не найдена""",
  """building.name""": """Название""",
  """building.type""": """Тип""",
  """building.coordinates""": """Координаты""",
  """building.install_type""": """Тип установки""",
  """building.build_status""": """Статус строительства""",
  """building.open_tasks""": """Открытые задания""",
  """building.new_task_tooltip""": """Создать задание (Магистральный ремонт)""",
  """building.show_on_map""": """Показать на карте""",
  """building.open_tooltip""": """Открыть коробку в UserSide""",
  """building.copy_tooltip""": """Копировать ссылку на коробку в UserSide""",
  """building.type_multiflat""": """Многоквартирный дом""",
  """building.type_private""": """Частный дом""",
  """building.type_office""": """Офисное здание""",
  """building.type_new""": """Новостройки""",
  """building.type_ravshan""": """Равшан""",
  """building.neighbours""": """Соседи""",
  """building.no_neighbours""": """У абонента нет соседей""",
  """building.column_agreement""": """ЛС""",
  """building.column_name""": """Имя""",
  """building.column_activity""": """Активность""",
  """building.column_status""": """Статус""",
  """building.column_rx""": """rx""",
  """customer.title""": """Абонент""",
  """customer.ont_tooltip""": """Открыть данные по ONT""",
  """customer.attachs_tooltip""": """Открыть вложения абонента и его заданий""",
  """customer.new_task_tooltip""": """Создать задание (Выезд на ремонт)""",
  """customer.open_tooltip""": """Открыть абонента в UserSide""",
  """customer.copy_tooltip""": """Копировать ссылку на абонента в UserSide""",
  """customer.is_potential""": """Потенциальный абонент""",
  """customer.is_corporate""": """Юридическое лицо""",
  """customer.no_billing""": """Нет в биллинге""",
  """customer.not_switched""": """Абонент не коммутирован""",
  """customer.is_inactive""": """Абонент отключен""",
  """customer.is_paused""": """Абонент на паузе""",
  """customer.building_problems""": """Проблемы в коробке""",
  """customer.name""": """ФИО""",
  """customer.agreement""": """Лицевой счёт""",
  """customer.balance""": """Баланс""",
  """customer.status""": """Статус""",
  """customer.connected_at""": """Дата подключения""",
  """customer.group""": """Группа""",
  """customer.last_activity""": """Последняя активность""",
  """customer.phone""": """Номер телефона""",
  """customer.phones""": """Номера телефонов""",
  """customer.tariff""": """Тариф""",
  """customer.tariffs""": """Тарифы""",
  """customer.will_disconnect_at""": """Плановая дата отключения""",
  """customer.geodata""": """Геоданные""",
  """customer.address""": """Адрес""",
  """customer.open_in_2gis""": """Открыть в 2GIS""",
  """customer.map_neotelecom""": """Открыть на карте Neotelecom""",
  """customer.map_2gis""": """Открыть на карте 2GIS""",
  """customer.coordinates""": """Координаты""",
  """customer.entrance""": """Подъезд""",
  """customer.floor""": """Этаж""",
  """customer.apartment""": """Квартира""",
  """tasksCard.title""": """Задания абонента""",
  """tasksCard.empty""": """У абонента нет заданий""",
  """tasksCard.column_id""": """ID""",
  """tasksCard.column_type""": """Тип задания""",
  """tasksCard.column_created""": """Дата создания""",
  """tasksCard.column_status""": """Статус""",
  """items.title""": """Оборудование""",
  """items.empty""": """У абонента нет оборудования""",
  """items.column_name""": """Название""",
  """items.column_type""": """Тип""",
  """items.column_sn""": """SN""",
  """items.column_amount""": """Количество""",
  """items.type_cable""": """Кабель""",
  """items.type_olt""": """OLT""",
  """items.type_edfa""": """EDFA""",
  """items.type_ont""": """ONT""",
  """items.type_clamp""": """Зажим""",
  """items.type_commutator""": """Коммутатор""",
  """items.type_coupling""": """Муфта""",
  """items.type_odf""": """ODF""",
  """items.type_patchcord""": """Патчкорд""",
  """items.type_other""": """Прочее""",
  """items.type_junction""": """Распред. коробка""",
  """items.type_router""": """Роутер""",
  """items.type_splitter""": """Разделитель""",
  """items.type_smart_home""": """Умный дом""",
  """items.type_cisco""": """Cisco""",
  """items.type_cambium""": """Cambium""",
  """ont.title""": """ONT / OLT""",
  """ont.section_olt""": """OLT""",
  """ont.section_ont""": """ONT""",
  """ont.section_catv""": """CATV""",
  """ont.section_eth""": """ETH/LAN""",
  """ont.restart""": """Перезагрузить ONT""",
  """ont.rewrite_sn""": """Перезаписать SN""",
  """ont.rewrite_mac""": """Перезаписать MAC""",
  """ont.restart_failed""": """Ошибка перезапуска ONT""",
  """ont.restarted""": """ONT перезапущен""",
  """ont.rewrite_sn_failed""": """Ошибка перезаписи SN""",
  """ont.sn_rewritten""": """SN перезаписан""",
  """ont.rewrite_mac_failed""": """Ошибка перезаписи MAC""",
  """ont.mac_rewritten""": """MAC перезаписан""",
  """ont.olt_name""": """Имя""",
  """ont.olt_location""": """Локация""",
  """ont.sn""": """SN""",
  """ont.ip""": """IP""",
  """ont.uptime""": """Аптайм""",
  """ont.distance""": """Дистанция""",
  """ont.last_up""": """Последнее включение""",
  """ont.last_down""": """Последнее отключение""",
  """ont.last_down_cause""": """Причина отключения""",
  """ont.rx""": """RX (dBm)""",
  """ont.tx""": """TX (dBm)""",
  """ont.temperature""": """Температура""",
  """ont.kilometers""": """км""",
  """ont.milliseconds""": """мс""",
  """ont.no_catv_ports""": """Нет CATV портов""",
  """ont.no_eth_ports""": """Нет ETH портов""",
  """ont.port_broken""": """Не работает""",
  """ont.port_shutdown""": """Отключен""",
  """ont.eth_duplex_full""": """Двойной""",
  """ont.eth_duplex_half""": """Одинарный""",
  """ont.eth_duplex_neg""": """Неизвестно""",
  """ont.neighbour_not_found""":
      """Невозможно пингануть соседа: Коробка не найдена или в ней нету активных абонентов""",
  """ont.neighbour_has_not_ip""":
      """Невозможно пингануть соседа: IP не найден""",
  """ont.ping""": """Пинг""",
  """ont.this_ont""": """Этот ONT""",
  """ont.neighbour_ont""": """Соседский ONT""",
  """ont.olt""": """OLT""",
  """catv.enable_title""": """Включение CATV""",
  """catv.disable_title""": """Выключение CATV""",
  """catv.enable_confirm""": """Вы уверены что хотите включить CATV?""",
  """catv.disable_confirm""": """Вы уверены что хотите выключить CATV?""",
  """catv.toggle_tooltip""": """Переключить состояние""",
  """catv.port_state""": """Состояние порта""",
  """catv.sn""": """SN""",
  """catv.olt_id""": """OLT ID""",
  """catv.catv_id""": """CATV ID""",
  """catv.customer_inactive""":
      """Невозможно включить CATV: Абонент неактивный.""",
  """catv.enable""": """Включить""",
  """catv.disable""": """Выключить""",
  """catv.toggled""": """CATV успешно переключен""",
  """catv.toggle_failed""": """Ошибка переключения CATV""",
  """task.title""": """Задание""",
  """task.copy_tooltip""": """Скопировать ссылку на задание в UserSide""",
  """task.section_main""": """Основные данные""",
  """task.section_comments""": """Комментарии""",
  """task.type""": """Тип""",
  """task.status""": """Статус""",
  """task.address""": """Адрес""",
  """task.author""": """Автор задания""",
  """task.employees""": """Назначенные сотрудники""",
  """task.divisions""": """Назначенные бригады""",
  """task.appeal_reason""": """Причина""",
  """task.solve""": """Решение""",
  """task.appeal_phone""": """Телефон обратившегося""",
  """task.appeal_type""": """Тип обращения""",
  """task.price""": """Стоимость работ""",
  """task.tariff""": """Тариф""",
  """task.coordinates""": """Координаты""",
  """task.connect_type""": """Тип подключения""",
  """task.created_at""": """Дата создания""",
  """task.updated_at""": """Дата обновления""",
  """task.planned_to""": """Плановая дата выполнения""",
  """task.completed_at""": """Дата выполнения""",
  """task.no_comments""": """Комментариев нет""",
  """task.comment_hint""": """Написать комментарий...""",
  """task.send""": """Отправить""",
  """task.just_now""": """только что""",
  """tasks.title""": """Задания""",
  """tasks.empty""": """Нет заданий""",
  """newTask.title""": """Создать задание""",
  """newTask.tab_repair""": """Ремонт""",
  """newTask.tab_building""": """Магистральный ремонт""",
  """newTask.load_error""": """Ошибка загрузки данных""",
  """newTask.created""": """Задание создано""",
  """newTask.create_error""": """Ошибка при создании задания""",
  """newTask.type""": """Тип задания""",
  """newTask.type_repair""": """Выезд на ремонт""",
  """newTask.type_uninstall""": """Демонтаж оборудование""",
  """newTask.type_inactive""": """Выезд к неактивным абонентам""",
  """newTask.type_ravshan""": """Выезд на ремонт (Равшан)""",
  """newTask.type_building_repair""": """Магистраль выезд на ремонт""",
  """newTask.type_building_mount""": """Магистраль-демонтаж/монтаж""",
  """newTask.phone""": """Номер телефона обратившегося""",
  """newTask.phone_hint""": """Введите номер телефона""",
  """newTask.phone_choose""": """или выберите из следующих""",
  """newTask.reason""": """Причина обращения""",
  """newTask.appeal_type""": """Тип обращения""",
  """newTask.description""": """Описание""",
  """newTask.description_hint""": """Введите описание (необязательно)""",
  """newTask.executors""": """Исполнители""",
  """newTask.no_building""": """Коробка не найдена""",
  """newTask.no_building_hint""":
      """Если коробка существует, дождитесь загрузки данных и переоткройте диалог""",
  """newTask.default_status""": """Не выполнено""",
  """settings.title""": """Настройки""",
  """settings.theme""": """Тема""",
  """settings.language""": """Язык""",
  """settings.disabled""": """Отключено""",
  """settings.debounce""": """Задержка при вводе""",
  """settings.debounce_hint""":
      """Время ожидания после поиска перед загрузкой абонентов""",
  """settings.debounce_unit""": """мс""",
  """settings.debounce_error""": """Неправильное значение""",
  """settings.log_out""": """Выйти из аккаунта""",
  """settings.logged_out""": """Вы вышли из аккаунта""",
  """settings.reload_required""":
      """Для применения изменений перезагрузите страницу""",
  """customerPhones.title""": """Телефоны абонента""",
  """customerPhones.main""": """Основной номер телефона""",
  """customerPhones.additional""": """Дополнительный номер телефона""",
  """customerPhones.save""": """Сохранить""",
};
