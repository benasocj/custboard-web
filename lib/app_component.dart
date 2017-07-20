import 'package:angular_components/angular_components.dart';
import 'package:angular/core.dart';
import 'package:http/browser_client.dart';
import 'package:http/http.dart';

import 'package:custboard/api.dart';
import 'package:custboard/dashboard.dart';

/*
 * TODO: Use anonymous function instead where this function gets called once
 * https://github.com/dart-lang/angular2/issues/10 is fixed.
 */
BrowserClient getFactoryFunc() => new BrowserClient();

@Component(
  selector: 'my-app',
  templateUrl: 'app_component.html',
  directives: const [Dashboard],
  providers: const [
    const Provider(BaseClient, useFactory: getFactoryFunc),
    const Provider(Api, useClass: Api, deps: const [BaseClient]),
    materialProviders,
  ],
)
class AppComponent {}
