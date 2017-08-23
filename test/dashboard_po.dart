import 'dart:async';

import 'package:pageloader/objects.dart';

class DashboardPO {
  @ByCss('material-dropdown-select .button-text')
  PageLoaderElement _dropdown;

  @ByTagName('material-radio')
  List<PageLoaderElement> _radios;

  @ById('bottom-bar')
  @optional
  PageLoaderElement _bottomBar;

  @ByTagName('material-select-dropdown-item')
  List<PageLoaderElement> _dropdownItems;

  Future<String> get dropdownLabel => _dropdown.visibleText;

  Future<bool> isRadioChecked(int index) async =>
      await _radios[index].attributes['aria-checked'] == 'true';

  Future<Null> clickRadio(int index) async => await _radios[index].click();

  Future<String> get bottomBarText => _bottomBar.visibleText;

  Future<Null> clickDropdown() => _dropdown.click();

  int get dropdownLength => _dropdownItems.length;

  Future<Null> clickDropdownItem(int index) => _dropdownItems[index].click();
}
