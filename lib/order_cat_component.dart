import 'package:angular/core.dart';

import 'package:custboard/cust_data.dart';

@Component(
  selector: 'my-order-cat',
  templateUrl: 'order_cat_component.html'
)
class OrderCatComponent {
  @Input('myOrderCat')
  OrderCat orderCat;
}
