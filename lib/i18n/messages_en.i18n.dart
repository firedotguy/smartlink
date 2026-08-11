// GENERATED FILE, do not edit!
// ignore_for_file: annotate_overrides, non_constant_identifier_names, prefer_single_quotes, unused_element, unused_field
import 'package:i18n/i18n.dart' as i18n;
import 'messages.i18n.dart';

String get _languageCode => 'en';
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

class MessagesEn extends Messages {
  const MessagesEn();
  String get locale => "en";
  String get languageCode => "en";
  AppMessagesEn get app => AppMessagesEn(this);
  CommonMessagesEn get common => CommonMessagesEn(this);
  StatusMessagesEn get status => StatusMessagesEn(this);
  LoginMessagesEn get login => LoginMessagesEn(this);
  HomeMessagesEn get home => HomeMessagesEn(this);
  BuildingMessagesEn get building => BuildingMessagesEn(this);
  CustomerMessagesEn get customer => CustomerMessagesEn(this);
  TasksCardMessagesEn get tasksCard => TasksCardMessagesEn(this);
  ItemsMessagesEn get items => ItemsMessagesEn(this);
  OntMessagesEn get ont => OntMessagesEn(this);
  CatvMessagesEn get catv => CatvMessagesEn(this);
  TaskMessagesEn get task => TaskMessagesEn(this);
  TasksMessagesEn get tasks => TasksMessagesEn(this);
  NewTaskMessagesEn get newTask => NewTaskMessagesEn(this);
  SettingsMessagesEn get settings => SettingsMessagesEn(this);
}

class AppMessagesEn extends AppMessages {
  final MessagesEn _parent;
  const AppMessagesEn(this._parent) : super(_parent);

  /// ```dart
  /// "SmartLink"
  /// ```
  String get title => """SmartLink""";

  /// ```dart
  /// "SmartLinkViewer"
  /// ```
  String get name => """SmartLinkViewer""";

  /// ```dart
  /// "© 2026 «NeoTelecom»"
  /// ```
  String get legalese => """© 2026 «NeoTelecom»""";

  /// ```dart
  /// "WASM renderer enabled"
  /// ```
  String get renderer_warning => """WASM renderer enabled""";

  /// ```dart
  /// "View source code"
  /// ```
  String get source_code => """View source code""";

  /// ```dart
  /// "View API source code"
  /// ```
  String get api_source_code => """View API source code""";

  /// ```dart
  /// "v$version (API $api)"
  /// ```
  String version(String version, String api) => """v$version (API $api)""";

  /// ```dart
  /// "SmartLinkViewer v$version [γ]"
  /// ```
  String version_badge(String version) => """SmartLinkViewer v$version [γ]""";

  /// ```dart
  /// "Settings"
  /// ```
  String get settings_tooltip => """Settings""";
}

class CommonMessagesEn extends CommonMessages {
  final MessagesEn _parent;
  const CommonMessagesEn(this._parent) : super(_parent);

  /// ```dart
  /// "-"
  /// ```
  String get empty => """-""";

  /// ```dart
  /// "Ok"
  /// ```
  String get ok => """Ok""";

  /// ```dart
  /// "Cancel"
  /// ```
  String get cancel => """Cancel""";

  /// ```dart
  /// "Close"
  /// ```
  String get close => """Close""";

  /// ```dart
  /// "Close dialog"
  /// ```
  String get close_dialog => """Close dialog""";

  /// ```dart
  /// "Create"
  /// ```
  String get create => """Create""";

  /// ```dart
  /// "Refresh data"
  /// ```
  String get refresh => """Refresh data""";

  /// ```dart
  /// "Open in UserSide"
  /// ```
  String get open_in_userside => """Open in UserSide""";

  /// ```dart
  /// "Copy UserSide link"
  /// ```
  String get copy_userside_link => """Copy UserSide link""";

  /// ```dart
  /// "Link copied"
  /// ```
  String get link_copied => """Link copied""";

  /// ```dart
  /// "Preview"
  /// ```
  String get preview => """Preview""";

  /// ```dart
  /// "Function in development"
  /// ```
  String get preview_tooltip => """Function in development""";

  /// ```dart
  /// "$amount som"
  /// ```
  String som(String amount) => """$amount som""";

  /// ```dart
  /// "Error open link: Link not clickable"
  /// ```
  String get link_not_clickable => """Error open link: Link not clickable""";
}

class StatusMessagesEn extends StatusMessages {
  final MessagesEn _parent;
  const StatusMessagesEn(this._parent) : super(_parent);

  /// ```dart
  /// "Active"
  /// ```
  String get active => """Active""";

  /// ```dart
  /// "Pause"
  /// ```
  String get paused => """Pause""";

  /// ```dart
  /// "Inactive"
  /// ```
  String get inactive => """Inactive""";

  /// ```dart
  /// "Enabled"
  /// ```
  String get enabled => """Enabled""";

  /// ```dart
  /// "Disabled"
  /// ```
  String get disabled => """Disabled""";

  /// ```dart
  /// "Online"
  /// ```
  String get online => """Online""";

  /// ```dart
  /// "Offline"
  /// ```
  String get offline => """Offline""";

  /// ```dart
  /// "ONLINE"
  /// ```
  String get online_badge => """ONLINE""";

  /// ```dart
  /// "OFFLINE"
  /// ```
  String get offline_badge => """OFFLINE""";
}

