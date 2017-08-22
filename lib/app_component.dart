import 'package:angular_components/angular_components.dart';
import 'package:angular/core.dart';
import 'package:http/browser_client.dart';
import 'package:http/http.dart';

import 'package:custboard/api.dart';
import 'package:custboard/application_tokens.dart';
import 'package:custboard/dashboard.dart';

BrowserClient browserClientFactory() => new BrowserClient();

@Component(
  selector: 'my-app',
  templateUrl: 'app_component.html',
  directives: const [Dashboard],
  providers: const [
    const Provider(BaseClient, useFactory: browserClientFactory),
    const Provider(Api, useClass: Api, deps: const [BaseClient]),
    const Provider(autoUpdate, useValue: true),
    materialProviders,
  ],
)
class AppComponent {}
