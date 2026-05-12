import 'package:flutter/material.dart';

class ComprasPageController extends ChangeNotifier {
  late TabController _tabController;
  int _tabIndex = 0;

  TabController get tabController => _tabController;
  int get tabIndex => _tabIndex;
  bool get shouldShowFab => _tabIndex == 0;

  void init(TickerProvider vsync) {
    _tabController = TabController(length: 2, vsync: vsync);
    _tabController.addListener(_handleTabChange);
  }

  void setTabIndex(int value) {
    if (_tabIndex == value) {
      return;
    }
    _tabIndex = value;
    notifyListeners();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      return;
    }
    setTabIndex(_tabController.index);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }
}