class LoginMessagesEn extends LoginMessages {
  final MessagesEn _parent;
  const LoginMessagesEn(this._parent) : super(_parent);

  /// ```dart
  /// "Authorization"
  /// ```
  String get title => """Authorization""";

  /// ```dart
  /// "Login"
  /// ```
  String get username => """Login""";

  /// ```dart
  /// "Password"
  /// ```
  String get password => """Password""";

  /// ```dart
  /// "Login"
  /// ```
  String get submit => """Login""";

  /// ```dart
  /// "Successful authorization"
  /// ```
  String get success => """Successful authorization""";

  /// ```dart
  /// "Auth error: invalid login or password"
  /// ```
  String get wrong_credentials => """Auth error: invalid login or password""";

  /// ```dart
  /// "Auth error"
  /// ```
  String get error => """Auth error""";
}

class HomeMessagesEn extends HomeMessages {
  final MessagesEn _parent;
  const HomeMessagesEn(this._parent) : super(_parent);

  /// ```dart
  /// "Name, agreement, SN or phone"
  /// ```
  String get search_hint => """Name, agreement, SN or phone""";

  /// ```dart
  /// "No results"
  /// ```
  String get no_results => """No results""";

  /// ```dart
  /// "Customer not selected"
  /// ```
  String get customer_not_selected => """Customer not selected""";

  /// ```dart
  /// "Error fetching customers"
  /// ```
  String get customers_error => """Error fetching customers""";

  /// ```dart
  /// "Error: user id not found"
  /// ```
  String get user_id_missing => """Error: user id not found""";

  /// ```dart
  /// "Error fetching customer data: $error"
  /// ```
  String customer_error(String error) =>
      """Error fetching customer data: $error""";

  /// ```dart
  /// "Error fetching building data: $error"
  /// ```
  String building_error(String error) =>
      """Error fetching building data: $error""";

  /// ```dart
  /// "Error fetching task data: $error"
  /// ```
  String tasks_error(String error) => """Error fetching task data: $error""";

  /// ```dart
  /// "Error fetching items: $error"
  /// ```
  String items_error(String error) => """Error fetching items: $error""";

  /// ```dart
  /// "Wait until customer load"
  /// ```
  String get wait_customer => """Wait until customer load""";

  /// ```dart
  /// "Customer not loaded"
  /// ```
  String get customer_not_loaded => """Customer not loaded""";

  /// ```dart
  /// "Customer has not items with SN"
  /// ```
  String get no_sn => """Customer has not items with SN""";

  /// ```dart
  /// "OLT not found"
  /// ```
  String get no_olt => """OLT not found""";
}

class BuildingMessagesEn extends BuildingMessages {
  final MessagesEn _parent;
  const BuildingMessagesEn(this._parent) : super(_parent);

  /// ```dart
  /// "Building"
  /// ```
  String get title => """Building""";

  /// ```dart
  /// "Building not found"
  /// ```
  String get not_found => """Building not found""";

  /// ```dart
  /// "Name"
  /// ```
  String get name => """Name""";

  /// ```dart
  /// "Type"
  /// ```
  String get type => """Type""";

  /// ```dart
  /// "Coordinates"
  /// ```
  String get coordinates => """Coordinates""";

  /// ```dart
  /// "Install type"
  /// ```
  String get install_type => """Install type""";

  /// ```dart
  /// "Build status"
  /// ```
  String get build_status => """Build status""";

  /// ```dart
  /// "Open tasks"
  /// ```
  String get open_tasks => """Open tasks""";

  /// ```dart
  /// "Create task (magistral repair)"
  /// ```
  String get new_task_tooltip => """Create task (magistral repair)""";

  /// ```dart
  /// "Show on map"
  /// ```
  String get show_on_map => """Show on map""";

  /// ```dart
  /// "Open in UserSide"
  /// ```
  String get open_tooltip => """Open in UserSide""";

  /// ```dart
  /// "Copy UserSide link"
  /// ```
  String get copy_tooltip => """Copy UserSide link""";

  /// ```dart
  /// "Multiflat house"
  /// ```
  String get type_multiflat => """Multiflat house""";

  /// ```dart
  /// "Private house"
  /// ```
  String get type_private => """Private house""";

  /// ```dart
  /// "Office"
  /// ```
  String get type_office => """Office""";

  /// ```dart
  /// "New house"
  /// ```
  String get type_new => """New house""";

  /// ```dart
  /// "Ravshan"
  /// ```
  String get type_ravshan => """Ravshan""";

  /// ```dart
  /// "Neighbours"
  /// ```
  String get neighbours => """Neighbours""";

  /// ```dart
  /// "Customer has not neighbours"
  /// ```
  String get no_neighbours => """Customer has not neighbours""";

  /// ```dart
  /// "Agree"
  /// ```
  String get column_agreement => """Agree""";

  /// ```dart
  /// "Name"
  /// ```
  String get column_name => """Name""";

  /// ```dart
  /// "Activity"
  /// ```
  String get column_activity => """Activity""";

  /// ```dart
  /// "Status"
  /// ```
  String get column_status => """Status""";

  /// ```dart
  /// "rx"
  /// ```
  String get column_rx => """rx""";
}

class CustomerMessagesEn extends CustomerMessages {
  final MessagesEn _parent;
  const CustomerMessagesEn(this._parent) : super(_parent);

  /// ```dart
  /// "Customer"
  /// ```
  String get title => """Customer""";

