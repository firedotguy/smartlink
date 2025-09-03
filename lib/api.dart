import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:smartlink/main.dart';

/// API key
final String api = dotenv.env['API_BASE']!;
/// API domain
final String key = dotenv.env['API_KEY']!;


/// get customer data
Future<Map<String, dynamic>> getCustomer(int id) async {
  l.i('API: get customer data, customerId: $id');
  final res = await http.get(Uri.parse('$api/customer?id=$id&apikey=$key'));
  return jsonDecode(res.body);
}

/// get box data
Future<Map<String, dynamic>> getBox(int id) async {
  l.i('API: get box data, boxId: $id');
  final res = await http.get(Uri.parse('$api/box?id=$id&apikey=$key'));
  return jsonDecode(res.body);
}

/// get customer attachments
Future<Map<String, dynamic>> getAttach(int id) async {
  l.i('API: get attachments, customerId: $id');
  final res = await http.get(Uri.parse('$api/attachs?id=$id&apikey=$key'));
  return jsonDecode(res.body);
}

/// get task comments
Future<Map<String, dynamic>> getComments(int id) async {
  l.i('API: get comments, taskId: $id');
  final res = await http.get(Uri.parse('$api/comments?id=$id&apikey=$key'));
  return jsonDecode(res.body);
}

/// find customer
Future<List<Map>> find(String query) async {
  l.i('API: find customers, query: $query');
  final res = await http.get(Uri.parse('$api/find?query=$query&apikey=$key'));
  return List<Map>.from(jsonDecode(res.body)['customers']);
}

/// check login
Future<Map> login(String login, String password) async {
  l.i('API: check login, login: $login, password: $password');
  final res = await http.get(Uri.parse('$api/login?login=$login&password=$password&apikey=$key'));
  return jsonDecode(res.body);
}

/// get additional data values
Future<Map> getAdditionalData() async {
  l.i('API: get additional data');
  final res = await http.get(Uri.parse('$api/additional_data?apikey=$key'));
  return jsonDecode(res.body)['data'];
}

/// get divisions list
Future<List<Map>> getDivisions() async {
  l.i('API: get divisions');
  final res = await http.get(Uri.parse('$api/divisions?apikey=$key'));
  return List<Map>.from(jsonDecode(res.body)['data']);
}

/// create task
Future<int> createTask(int customerId, int authorId, String reason, bool box, int? boxId, String description, List<int> divisions, String phone, String type) async {
  l.i('API: create task');
  final res = await http.post(Uri.parse('$api/task?apikey=$key&customer_id=$customerId&author_id=$authorId&reason=$reason&box=$box&description=$description&divisions=$divisions&phone=$phone&type=$type${boxId != null? '&box_id=$boxId' : ""}'));
  l.i(jsonDecode(res.body));
  return jsonDecode(res.body)['id'];
}

/// get employee name
Future<String> getEmployeeName(int id) async {
  l.i('API: get employee name');
  final res = await http.get(Uri.parse('$api/employee/name?apikey=$key&id=$id'));
  return jsonDecode(res.body)['name'];
}

/// get ont&olt data
Future<Map> getOnt(int oltId, String sn) async {
  l.i('API: get ont data');
  final res = await http.get(Uri.parse('$api/ont?apikey=$key&olt_id=$oltId&sn=$sn'));
  return jsonDecode(res.body);
}