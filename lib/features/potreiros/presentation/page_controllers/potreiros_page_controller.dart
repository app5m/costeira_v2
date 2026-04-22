import 'package:flutter/material.dart';

class PotreirosPageController extends ChangeNotifier {
  TabController? _tabController;
  int _listVersion = 0;
  int _tabIndex = 0;

  TabController get tabController => _tabController!;
  int get listVersion => _listVersion;
  int get tabIndex => _tabIndex;
  bool get shouldShowFab => _tabIndex == 1;

  void init(TickerProvider vsync) {
    _tabController = TabController(length: 2, vsync: vsync);
  }

  void setTabIndex(int value) {
    _tabIndex = value;
    _tabController?.index = value;
    notifyListeners();
  }

  void handleCreatedOrUpdated() {
    _listVersion++;
    setTabIndex(1);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
}