  /// ```dart
  /// "Open ONT data"
  /// ```
  String get ont_tooltip => """Open ONT data""";

  /// ```dart
  /// "Open attachments"
  /// ```
  String get attachs_tooltip => """Open attachments""";

  /// ```dart
  /// "Create task (customer repair)"
  /// ```
  String get new_task_tooltip => """Create task (customer repair)""";

  /// ```dart
  /// "Open in UserSide"
  /// ```
  String get open_tooltip => """Open in UserSide""";

  /// ```dart
  /// "Copy UserSide link"
  /// ```
  String get copy_tooltip => """Copy UserSide link""";

  /// ```dart
  /// "Potential customer"
  /// ```
  String get is_potential => """Potential customer""";

  /// ```dart
  /// "Organization"
  /// ```
  String get is_corporate => """Organization""";

  /// ```dart
  /// "Not in billing"
  /// ```
  String get no_billing => """Not in billing""";

  /// ```dart
  /// "Not commutated"
  /// ```
  String get not_switched => """Not commutated""";

  /// ```dart
  /// "Inactive customer"
  /// ```
  String get is_inactive => """Inactive customer""";

  /// ```dart
  /// "Paused customer"
  /// ```
  String get is_paused => """Paused customer""";

  /// ```dart
  /// "Last activity was $when"
  /// ```
  String last_activity_warning(String when) => """Last activity was $when""";

  /// ```dart
  /// "Problems in building"
  /// ```
  String get building_problems => """Problems in building""";

  /// ```dart
  /// "Name"
  /// ```
  String get name => """Name""";

  /// ```dart
  /// "Agreement"
  /// ```
  String get agreement => """Agreement""";

  /// ```dart
  /// "Balance"
  /// ```
  String get balance => """Balance""";

  /// ```dart
  /// "Status"
  /// ```
  String get status => """Status""";

  /// ```dart
  /// "Connect date"
  /// ```
  String get connected_at => """Connect date""";

  /// ```dart
  /// "Group"
  /// ```
  String get group => """Group""";

  /// ```dart
  /// "Last activity"
  /// ```
  String get last_activity => """Last activity""";

  /// ```dart
  /// "Phone number"
  /// ```
  String get phone => """Phone number""";

  /// ```dart
  /// "Phone numbers"
  /// ```
  String get phones => """Phone numbers""";

  /// ```dart
  /// "Tariff"
  /// ```
  String get tariff => """Tariff""";

  /// ```dart
  /// "Tariffs"
  /// ```
  String get tariffs => """Tariffs""";

  /// ```dart
  /// "Planned disconnect"
  /// ```
  String get will_disconnect_at => """Planned disconnect""";

  /// ```dart
  /// "Geo data"
  /// ```
  String get geodata => """Geo data""";

  /// ```dart
  /// "Address"
  /// ```
  String get address => """Address""";

  /// ```dart
  /// "Open in 2GIS"
  /// ```
  String get open_in_2gis => """Open in 2GIS""";

  /// ```dart
  /// "Open in Neotelecom maps"
  /// ```
  String get map_neotelecom => """Open in Neotelecom maps""";

  /// ```dart
  /// "Open in 2GIS"
  /// ```
  String get map_2gis => """Open in 2GIS""";

  /// ```dart
  /// "Coordinates"
  /// ```
  String get coordinates => """Coordinates""";

  /// ```dart
  /// "Entrance"
  /// ```
  String get entrance => """Entrance""";

  /// ```dart
  /// "Floor"
  /// ```
  String get floor => """Floor""";

  /// ```dart
  /// "Apratment"
  /// ```
  String get apartment => """Apratment""";
}

class TasksCardMessagesEn extends TasksCardMessages {
  final MessagesEn _parent;
  const TasksCardMessagesEn(this._parent) : super(_parent);

  /// ```dart
  /// "Tasks"
  /// ```
  String get title => """Tasks""";

  /// ```dart
  /// "Customer has not tasks"
  /// ```
  String get empty => """Customer has not tasks""";

  /// ```dart
  /// "ID"
  /// ```
  String get column_id => """ID""";

  /// ```dart
  /// "Type"
  /// ```
  String get column_type => """Type""";

  /// ```dart
  /// "Create date"
  /// ```
  String get column_created => """Create date""";

  /// ```dart
  /// "Status"
  /// ```
  String get column_status => """Status""";
}

class ItemsMessagesEn extends ItemsMessages {
  final MessagesEn _parent;
  const ItemsMessagesEn(this._parent) : super(_parent);

  /// ```dart
  /// "Items"
  /// ```
  String get title => """Items""";

  /// ```dart
  /// "Customer has not items"
  /// ```
  String get empty => """Customer has not items""";

  /// ```dart
  /// "Name"
  /// ```
  String get column_name => """Name""";

  /// ```dart
  /// "Type"
  /// ```
  String get column_type => """Type""";

  /// ```dart
  /// "SN"
  /// ```
  String get column_sn => """SN""";

  /// ```dart
  /// "Amount"
  /// ```
  String get column_amount => """Amount""";

  /// ```dart
  /// "Cable"
  /// ```
  String get type_cable => """Cable""";

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
  /// "Clamp"
  /// ```
  String get type_clamp => """Clamp""";

  /// ```dart
  /// "Commutator"
  /// ```
  String get type_commutator => """Commutator""";

  /// ```dart
  /// "Coupling"
  /// ```
  String get type_coupling => """Coupling""";

