import 'dart:async';

import 'package:angular_components/angular_components.dart';
import 'package:angular/angular.dart';
import 'package:charted/charts/charts.dart';

import 'package:custboard/api.dart';
import 'package:custboard/cust_data.dart';
import 'package:custboard/order_cat_component.dart';

@Component(
  selector: 'dashboard',
  templateUrl: 'dashboard.html',
  directives: const [
    CORE_DIRECTIVES,
    OrderCatComponent,
    materialDirectives,
  ],
)
class Dashboard implements AfterViewInit {
  @ViewChild('myChart')
  ElementRef chartEl;
  List<Map<String, String>> availablePartners;
  Timer timer;
  String chosenPartner;
  String chosenPartnerName;
  int chosenInterval;
  Api _api;
  CustData custData;
  /*
   * TODO: Remove this once `https://github.com/google/charted/issues/209` is
   * fixed and use `CartesianArea`'s `autoUpdate` instead. I can then also
   * remove all calls to `draw()` and only hold a reference for the `rows`
   * object instead holding the whole `ChartData` object.
   */
  CartesianArea _chartArea;

  Dashboard(this._api);

  @override
  ngAfterViewInit() {
    _setDefaultInterval();
    _setupChart();
    _getPartners();
  }

  Future<Null> _getPartners() async {
    availablePartners = await _api.getPartners();
  }

  void setPartner(Map<String, String> partner) {
    if (chosenPartner == partner['id']) return;
    chosenPartner = partner['id'];
    chosenPartnerName = partner['name'];
    configChanged();
  }

  void setInterval(int v) {
    chosenInterval = v;
    configChanged();
  }

  void configChanged() {
    if (chosenPartner == null) return;
    if (timer?.isActive ?? false) {
      timer.cancel();
    }
    _updateCustData();
  }

  Future<Null> _updateCustData() async {
    custData = new CustData.fromJson(
      await _api.getData(chosenPartner, chosenInterval), chosenInterval);

    _updateChart();

    DateTime now = new DateTime.now();
    DateTime midnight = new DateTime(now.year, now.month, now.day);
    Duration secondsFromMidnight = new Duration(seconds:
      (now.difference(midnight).inSeconds ~/ chosenInterval + 1)
        * chosenInterval);
    timer = new Timer(
      midnight.add(secondsFromMidnight).difference(now),
      _updateCustData
    );
  }

  void _setupChart() {
    ChartSeries series = new ChartSeries(
      null, <int>[1], new LineChartRenderer());
    ChartConfig config = new ChartConfig(
      <ChartSeries>[series], <int>[0]);
    ChartData data = new ChartData(
      <ChartColumnSpec>[
        new ChartColumnSpec(
          label: 'Time',
          type: ChartColumnSpec.TYPE_TIMESTAMP),
        new ChartColumnSpec(label: 'Throughput'),
      ],
      <List<int>>[]
    );
    _chartArea = new CartesianArea(chartEl.nativeElement, data, config)
      ..addChartBehavior(new Hovercard());
  }

  void _updateChart() {
    _chartArea.data.rows.clear();
    for (String date in custData.chartData.keys) {
      _chartArea.data.rows.add([
        DateTime.parse(date).millisecondsSinceEpoch,
        custData.chartData[date],
      ]);
    }
    _chartArea.draw();
  }

  void _setDefaultInterval() {
    for (Map<String, dynamic> i in intervals) {
      if (i['isDefault']) {
        chosenInterval = i['seconds'];
        break;
      }
    }
  }

  List<Map<String, dynamic>> get intervals => const <Map<String, dynamic>>[
    const <String, dynamic>{
      'label': '1 min', 'seconds': 60, 'isDefault': false},
    const <String, dynamic>{
      'label': '5 min', 'seconds': 5 * 60, 'isDefault': false},
    const <String, dynamic>{
      'label': '10 min', 'seconds': 10 * 60, 'isDefault': false},
    const <String, dynamic>{
      'label': '15 min', 'seconds': 15 * 60, 'isDefault': true},
    const <String, dynamic>{
      'label': '30 min', 'seconds': 30 * 60, 'isDefault': false},
    const <String, dynamic>{
      'label': '60 min', 'seconds': 60 * 60, 'isDefault': false},
  ];
}
