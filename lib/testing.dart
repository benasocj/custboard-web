import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:angular/core.dart';
import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:intl/intl.dart';

@Injectable()
MockClient mockClientFactory() {
  return new MockClient(new TestClient().handler);
}

class TestClient {
  var _cnt = 0;
  var _chartData = new Map<String, int>();

  TestClient() {
    for (int i = 0; i < 2; i++) {
      _addChartData();
      _cnt++;
    }
  }

  Future<Response> handler(Request request) async {
    var path = request.url.pathSegments.sublist(1);

    dynamic data;
    if (_eq(['partners'], path)) {
      switch (request.method) {
        case 'GET':
          data = [
            {'id': 'pa1', 'name': 'name1'},
            {'id': 'pa2', 'name': 'name2'},
          ];
          break;
      }
    } else if (_eq(['partners', 'pa1', 'data'], path) ||
        _eq(['partners', 'pa2', 'data'], path)) {
      switch (request.method) {
        case 'GET':
          int offset = _cnt + (path[1] == 'pa1' ? 0 : 1000);
          _addChartData();
          data = {
            'conversion': 1 + offset,
            'openOld': {
              'orders': 100 + offset,
              'units': 101 + offset,
            },
            'openToday': {
              'orders': 200 + offset,
              'units': 201 + offset,
            },
            'unreleased': {
              'orders': 400 + offset,
              'units': 401 + offset,
            },
            'released': {
              'orders': 500 + offset,
              'units': 501 + offset,
            },
            'packed': {
              'orders': 600 + offset,
              'units': 601 + offset,
            },
            'chartData': _chartData,
          };
          _cnt++;
          break;
      }
    }
    return new Response(JSON.encode(data), 200,
        headers: {'content-type': 'application/json'});
  }

  void _addChartData() {
    var timestamp = new DateFormat('yyyy-MM-ddTHH:mm:ss')
        .format(new DateTime(2017, 1, 1, 8).add(new Duration(hours: _cnt)));
    _chartData[timestamp] = new Random().nextInt(1000) + 500;
  }

  bool _eq(List<String> pathTest, List<String> pathIs) {
    return const IterableEquality().equals(pathTest, pathIs);
  }
}
