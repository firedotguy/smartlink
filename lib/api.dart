import 'dart:convert';

import 'package:http/http.dart';
import 'package:smartlink/main.dart';

const String _base = String.fromEnvironment(
  'API_BASE',
  defaultValue: 'http://localhost:8000',
);

const String _key = String.fromEnvironment(
  'API_KEY',
  defaultValue: '',
);

final Client _client = Client();

Uri _u(String action, Map<String, String> qp) {
  final params = {'apikey': _key, ...qp};
  final base = Uri.parse(_base);
  final act = action.replaceAll(RegExp(r'^/+|/+$'), '');
  final basePath = base.path.replaceAll(RegExp(r'/+$'), '');
  final Uri uri = base.replace(path: '$basePath/$act', queryParameters: params);
  l.d('API: action="$action" qp=$qp -> $uri');
  return uri;
}

Future<Map<String, dynamic>> _get(String action, Map<String, String> qp, {int timeout = 20, bool processStatusCode = true}) async {
  l.d('API GET: $action $qp');
  final uri = _u(action, qp);
  final resp = await _client.get(uri).timeout(Duration(seconds: timeout));

  if (resp.statusCode != 200 && processStatusCode) {
    l.e('API GET $action -> HTTP ${resp.statusCode}, body: ${resp.body}');
    throw Exception('HTTP ${resp.statusCode}');
  }
  final data = jsonDecode(resp.body);
  if (data is Map<String, dynamic>) return data;

  l.e('API GET unexpected response type for $action');
  throw Exception('Unexpected response');
}

Future<Map<String, dynamic>> _post(String action, Map<String, String> qp, {int timeout = 20, bool processStatusCode = true}) async {
  l.d('API POST: $action $qp');
  final uri = _u(action, qp);
  final resp = await _client.post(uri).timeout(Duration(seconds: timeout));

  if (resp.statusCode != 200 && processStatusCode) {
    l.e('API POST $action -> HTTP ${resp.statusCode}, body: ${resp.body}');
    throw Exception('HTTP ${resp.statusCode}');
  }
  final data = jsonDecode(resp.body);
  if (data is Map<String, dynamic>) return data;

  l.e('API POST unexpected response type for $action');
  throw Exception('Unexpected response');
}

Future<Map<String, dynamic>> getCustomer(int id) async {
  l.i('API: get customer id=$id');
  return await _get('customer/$id', {});
}

Future<Map<String, dynamic>> getBox(int id, {int skip = 0, int limit = 10, bool getCount = true}) async {
  l.i('API: get box id=$id');
  return await _get('box/$id', {'get_onu_level': 'true', 'get_tasks': 'true', 'limit': limit.toString(), 'skip': skip.toString(), 'get_count': getCount.toString()}); // TODO: check #45
}

Future<Map<String, dynamic>> getAttach(int customerId) async {
  l.i('API: get attachs customerId=$customerId');
  return await _get('attachs/customer/$customerId', {
    'include_task': 'true',
  });
}

Future<List<Map>> find(String query) async {
  l.i('API: find customers query="$query"');
  final res = await _get('customer/search', {'query': query}, processStatusCode: false);
  if (res['detail'] == 'not found') {
    return [];
  }
  return List<Map>.from(res['customers']);
}

Future<Map> login(String login, String password) async {
  l.i('API: employee login login="$login"');
  return await _get('employee/login', {
    'login': login,
    'password': password,
  });
}

Future<Map> getAdditionalData() async {
  l.i('API: get additional data');
  final raw = await _get('addata/options', {});
  return Map<String, dynamic>.from(raw['data'] ?? const {});
}

Future<List<Map>> getDivisions() async {
  l.i('API: get divisions');
  final raw = await _get('employee/divisions', {});
  return List<Map>.from(raw['data'] ?? const []);
}

Future<int> createTask(
  int type,
  int? customerId,
  int authorId,
  String reason,
  int? addressId,
  String description,
  List<int> divisions,
  String phone,
  String appealType,
) async {
  l.i('API: create task for customer=$customerId');
  final qp = <String, String>{
    'type': type.toString(),
    if (customerId != null) 'customer_id': customerId.toString(),
    'author_id': authorId.toString(),
    'reason': reason,
    if (addressId != null) 'address_id': addressId.toString(),
    'description': description,
    'divisions': divisions.join(','),
    if (phone.isNotEmpty) 'appeal_phone': phone,
    'appeal_type': appealType
  };
  final raw = await _post('task', qp);
  final id = raw['id'];
  if (id is int) return id;
  throw Exception('Task id missing');
}

Future<String> getEmployeeName(int id) async {
  l.i('API: get employee name id=$id');
  final raw = await _get('employee/name', {'id': id.toString()});
  return (raw['name'] ?? '').toString();
}

Future<Map> getOnt(int oltId, String sn) async {
  l.i('API: get ont data oltId=$oltId sn=$sn');
  return await _get('ont', {
    'olt_id': oltId.toString(),
    'sn': sn,
  });
}

Future<String?> restartOnt(int ontId, String host, Map interface) async {
  l.i('API: restart ONT id=$ontId host=$host iface=$interface');
  final raw = await _post('ont/${interface['fibre']}/${interface['service']}/${interface['port']}/$ontId/restart', {
    'id': ontId.toString(),
    'host': host
  });
  if (raw['status'] == 'success') return null;
  return (raw['detail'] ?? 'unknown error').toString();
}

Future<Map> rewriteSN(String sn, int customerId, int ls) async {
  l.i('API: rewrite sn sn=$sn customerId=$customerId ls=$ls');
  return await _post('ont/rewrite_sn', {
    'customer_id': customerId.toString(),
    'sn': sn,
    'ls': ls.toString()
  }, timeout: 360);
}
Future<Map> rewriteMAC(int customerId, int ls) async {
  l.i('API: rewrite mac customerId=$customerId ls=$ls');
  return await _post('ont/rewrite_mac', {
    'customer_id': customerId.toString(),
    'ls': ls.toString()
  });
}

Future<Map> toggleCATV(String host, int fibre, int service, int port, int ontID, int catvID, bool state) async {
  l.i('API: toggle catv host=$host fibre=$fibre service=$service port=$port ontId=$ontID catvID=$catvID');
  return await _post('ont/$fibre/$service/$port/$ontID/catv/$catvID/toggle', {
    'host': host,
    'state': state.toString()
  });
}

Future<Map<String, dynamic>> getTask(int id) async {
  l.i('API: get task id=$id');
  return await _get('task/$id', {});
}

Future<List<dynamic>> getCustomerTasks(int customerId, {int skip = 0, bool getCount = true}) async {
  l.i('API: get customer tasks id=$customerId');
  final res = await _get('task/', {'customer_id': customerId.toString(), 'limit': '5', 'skip': skip.toString(), 'get_count': getCount.toString()}); // TODO: check #45
  return [List<Map<String, dynamic>>.from(res['data']), res['limit'], res['count']];
}

Future<List<Map<String, dynamic>>> getCustomerInventory(int customerId) async {
  l.i('API: get customer inventory id=$customerId');
  return List<Map<String, dynamic>>.from((await _get('inventory/', {'customer_id': customerId.toString()}))['data']);
}

Future addComent(int id, String content, int authorId) async {
  l.i('API: add comment id=$id content=$content authorId=$authorId');
  await _post('task/$id/comment', {'content': content, 'author': authorId.toString()});
}