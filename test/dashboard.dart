@Tags(const ['aot'])
@TestOn('browser')

import 'dart:async';
import 'dart:html';

import 'package:angular_components/angular_components.dart';
import 'package:angular_test/angular_test.dart';
import 'package:angular/angular.dart';
import 'package:http/http.dart';
import 'package:test/test.dart';

import 'package:custboard/api.dart';
import 'package:custboard/application_tokens.dart';
import 'package:custboard/dashboard.dart';
import 'package:custboard/order_cat_component.dart';
import 'package:custboard/testing.dart';
import 'dashboard_po.dart';

@AngularEntrypoint()
void main() {
  DashboardPO po;
  NgTestFixture<ExtensionComponent> fixture;

  tearDown(disposeAnyRunningTest);

  setUp(() async {
    final testBed = new NgTestBed<ExtensionComponent>().addProviders([
      provide(BaseClient, useClass: TestClient),
      provide(Api, useClass: Api, deps: [BaseClient]),
      provide(autoUpdate, useValue: false),
    ]);
    fixture = await testBed.create();
    po = await fixture.resolvePageObject(DashboardPO);
    await fixture.update();
  });

  test('check initial screen', () async {
    expect(await po.dropdownLabel, 'Select partner');
    expect(await po.isRadioChecked(3), true);
  });

  group('radio', () {
    test('click 60', () async {
      await po.clickRadio(0);
      expect(await po.isRadioChecked(0), true);
      await fixture.update((c) {
        expect(c.chosenInterval, 60);
      });
    });
  });

  group('dropdown', () {
    setUp(() async {
      await po.clickDropdown();
      // Wait until dropdown popup is fully opened.
      await new Future.delayed(const Duration(milliseconds: 500));
      po = await fixture.resolvePageObject(DashboardPO);
    });

    test('check length', () async {
      expect(po.dropdownLength, 2);
    });

    test('click dropdown item', () async {
      await po.clickDropdownItem(0);
      po = await fixture.resolvePageObject(DashboardPO);
      expect(await po.dropdownLabel, 'name1');
      expect(await po.bottomBarText, contains('Unreleased'));
    });
  });
}

HtmlElement getOverlayContainerParent(Element parent) => parent;

@Component(
  selector: 'dashboard',
  templateUrl: 'package:custboard/dashboard.html',
  directives: const [
    CORE_DIRECTIVES,
    OrderCatComponent,
    materialDirectives,
  ],
  providers: const [
    materialProviders,
    const Provider(overlayContainerParent,
        useFactory: getOverlayContainerParent, deps: const [Element]),
  ],
)
class ExtensionComponent extends Dashboard {
  ExtensionComponent(Api api, @Inject(autoUpdate) bool useTimer)
      : super(api, useTimer);
}
