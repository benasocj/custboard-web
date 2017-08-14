import 'dart:async';
import 'dart:convert';

import 'package:angular/core.dart';
import 'package:http/http.dart';

@Injectable()
class Api {
  final BaseClient _client;

  Api(this._client);

  Future<List<Map<String, String>>> getPartners() async =>
      await _makeCall(_client.get, '/partners');

  Future<Map<String, dynamic>> getData(String partner, int interval) async {
    var uri = new Uri(
        path: '/partners/${partner}/data',
        queryParameters: <String, dynamic>{'interval': '$interval'});
    return await _makeCall(_client.get, uri.toString());
  }

  Future<dynamic> _makeCall(Function fn, String uri, [dynamic body]) async {
    Response resp;
    try {
      uri = 'api$uri';
      if (body == null) {
        resp = await fn('$uri');
      } else {
        resp = await fn('$uri',
            headers: {'Content-Type': 'application/json'},
            body: JSON.encode(body));
      }
    } catch (e) {
      print(e);
      rethrow;
    }
    return JSON.decode(resp.body);
  }
}