  /// ```dart
  /// "ODF"
  /// ```
  String get type_odf => """ODF""";

  /// ```dart
  /// "Patchcord"
  /// ```
  String get type_patchcord => """Patchcord""";

  /// ```dart
  /// "Other"
  /// ```
  String get type_other => """Other""";

  /// ```dart
  /// "Junction"
  /// ```
  String get type_junction => """Junction""";

  /// ```dart
  /// "Router"
  /// ```
  String get type_router => """Router""";

  /// ```dart
  /// "Splitter"
  /// ```
  String get type_splitter => """Splitter""";

  /// ```dart
  /// "Smart home"
  /// ```
  String get type_smart_home => """Smart home""";

  /// ```dart
  /// "Cisco"
  /// ```
  String get type_cisco => """Cisco""";

  /// ```dart
  /// "Cambium"
  /// ```
  String get type_cambium => """Cambium""";
}

class OntMessagesEn extends OntMessages {
  final MessagesEn _parent;
  const OntMessagesEn(this._parent) : super(_parent);

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
  /// "Restart ONT"
  /// ```
  String get restart => """Restart ONT""";

  /// ```dart
  /// "Rewrite SN"
  /// ```
  String get rewrite_sn => """Rewrite SN""";

  /// ```dart
  /// "Rewrite MAC"
  /// ```
  String get rewrite_mac => """Rewrite MAC""";

  /// ```dart
  /// "Error fetching ONT: $error"
  /// ```
  String load_error(String error) => """Error fetching ONT: $error""";

  /// ```dart
  /// "Error restarting ONT: $error"
  /// ```
  String restart_error(String error) => """Error restarting ONT: $error""";

  /// ```dart
  /// "Error restarting ONT"
  /// ```
  String get restart_failed => """Error restarting ONT""";

  /// ```dart
  /// "ONT restarted"
  /// ```
  String get restarted => """ONT restarted""";

  /// ```dart
  /// "Error rewriting SN: $error"
  /// ```
  String rewrite_sn_error(String error) => """Error rewriting SN: $error""";

  /// ```dart
  /// "Error rewriting SN"
  /// ```
  String get rewrite_sn_failed => """Error rewriting SN""";

  /// ```dart
  /// "SN rewritten"
  /// ```
  String get sn_rewritten => """SN rewritten""";

  /// ```dart
  /// "Error rewriting MAC: $error"
  /// ```
  String rewrite_mac_error(String error) => """Error rewriting MAC: $error""";

  /// ```dart
  /// "Error rewriting MAC"
  /// ```
  String get rewrite_mac_failed => """Error rewriting MAC""";

  /// ```dart
  /// "MAC rewritten"
  /// ```
  String get mac_rewritten => """MAC rewritten""";

  /// ```dart
  /// "Name"
  /// ```
  String get olt_name => """Name""";

  /// ```dart
  /// "Location"
  /// ```
  String get olt_location => """Location""";

  /// ```dart
  /// "SN"
  /// ```
  String get sn => """SN""";

  /// ```dart
  /// "IP"
  /// ```
  String get ip => """IP""";

  /// ```dart
  /// "Uptime"
  /// ```
  String get uptime => """Uptime""";

  /// ```dart
  /// "Distance"
  /// ```
  String get distance => """Distance""";

  /// ```dart
  /// "Last up"
  /// ```
  String get last_up => """Last up""";

  /// ```dart
  /// "Last down"
  /// ```
  String get last_down => """Last down""";

  /// ```dart
  /// "Last down cause"
  /// ```
  String get last_down_cause => """Last down cause""";

  /// ```dart
  /// "Ping"
  /// ```
  String get ping => """Ping""";

  /// ```dart
  /// "RX (dBm)"
  /// ```
  String get rx => """RX (dBm)""";

  /// ```dart
  /// "TX (dBm)"
  /// ```
  String get tx => """TX (dBm)""";

  /// ```dart
  /// "Temperature"
  /// ```
  String get temperature => """Temperature""";

  /// ```dart
  /// "km"
  /// ```
  String get kilometers => """km""";

  /// ```dart
  /// "No CATV ports"
  /// ```
  String get no_catv_ports => """No CATV ports""";

  /// ```dart
  /// "No ETH ports"
  /// ```
  String get no_eth_ports => """No ETH ports""";

  /// ```dart
  /// "Port $id"
  /// ```
  String port(String id) => """Port $id""";

  /// ```dart
  /// "Not working"
  /// ```
  String get port_broken => """Not working""";

  /// ```dart
  /// "Disabled"
  /// ```
  String get port_shutdown => """Disabled""";

  /// ```dart
  /// "$speed MBit/s  $duplex"
  /// ```
  String port_speed(String speed, String duplex) =>
      """$speed MBit/s  $duplex""";

  /// ```dart
  /// """
  /// State: $state
  /// Status: $actual
  /// """
  /// ```
  String catv_tooltip(String state, String actual) => """State: $state
Status: $actual""";

  /// ```dart
  /// """
  /// State: $state
  /// Status: $actual
  /// Speed: $speed Мбит/c
  /// Duplex: $duplex
  /// """
  /// ```
  String eth_tooltip(
    String state,
    String actual,
    String speed,
    String duplex,
  ) =>
      """State: $state
Status: $actual
Speed: $speed Мбит/c
Duplex: $duplex""";

