@Tags(const ['aot'])
@TestOn('browser')

import 'dart:async';
import 'dart:html';

import 'package:angular_components/angular_components.dart';
import 'package:angular_test/angular_test.dart';
import 'package:angular/angular.dart';
import 'package:http/http.dart';
import 'package:pageloader/html.dart';
import 'package:test/test.dart';

import 'package:custboard/api.dart';
import 'package:custboard/application_tokens.dart';
import 'package:custboard/dashboard.dart';
import 'package:custboard/testing.dart';
import 'dashboard_po.dart';

PageLoader Function(Element el, NgTestFixture<Dashboard> fixture)
    _getCreatePageLoaderFunc(Element el) {
  return (_, fixture) => new HtmlPageLoader(el, executeSyncedFn: (fn) async {
        await fn();
        return fixture.update();
      });
}

@AngularEntrypoint()
void main() {
  DashboardPO po;
  NgTestFixture<Dashboard> fixture;

  tearDown(disposeAnyRunningTest);

  setUp(() async {
    var parentDiv = new DivElement(),
        hostDiv = new DivElement(),
        overlayContDiv = new DivElement();
    parentDiv.children..add(hostDiv)..add(overlayContDiv);
    final testBed = new NgTestBed<Dashboard>(host: hostDiv)
        .setPageLoader(_getCreatePageLoaderFunc(parentDiv))
        .addProviders([
      provide(BaseClient, useFactory: mockClientFactory),
      provide(Api, useClass: Api, deps: [BaseClient]),
      provide(autoUpdate, useValue: false),
      materialProviders,
      provide(overlayContainerParent, useValue: overlayContDiv),
    ]);
    fixture = await testBed.create();
    po = await fixture.resolvePageObject(DashboardPO);
    await fixture.update();
  });

  group('radio:', () {
    test('check initial state', () async {
      expect(await po.isRadioChecked(3), true);
    });

    test('click 60', () async {
      await po.clickRadio(0);
      expect(await po.isRadioChecked(0), true);
      await fixture.update((c) {
        expect(c.chosenInterval, 60);
      });
    });
  });

  group('dropdown:', () {
    test('check initial state', () async {
      expect(await po.dropdownLabel, 'Select partner');
    });

    group('click dropdown:', () {
      setUp(() async {
        await po.clickDropdown();
        // Wait until dropdown popup is fully opened.
        await new Future.delayed(const Duration(milliseconds: 500));
        po = await fixture.resolvePageObject(DashboardPO);
      });

      test('check length', () async {
        expect(po.dropdownLength, 2);
      });

      group('click dropdown item:', () {
        setUp(() async {
          await po.clickDropdownItem(0);
          po = await fixture.resolvePageObject(DashboardPO);
        });

        test('check label and Unreleased shown', () async {
          expect(await po.dropdownLabel, 'name1');
          expect(await po.bottomBarText, contains('Unreleased'));
        });

        test('disabling dropdown item must not be possible', () async {
          await po.clickDropdown();
          // Wait until dropdown popup is fully opened.
          await new Future.delayed(const Duration(milliseconds: 500));
          po = await fixture.resolvePageObject(DashboardPO);

          await po.clickDropdownItem(0);
          po = await fixture.resolvePageObject(DashboardPO);
          expect(await po.dropdownLabel, 'name1');
          expect(await po.bottomBarText, contains('Unreleased'));
        });
      });
    });
  });
}
