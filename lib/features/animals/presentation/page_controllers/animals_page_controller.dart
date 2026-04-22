import 'package:costeira/core/utils/app_logger.dart';
import 'package:flutter/material.dart';

class AnimalsPageController extends ChangeNotifier {
  TabController? _tabController;
  int _animalsListVersion = 0;
  int _lotsListVersion = 0;
  int _tabIndex = 0;

  TabController get tabController => _tabController!;
  int get animalsListVersion => _animalsListVersion;
  int get lotsListVersion => _lotsListVersion;
  int get tabIndex => _tabIndex;
  bool get shouldShowFab => _tabIndex == 1 || _tabIndex == 2;
  bool get isAnimalsTab => _tabIndex == 1;

  void init(TickerProvider vsync) {
    AppLogger.info('ANIMAIS PAGE CONTROLLER: INICIALIZANDO TABS');
    _tabController = TabController(length: 3, vsync: vsync);
  }

  void setTabIndex(int value) {
    AppLogger.debug('ANIMAIS PAGE CONTROLLER: ALTERANDO ABA PARA INDEX=$value');
    _tabIndex = value;
    _tabController?.index = value;
    notifyListeners();
  }

  void handleAnimalCreated() {
    AppLogger.info('ANIMAIS PAGE CONTROLLER: ATUALIZANDO LISTA DE ANIMAIS');
    _animalsListVersion++;
    setTabIndex(1);
  }

  void handleLotCreated() {
    AppLogger.info('ANIMAIS PAGE CONTROLLER: ATUALIZANDO LISTA DE LOTES');
    _lotsListVersion++;
    setTabIndex(2);
  }

  @override
  void dispose() {
    AppLogger.info('ANIMAIS PAGE CONTROLLER: DISPONDO TABS');
    _tabController?.dispose();
    super.dispose();
  }
}
