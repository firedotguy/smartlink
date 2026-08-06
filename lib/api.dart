import 'dart:convert';

import 'package:http/browser_client.dart';
import 'package:smartlink/main.dart';

const String _base = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://localhost:8000',
);


final BrowserClient _client = BrowserClient()..withCredentials = true;

Uri _u(String action, Map<String, String> qp) {
    final base = Uri.parse(_base);
    final act = action.replaceAll(RegExp(r'^/+|/+$'), '');
    final basePath = base.path.replaceAll(RegExp(r'/+$'), '');
    final Uri uri = base.replace(path: '$basePath/$act', queryParameters: qp);
    l.d('API: action="$action" qp=$qp -> $uri');
    return uri;
}

Future<dynamic> _request(String method, String action, Map<String, String> qp, {int timeout = 20}) async {
    l.d('API ${method.toUpperCase()}: $action $qp');
    final uri = _u(action, qp);

    dynamic func;
    if (method == 'get') {
        func = _client.get;
    } else if (method == 'post') {
        func = _client.post;
    } else {
        func = _client.patch;
    }
    final resp = await func(uri).timeout(Duration(seconds: timeout));

    if (resp.statusCode == 204) {
        return;
    }
    return jsonDecode(resp.body);
}

Future<dynamic> _get(String action, Map<String, String> qp, {int timeout = 20}) async {
    return _request('get', action, qp, timeout: timeout);
}


Future<dynamic> _post(String action, Map<String, String> qp, {int timeout = 20}) async {
    return _request('post', action, qp, timeout: timeout);
}

Future<dynamic> _patch(String action, Map<String, String> qp, {int timeout = 20}) async {
    return _request('patch', action, qp, timeout: timeout);
}


Future<Map<String, dynamic>> getCustomer(int id) async {
    l.i('API: get customer id=$id');
    return await _get('customers/$id', {});
}

Future<Map<String, dynamic>> getCustomers(List<int> ids, {int limit = 10, int skip = 0}) async {
    l.i('API: get customers ids=$ids');
    return await _get('customers', {'ids': ids.toString(), 'limit': limit.toString(), 'skip': skip.toString(), 'get_olt_data': 'true'});
}

Future<Map<String, dynamic>> getBuilding(int id, {int limit = 10}) async { // TODO: check #45
    l.i('API: get building id=$id');
    return await _get('buildings/$id', {});
}

Future<Map<String, dynamic>> getAttach(int customerId) async {
    l.i('API: get attachs customerId=$customerId');
    return await _get('customers/$customerId/attachs', {});
}

Future<List<Map>> searchCustomers(String query) async {
    l.i('API: search customers query="$query"');
    final res = await _get('customers/search', {'q': query});
    return List<Map>.from(res);
}

Future<Map> login(String username, String password) async {
    l.i('API: employee login username="$username"');
    return await _post('employees/login', {
        'username': username,
        'password': password,
    });
}

Future<List<Map>> getDivisions() async {
    l.i('API: get divisions');
    final raw = await _get('employees/divisions', {});
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
    final raw = await _post('tasks', qp);
    final id = raw['id'];
    if (id is int) return id;
    throw Exception('Task id missing');
}

Future<String> getEmployeeName(int id) async {
    l.i('API: get employee name id=$id');
    final raw = await _get('employees/name', {'id': id.toString()});
    return (raw['name'] ?? '').toString();
}

Future<Map> getOnt(int oltId, String sn) async {
    l.i('API: get ont data oltId=$oltId sn=$sn');
    return await _get('onts/$sn', {
        'olt_id': oltId.toString()
    });
}

Future<dynamic> restartOnt(String sn, int oltId) async {
    l.i('API: restart ONT sn=$sn oltId=$oltId');
    return await _post('onts/$sn/restart', {
        'olt_id': oltId.toString()
    });
}

Future<dynamic> rewriteSN(String sn, int customerId, String agreement) async {
    l.i('API: rewrite sn sn=$sn customerId=$customerId agreement=$agreement');
    return await _post('customers/$customerId/rewrite-sn', {
        'sn': sn,
        'agreement': agreement
    }, timeout: 360);
}
Future<dynamic> rewriteMAC(int customerId, String agreement) async {
    l.i('API: rewrite mac customerId=$customerId agreement=$agreement');
    return await _post('customers/$customerId/rewrite-mac', {
        'agreement': agreement
    });
}

Future<dynamic> toggleCATV(String sn, int oltId, int catvId, bool state) async {
    l.i('API: toggle catv sn=$sn oltId=$oltId catvID=$catvId');
    return await _patch('onts/$sn/catv/$catvId', {
        'olt_id': oltId.toString(),
        'state': state.toString()
    });
}

Future<Map<String, dynamic>> getTask(int id) async {
    l.i('API: get task id=$id');
    return await _get('tasks/$id', {});
}

Future<List<Map<dynamic, dynamic>>> getCustomerTasks(int customerId, {int skip = 0, int limit = 5, bool getCount = true}) async {
    l.i('API: get customer tasks id=$customerId');
    final res = await _get('customers/$customerId/tasks/', {});
    return List<Map<dynamic, dynamic>>.from(res);
}

Future<List<Map<String, dynamic>>> getCustomerItems(int customerId) async {
    l.i('API: get customer items id=$customerId');
    return List<Map<String, dynamic>>.from(await _get('customers/$customerId/items', {}));
}

Future<int> addComment(int id, String content) async {
    l.i('API: add comment id=$id content=$content');
    return (await _post('tasks/$id/comments', {'content': content}))['id'];
}