  /// ```dart
  /// "Full"
  /// ```
  String get eth_duplex_full => """Full""";

  /// ```dart
  /// "Half"
  /// ```
  String get eth_duplex_half => """Half""";

  /// ```dart
  /// "Unknown"
  /// ```
  String get eth_duplex_neg => """Unknown""";

  /// ```dart
  /// "$relative ($absolute)"
  /// ```
  String relative_date(String relative, String absolute) =>
      """$relative ($absolute)""";
}

class CatvMessagesEn extends CatvMessages {
  final MessagesEn _parent;
  const CatvMessagesEn(this._parent) : super(_parent);

  /// ```dart
  /// "Enabling CATV"
  /// ```
  String get enable_title => """Enabling CATV""";

  /// ```dart
  /// "Disabling CATV"
  /// ```
  String get disable_title => """Disabling CATV""";

  /// ```dart
  /// "Are you sure to enable CATV?"
  /// ```
  String get enable_confirm => """Are you sure to enable CATV?""";

  /// ```dart
  /// "Are you sure to disable CATV?"
  /// ```
  String get disable_confirm => """Are you sure to disable CATV?""";

  /// ```dart
  /// "Toggle state"
  /// ```
  String get toggle_tooltip => """Toggle state""";

  /// ```dart
  /// "Port state"
  /// ```
  String get port_state => """Port state""";

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
  /// "Unable toggle CATV: Customer is inactive."
  /// ```
  String get customer_inactive =>
      """Unable toggle CATV: Customer is inactive.""";

  /// ```dart
  /// "Enable"
  /// ```
  String get enable => """Enable""";

  /// ```dart
  /// "Disable"
  /// ```
  String get disable => """Disable""";

  /// ```dart
  /// "CATV successfully toggled"
  /// ```
  String get toggled => """CATV successfully toggled""";

  /// ```dart
  /// "Error toggling CATV: $error"
  /// ```
  String toggle_error(String error) => """Error toggling CATV: $error""";

  /// ```dart
  /// "Error toggling CATV"
  /// ```
  String get toggle_failed => """Error toggling CATV""";
}

class TaskMessagesEn extends TaskMessages {
  final MessagesEn _parent;
  const TaskMessagesEn(this._parent) : super(_parent);

  /// ```dart
  /// "Task"
  /// ```
  String get title => """Task""";

  /// ```dart
  /// "Copy UserSide link"
  /// ```
  String get copy_tooltip => """Copy UserSide link""";

  /// ```dart
  /// "Error loading task: $error"
  /// ```
  String load_error(String error) => """Error loading task: $error""";

  /// ```dart
  /// "Error sending comment: $error"
  /// ```
  String comment_error(String error) => """Error sending comment: $error""";

  /// ```dart
  /// "Main data"
  /// ```
  String get section_main => """Main data""";

  /// ```dart
  /// "Comments"
  /// ```
  String get section_comments => """Comments""";

  /// ```dart
  /// "Type"
  /// ```
  String get type => """Type""";

  /// ```dart
  /// "Status"
  /// ```
  String get status => """Status""";

  /// ```dart
  /// "Address"
  /// ```
  String get address => """Address""";

  /// ```dart
  /// "Task author"
  /// ```
  String get author => """Task author""";

  /// ```dart
  /// "Assigned employees"
  /// ```
  String get employees => """Assigned employees""";

  /// ```dart
  /// "Assigned divisions"
  /// ```
  String get divisions => """Assigned divisions""";

  /// ```dart
  /// "Reason"
  /// ```
  String get appeal_reason => """Reason""";

  /// ```dart
  /// "Solve"
  /// ```
  String get solve => """Solve""";

  /// ```dart
  /// "Appeal phone"
  /// ```
  String get appeal_phone => """Appeal phone""";

  /// ```dart
  /// "Appeal type"
  /// ```
  String get appeal_type => """Appeal type""";

  /// ```dart
  /// "Work price"
  /// ```
  String get price => """Work price""";

  /// ```dart
  /// "Tariff"
  /// ```
  String get tariff => """Tariff""";

  /// ```dart
  /// "Coordinates"
  /// ```
  String get coordinates => """Coordinates""";

  /// ```dart
  /// "Connect type"
  /// ```
  String get connect_type => """Connect type""";

  /// ```dart
  /// "Create date"
  /// ```
  String get created_at => """Create date""";

  /// ```dart
  /// "Update date"
  /// ```
  String get updated_at => """Update date""";

  /// ```dart
  /// "Planned to complete date"
  /// ```
  String get planned_to => """Planned to complete date""";

  /// ```dart
  /// "Complete date"
  /// ```
  String get completed_at => """Complete date""";

  /// ```dart
  /// "No comments"
  /// ```
  String get no_comments => """No comments""";

  /// ```dart
  /// "Write comments..."
  /// ```
  String get comment_hint => """Write comments...""";

  /// ```dart
  /// "Send"
  /// ```
  String get send => """Send""";

  /// ```dart
  /// "Just now"
  /// ```
  String get just_now => """Just now""";
}

class TasksMessagesEn extends TasksMessages {
  final MessagesEn _parent;
  const TasksMessagesEn(this._parent) : super(_parent);

  /// ```dart
  /// "Tasks"
  /// ```
  String get title => """Tasks""";

  /// ```dart
  /// "No tasks"
  /// ```
  String get empty => """No tasks""";

  /// ```dart
  /// "ID: $id"
  /// ```
  String id(String id) => """ID: $id""";

