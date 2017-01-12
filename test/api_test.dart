@Tags(const ['aot'])
@TestOn('browser')

import 'dart:async';

import 'package:angular2/core.dart';
import 'package:angular_test/angular_test.dart';
import 'package:http/http.dart';
import 'package:test/test.dart';

import 'package:custboard/api.dart';
import 'package:custboard/dashboard.dart';
import 'package:custboard/testing.dart' show TestClient;

@AngularEntrypoint()
void main() {
  tearDown(disposeAnyRunningTest);

  group('GET', () {
    test('/cust-data', () async {
      final testBed = new NgTestBed<Dashboard>()
        .addProviders([
          provide(BaseClient, useClass: TestClient),
          provide(Api, useClass: Api, deps: [BaseClient]),
        ]);
      final fixture = await testBed.create();
      await fixture.update();
      expect(fixture.rootElement.innerHtml, contains('100'));

      await new Future.delayed(const Duration(milliseconds: 1100));
      await fixture.update();
      expect(fixture.rootElement.innerHtml, contains('102'));
    });
  });
}
