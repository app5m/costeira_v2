import 'package:flutter/material.dart';

class TransferenciasPageController extends ChangeNotifier {
  TabController? _tabController;
  int _tabIndex = 0;

  TabController get tabController => _tabController!;
  int get tabIndex => _tabIndex;
  bool get shouldShowFab => _tabIndex < 2;

  void init(TickerProvider vsync) {
    if (_tabController != null && _tabController!.length == 3) {
      return;
    }
    _tabController?.dispose();
    _tabController = TabController(length: 3, vsync: vsync);
  }

  void setTabIndex(int index) {
    _tabIndex = index;
    notifyListeners();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _tabController = null;
    super.dispose();
  }
}