  /// ```dart
  /// "Created: $date"
  /// ```
  String created(String date) => """Created: $date""";

  /// ```dart
  /// "Completed: $date"
  /// ```
  String completed(String date) => """Completed: $date""";

  /// ```dart
  /// "Author: $name"
  /// ```
  String author(String name) => """Author: $name""";
}

class NewTaskMessagesEn extends NewTaskMessages {
  final MessagesEn _parent;
  const NewTaskMessagesEn(this._parent) : super(_parent);

  /// ```dart
  /// "Create task"
  /// ```
  String get title => """Create task""";

  /// ```dart
  /// "Repair"
  /// ```
  String get tab_repair => """Repair""";

  /// ```dart
  /// "Magistral repair"
  /// ```
  String get tab_building => """Magistral repair""";

  /// ```dart
  /// "Error fetching data"
  /// ```
  String get load_error => """Error fetching data""";

  /// ```dart
  /// "Task created"
  /// ```
  String get created => """Task created""";

  /// ```dart
  /// "Error creating task"
  /// ```
  String get create_error => """Error creating task""";

  /// ```dart
  /// "Task type"
  /// ```
  String get type => """Task type""";

  /// ```dart
  /// "Repair"
  /// ```
  String get type_repair => """Repair""";

  /// ```dart
  /// "Uninstall"
  /// ```
  String get type_uninstall => """Uninstall""";

  /// ```dart
  /// "Drive to inactive customer"
  /// ```
  String get type_inactive => """Drive to inactive customer""";

  /// ```dart
  /// "Repair (Ravshan)"
  /// ```
  String get type_ravshan => """Repair (Ravshan)""";

  /// ```dart
  /// "Magistral repair"
  /// ```
  String get type_building_repair => """Magistral repair""";

  /// ```dart
  /// "Magistral install / uninstall"
  /// ```
  String get type_building_mount => """Magistral install / uninstall""";

  /// ```dart
  /// "Phone"
  /// ```
  String get phone => """Phone""";

  /// ```dart
  /// "Enter phone number"
  /// ```
  String get phone_hint => """Enter phone number""";

  /// ```dart
  /// "or select below"
  /// ```
  String get phone_choose => """or select below""";

  /// ```dart
  /// "Reason"
  /// ```
  String get reason => """Reason""";

  /// ```dart
  /// "Appeal type"
  /// ```
  String get appeal_type => """Appeal type""";

  /// ```dart
  /// "Description"
  /// ```
  String get description => """Description""";

  /// ```dart
  /// "Enter description (not required)"
  /// ```
  String get description_hint => """Enter description (not required)""";

  /// ```dart
  /// "Employees"
  /// ```
  String get executors => """Employees""";

  /// ```dart
  /// "Building not found"
  /// ```
  String get no_building => """Building not found""";

  /// ```dart
  /// "Building not found. If it exists, wait until it load and open again."
  /// ```
  String get no_building_hint =>
      """Building not found. If it exists, wait until it load and open again.""";

  /// ```dart
  /// "Not completed"
  /// ```
  String get default_status => """Not completed""";
}

class SettingsMessagesEn extends SettingsMessages {
  final MessagesEn _parent;
  const SettingsMessagesEn(this._parent) : super(_parent);

  /// ```dart
  /// "Settings"
  /// ```
  String get title => """Settings""";

  /// ```dart
  /// "Theme"
  /// ```
  String get theme => """Theme""";

  /// ```dart
  /// "Language"
  /// ```
  String get language => """Language""";

  /// ```dart
  /// "Disabled"
  /// ```
  String get disabled => """Disabled""";

  /// ```dart
  /// "Debounce while typing"
  /// ```
  String get debounce => """Debounce while typing""";

  /// ```dart
  /// "Duration after search before load customers"
  /// ```
  String get debounce_hint => """Duration after search before load customers""";

  /// ```dart
  /// "ms"
  /// ```
  String get debounce_unit => """ms""";

  /// ```dart
  /// "Invalid value"
  /// ```
  String get debounce_error => """Invalid value""";

  /// ```dart
  /// "Log out"
  /// ```
  String get log_out => """Log out""";

  /// ```dart
  /// "You logged out"
  /// ```
  String get logged_out => """You logged out""";

  /// ```dart
  /// "Reload page to apply changes"
  /// ```
  String get reload_required => """Reload page to apply changes""";
}

