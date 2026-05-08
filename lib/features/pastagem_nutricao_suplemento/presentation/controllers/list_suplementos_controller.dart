import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/suplemento.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/suplemento_filter.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/usecases/get_suplementos_usecase.dart';
import 'package:flutter/foundation.dart';

class ListSuplementosController extends ChangeNotifier {
  ListSuplementosController(this._getSuplementosUsecase);

  final GetSuplementosUsecase _getSuplementosUsecase;

  bool _isLoading = false;
  String? _errorMessage;
  List<Suplemento> _suplementos = const [];
  int _rows = 0;
  SuplementoFilterEntity? _currentFilter;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Suplemento> get suplementos => _suplementos;
  int get rows => _rows;
  SuplementoFilterEntity? get currentFilter => _currentFilter;
  List<SuplementoRegistro> get registros =>
      _suplementos.expand((item) => item.registros).toList(growable: false);

  Future<void> load({
    int? id,
    int? idPotreiro,
    int? idLote,
    int? idProduto,
  }) async {
    AppLogger.info('SUPLEMENTACAO LIST CONTROLLER: INICIANDO CARREGAMENTO');
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuario nao autenticado.');
      }

      _currentFilter = SuplementoFilterEntity(
        appUsersId: user.id,
        id: id,
        idPotreiro: idPotreiro,
        idLote: idLote,
        idProduto: idProduto,
      );

      final result = await _getSuplementosUsecase(_currentFilter!);
      _suplementos = result.data;
      _rows = result.rows;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> reload() async {
    final filter = _currentFilter;
    if (filter == null) {
      await load();
      return;
    }

    await load(
      id: filter.id,
      idPotreiro: filter.idPotreiro,
      idLote: filter.idLote,
      idProduto: filter.idProduto,
    );
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
