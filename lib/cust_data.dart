class CustData {
  final int conversion;
  final OrderCat openOld;
  final OrderCat openToday;
  final OrderCat unreleased;
  final OrderCat released;
  final OrderCat packed;
  final Map<String, int> chartData;
  final int chosenInterval;

  CustData(this.conversion, this.openOld, this.openToday, this.unreleased,
      this.released, this.packed, this.chartData, this.chosenInterval);

  String get timeLeft {
    if (conversion == 0) {
      return 'invalid conversion rate';
    }
    double hoursFractional =
        total.orders / (conversion * (3600 / chosenInterval));
    var hours = hoursFractional.toInt();
    var minutes = (hoursFractional % 1 * 60).toInt();
    return '${hours}h${minutes.toString().padLeft(2, '0')}m';
  }

  OrderCat get total => openOld + openToday;

  factory CustData.fromJson(Map<String, dynamic> data, int chosenInterval) =>
      new CustData(
          data['conversion'],
          new OrderCat.fromJson(data['openOld']),
          new OrderCat.fromJson(data['openToday']),
          new OrderCat.fromJson(data['unreleased']),
          new OrderCat.fromJson(data['released']),
          new OrderCat.fromJson(data['packed']),
          data['chartData'],
          chosenInterval);
}

class OrderCat {
  final int orders;
  final int units;

  OrderCat(this.orders, this.units);

  factory OrderCat.fromJson(Map<String, dynamic> data) =>
      new OrderCat(data['orders'], data['units']);

  /// Required for doing a `openOld + openToday`.
  OrderCat operator +(OrderCat oc) =>
      new OrderCat(orders + oc.orders, units + oc.units);
}
