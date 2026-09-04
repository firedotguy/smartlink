import 'dart:convert';

import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;
import 'package:smartlink/exception.dart';
import 'package:smartlink/utils.dart';

const String _base = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://localhost:8000',
);

final BrowserClient _client = BrowserClient()..withCredentials = true;

Uri _build_uri(String action, Map<String, String> query) {
    final Uri base = Uri.parse(_base);
    final String path = action.replaceAll(RegExp(r'^/+|/+$'), '');
    final String base_path = base.path.replaceAll(RegExp(r'/+$'), '');

    final Uri uri = base.replace(path: '$base_path/$path', queryParameters: query);
    l.d('API: action="$action" query=$query -> $uri');
    return uri;
}

String _extract_detail(http.Response res) {
    try {
        final body = jsonDecode(res.body);
        if (body is Map && body['detail'] != null) return body['detail'].toString();
    } catch (_) {}
    return 'HTTP ${res.statusCode}';
}

Future<dynamic> _request(String method, String action, Map<String, String> query, {int timeout = 20}) async {
    l.d('API ${method.toUpperCase()}: $action $query');
    final Uri uri = _build_uri(action, query);

    final dynamic send = switch (method) {
        'get' => _client.get,
        'post' => _client.post,
        'patch' => _client.patch,
        _ => _client.delete
    };
    final res = await send(uri).timeout(Duration(seconds: timeout));
    l.d('< ${res.statusCode} ${res.body}');

    if (res.statusCode >= 400) {
        throw ApiException(res.statusCode, _extract_detail(res));
    }
    if (res.statusCode == 204) return null;
    return jsonDecode(res.body);
}

Future<dynamic> _get(String action, Map<String, String> query, {int timeout = 20}) async {
    return _request('get', action, query, timeout: timeout);
}

Future<dynamic> _post(String action, Map<String, String> query, {int timeout = 20}) async {
    return _request('post', action, query, timeout: timeout);
}

Future<dynamic> _patch(String action, Map<String, String> query, {int timeout = 20}) async {
    return _request('patch', action, query, timeout: timeout);
}


// абоненты

Future<Map<String, dynamic>> get_customer(int id, {bool full = true}) async {
    l.i('API: get customer id=$id');
    return await _get('customers/$id', {'full': full.toString()});
}

Future<List<Map>> search_customers(String query) async {
    l.i('API: search customers query="$query"');
    return List<Map>.from(await _get('customers/search', {'q': query}));
}

Future<Map<String, dynamic>> get_building(int id) async { // TODO: check #45
    l.i('API: get building id=$id');
    return await _get('buildings/$id', {});
}

Future<Map<String, dynamic>> get_attach(int id) async {
    l.i('API: get attachs id=$id');
    return await _get('customers/$id/attachs', {});
}

Future<List<Map<dynamic, dynamic>>> get_customer_tasks(int id) async {
    l.i('API: get customer tasks id=$id');
    return List<Map<dynamic, dynamic>>.from(await _get('customers/$id/tasks/', {}));
}

Future<List<Map<String, dynamic>>> get_customer_items(int id) async {
    l.i('API: get customer items id=$id');
    return List<Map<String, dynamic>>.from(await _get('customers/$id/items', {}));
}

Future<bool> update_customers(int id, List<int> phones) async {
    l.i('API update customer id=$id phones=$phones');
    await _patch('customers/$id/', {'phones': phones.join(',')});
    return true;
}


// сотрудники

Future<Map> login(String username, String password) async {
    l.i('API: employee login username="$username"');
    return await _post('employees/login', {
        'username': username,
        'password': password,
    });
}

Future<List<Map>> get_divisions() async {
    l.i('API: get divisions');
    final raw = await _get('employees/divisions', {});
    return List<Map>.from(raw);
}

Future<String> get_employee_name(int id) async {
    l.i('API: get employee name id=$id');
    final raw = await _get('employees/name', {'id': id.toString()});
    return (raw['name'] ?? '').toString();
}


// задания

Future<Map<String, dynamic>> get_task(int id) async {
    l.i('API: get task id=$id');
    return await _get('tasks/$id', {});
}

Future<int> create_task(
    int type,
    int? customer_id,
    String reason,
    int? address_id,
    String description,
    List<int> divisions,
    String phone,
    String appeal_type,
) async {
    l.i('API: create task for customer=$customer_id');
    final Map<String, String> query = <String, String>{
        'type': type.toString(),
        if (customer_id != null) 'customer_id': customer_id.toString(),
        'reason': reason,
        if (address_id != null) 'address_id': address_id.toString(),
        'description': description,
        'divisions': divisions.join(','),
        if (phone.isNotEmpty) 'appeal_phone': phone,
        'appeal_type': appeal_type
    };

    final raw = await _post('tasks', query);
    final id = raw['id'];
    if (id is int) return id;
    throw Exception('Task id missing');
}

Future<int> add_comment(int id, String content) async {
    l.i('API: add comment id=$id content=$content');
    return (await _post('tasks/$id/comments', {'content': content}))['id'];
}


// ONT

Future<Map> get_ont(int olt_id, String sn) async {
    l.i('API: get ont data olt_id=$olt_id sn=$sn');
    return await _get('onts/$sn', {'olt_id': olt_id.toString()});
}

Future<bool> restart_ont(String sn, int olt_id) async {
    l.i('API: restart ONT sn=$sn olt_id=$olt_id');
    await _post('onts/$sn/restart', {'olt_id': olt_id.toString()});
    return true;
}

Future<bool> rewrite_sn(String sn, int customer_id, String agreement) async {
    l.i('API: rewrite sn sn=$sn customer_id=$customer_id agreement=$agreement');
    await _post('customers/$customer_id/rewrite-sn', {
        'sn': sn,
        'agreement': agreement
    }, timeout: 360);
    return true;
}

Future<bool> rewrite_mac(int customer_id, String agreement) async {
    l.i('API: rewrite mac customer_id=$customer_id agreement=$agreement');
    await _post('customers/$customer_id/rewrite-mac', {'agreement': agreement});
    return true;
}

Future<bool> toggle_catv(String sn, int olt_id, int catv_id, bool state) async {
    l.i('API: toggle catv sn=$sn olt_id=$olt_id catv_id=$catv_id');
    await _patch('onts/$sn/catv/$catv_id', {
        'olt_id': olt_id.toString(),
        'state': state.toString()
    });
    return true;
}

Future<dynamic> ping(String ip) async {
    l.i('API: ping ip=$ip');
    return await _get('onts/ping', {'ip': ip});
}


// platform

Future<Map> get_platform() async {
    l.i('API: get platform');
    return await _get('platform', {});
}