Map<String, String> get messagesEnMap => {
  """app.title""": """SmartLink""",
  """app.name""": """SmartLinkViewer""",
  """app.legalese""": """© 2026 «NeoTelecom»""",
  """app.renderer_warning""": """WASM renderer enabled""",
  """app.source_code""": """View source code""",
  """app.api_source_code""": """View API source code""",
  """app.settings_tooltip""": """Settings""",
  """common.empty""": """-""",
  """common.ok""": """Ok""",
  """common.cancel""": """Cancel""",
  """common.close""": """Close""",
  """common.close_dialog""": """Close dialog""",
  """common.create""": """Create""",
  """common.refresh""": """Refresh data""",
  """common.open_in_userside""": """Open in UserSide""",
  """common.copy_userside_link""": """Copy UserSide link""",
  """common.link_copied""": """Link copied""",
  """common.preview""": """Preview""",
  """common.preview_tooltip""": """Function in development""",
  """common.link_not_clickable""": """Error open link: Link not clickable""",
  """status.active""": """Active""",
  """status.paused""": """Pause""",
  """status.inactive""": """Inactive""",
  """status.enabled""": """Enabled""",
  """status.disabled""": """Disabled""",
  """status.online""": """Online""",
  """status.offline""": """Offline""",
  """status.online_badge""": """ONLINE""",
  """status.offline_badge""": """OFFLINE""",
  """login.title""": """Authorization""",
  """login.username""": """Login""",
  """login.password""": """Password""",
  """login.submit""": """Login""",
  """login.success""": """Successful authorization""",
  """login.wrong_credentials""": """Auth error: invalid login or password""",
  """login.error""": """Auth error""",
  """home.search_hint""": """Name, agreement, SN or phone""",
  """home.no_results""": """No results""",
  """home.customer_not_selected""": """Customer not selected""",
  """home.customers_error""": """Error fetching customers""",
  """home.user_id_missing""": """Error: user id not found""",
  """home.wait_customer""": """Wait until customer load""",
  """home.customer_not_loaded""": """Customer not loaded""",
  """home.no_sn""": """Customer has not items with SN""",
  """home.no_olt""": """OLT not found""",
  """building.title""": """Building""",
  """building.not_found""": """Building not found""",
  """building.name""": """Name""",
  """building.type""": """Type""",
  """building.coordinates""": """Coordinates""",
  """building.install_type""": """Install type""",
  """building.build_status""": """Build status""",
  """building.open_tasks""": """Open tasks""",
  """building.new_task_tooltip""": """Create task (magistral repair)""",
  """building.show_on_map""": """Show on map""",
  """building.open_tooltip""": """Open in UserSide""",
  """building.copy_tooltip""": """Copy UserSide link""",
  """building.type_multiflat""": """Multiflat house""",
  """building.type_private""": """Private house""",
  """building.type_office""": """Office""",
  """building.type_new""": """New house""",
  """building.type_ravshan""": """Ravshan""",
  """building.neighbours""": """Neighbours""",
  """building.no_neighbours""": """Customer has not neighbours""",
  """building.column_agreement""": """Agree""",
  """building.column_name""": """Name""",
  """building.column_activity""": """Activity""",
  """building.column_status""": """Status""",
  """building.column_rx""": """rx""",
  """customer.title""": """Customer""",
  """customer.ont_tooltip""": """Open ONT data""",
  """customer.attachs_tooltip""": """Open attachments""",
  """customer.new_task_tooltip""": """Create task (customer repair)""",
  """customer.open_tooltip""": """Open in UserSide""",
  """customer.copy_tooltip""": """Copy UserSide link""",
  """customer.is_potential""": """Potential customer""",
  """customer.is_corporate""": """Organization""",
  """customer.no_billing""": """Not in billing""",
  """customer.not_switched""": """Not commutated""",
  """customer.is_inactive""": """Inactive customer""",
  """customer.is_paused""": """Paused customer""",
  """customer.building_problems""": """Problems in building""",
  """customer.name""": """Name""",
  """customer.agreement""": """Agreement""",
  """customer.balance""": """Balance""",
  """customer.status""": """Status""",
  """customer.connected_at""": """Connect date""",
  """customer.group""": """Group""",
  """customer.last_activity""": """Last activity""",
  """customer.phone""": """Phone number""",
  """customer.phones""": """Phone numbers""",
  """customer.tariff""": """Tariff""",
  """customer.tariffs""": """Tariffs""",
  """customer.will_disconnect_at""": """Planned disconnect""",
  """customer.geodata""": """Geo data""",
  """customer.address""": """Address""",
  """customer.open_in_2gis""": """Open in 2GIS""",
  """customer.map_neotelecom""": """Open in Neotelecom maps""",
  """customer.map_2gis""": """Open in 2GIS""",
  """customer.coordinates""": """Coordinates""",
  """customer.entrance""": """Entrance""",
  """customer.floor""": """Floor""",
  """customer.apartment""": """Apratment""",
  """tasksCard.title""": """Tasks""",
  """tasksCard.empty""": """Customer has not tasks""",
  """tasksCard.column_id""": """ID""",
  """tasksCard.column_type""": """Type""",
  """tasksCard.column_created""": """Create date""",
  """tasksCard.column_status""": """Status""",
  """items.title""": """Items""",
  """items.empty""": """Customer has not items""",
  """items.column_name""": """Name""",
  """items.column_type""": """Type""",
  """items.column_sn""": """SN""",
  """items.column_amount""": """Amount""",
  """items.type_cable""": """Cable""",
  """items.type_olt""": """OLT""",
  """items.type_edfa""": """EDFA""",
  """items.type_ont""": """ONT""",
  """items.type_clamp""": """Clamp""",
  """items.type_commutator""": """Commutator""",
  """items.type_coupling""": """Coupling""",
  """items.type_odf""": """ODF""",
  """items.type_patchcord""": """Patchcord""",
  """items.type_other""": """Other""",
  """items.type_junction""": """Junction""",
  """items.type_router""": """Router""",
  """items.type_splitter""": """Splitter""",
  """items.type_smart_home""": """Smart home""",
  """items.type_cisco""": """Cisco""",
  """items.type_cambium""": """Cambium""",
  """ont.title""": """ONT / OLT""",
  """ont.section_olt""": """OLT""",
  """ont.section_ont""": """ONT""",
  """ont.section_catv""": """CATV""",
  """ont.section_eth""": """ETH/LAN""",
  """ont.restart""": """Restart ONT""",
  """ont.rewrite_sn""": """Rewrite SN""",
  """ont.rewrite_mac""": """Rewrite MAC""",
  """ont.restart_failed""": """Error restarting ONT""",
  """ont.restarted""": """ONT restarted""",
  """ont.rewrite_sn_failed""": """Error rewriting SN""",
  """ont.sn_rewritten""": """SN rewritten""",
  """ont.rewrite_mac_failed""": """Error rewriting MAC""",
  """ont.mac_rewritten""": """MAC rewritten""",
  """ont.olt_name""": """Name""",
  """ont.olt_location""": """Location""",
  """ont.sn""": """SN""",
  """ont.ip""": """IP""",
  """ont.uptime""": """Uptime""",
  """ont.distance""": """Distance""",
  """ont.last_up""": """Last up""",
  """ont.last_down""": """Last down""",
  """ont.last_down_cause""": """Last down cause""",
  """ont.ping""": """Ping""",
  """ont.rx""": """RX (dBm)""",
  """ont.tx""": """TX (dBm)""",
  """ont.temperature""": """Temperature""",
  """ont.kilometers""": """km""",
  """ont.no_catv_ports""": """No CATV ports""",
  """ont.no_eth_ports""": """No ETH ports""",
  """ont.port_broken""": """Not working""",
  """ont.port_shutdown""": """Disabled""",
  """ont.eth_duplex_full""": """Full""",
  """ont.eth_duplex_half""": """Half""",
  """ont.eth_duplex_neg""": """Unknown""",
  """catv.enable_title""": """Enabling CATV""",
  """catv.disable_title""": """Disabling CATV""",
  """catv.enable_confirm""": """Are you sure to enable CATV?""",
  """catv.disable_confirm""": """Are you sure to disable CATV?""",
  """catv.toggle_tooltip""": """Toggle state""",
  """catv.port_state""": """Port state""",
  """catv.sn""": """SN""",
  """catv.olt_id""": """OLT ID""",
  """catv.catv_id""": """CATV ID""",
  """catv.customer_inactive""": """Unable toggle CATV: Customer is inactive.""",
  """catv.enable""": """Enable""",
  """catv.disable""": """Disable""",
  """catv.toggled""": """CATV successfully toggled""",
  """catv.toggle_failed""": """Error toggling CATV""",
  """task.title""": """Task""",
  """task.copy_tooltip""": """Copy UserSide link""",
  """task.section_main""": """Main data""",
  """task.section_comments""": """Comments""",
  """task.type""": """Type""",
  """task.status""": """Status""",
  """task.address""": """Address""",
  """task.author""": """Task author""",
  """task.employees""": """Assigned employees""",
  """task.divisions""": """Assigned divisions""",
  """task.appeal_reason""": """Reason""",
  """task.solve""": """Solve""",
  """task.appeal_phone""": """Appeal phone""",
  """task.appeal_type""": """Appeal type""",
  """task.price""": """Work price""",
  """task.tariff""": """Tariff""",
  """task.coordinates""": """Coordinates""",
  """task.connect_type""": """Connect type""",
  """task.created_at""": """Create date""",
  """task.updated_at""": """Update date""",
  """task.planned_to""": """Planned to complete date""",
  """task.completed_at""": """Complete date""",
  """task.no_comments""": """No comments""",
  """task.comment_hint""": """Write comments...""",
  """task.send""": """Send""",
  """task.just_now""": """Just now""",
  """tasks.title""": """Tasks""",
  """tasks.empty""": """No tasks""",
  """newTask.title""": """Create task""",
  """newTask.tab_repair""": """Repair""",
  """newTask.tab_building""": """Magistral repair""",
  """newTask.load_error""": """Error fetching data""",
  """newTask.created""": """Task created""",
  """newTask.create_error""": """Error creating task""",
  """newTask.type""": """Task type""",
  """newTask.type_repair""": """Repair""",
  """newTask.type_uninstall""": """Uninstall""",
  """newTask.type_inactive""": """Drive to inactive customer""",
  """newTask.type_ravshan""": """Repair (Ravshan)""",
  """newTask.type_building_repair""": """Magistral repair""",
  """newTask.type_building_mount""": """Magistral install / uninstall""",
  """newTask.phone""": """Phone""",
  """newTask.phone_hint""": """Enter phone number""",
  """newTask.phone_choose""": """or select below""",
  """newTask.reason""": """Reason""",
  """newTask.appeal_type""": """Appeal type""",
  """newTask.description""": """Description""",
  """newTask.description_hint""": """Enter description (not required)""",
  """newTask.executors""": """Employees""",
  """newTask.no_building""": """Building not found""",
  """newTask.no_building_hint""":
      """Building not found. If it exists, wait until it load and open again.""",
  """newTask.default_status""": """Not completed""",
  """settings.title""": """Settings""",
  """settings.theme""": """Theme""",
  """settings.language""": """Language""",
  """settings.disabled""": """Disabled""",
  """settings.debounce""": """Debounce while typing""",
  """settings.debounce_hint""":
      """Duration after search before load customers""",
  """settings.debounce_unit""": """ms""",
  """settings.debounce_error""": """Invalid value""",
  """settings.log_out""": """Log out""",
  """settings.logged_out""": """You logged out""",
  """settings.reload_required""": """Reload page to apply changes""",
};
