import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/movimentacoes/transferencias/domain/usecases/aceitar_transferencia_fazenda_usecase.dart';
import 'package:flutter/foundation.dart';

class AceitarTransferenciaFazendaController extends ChangeNotifier {
  AceitarTransferenciaFazendaController(this._usecase);

  final AceitarTransferenciaFazendaUsecase _usecase;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<ApiMessage?> submit({
    required int id,
    required int statusTransferencia,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      return await _usecase(
        id: id,
        statusTransferencia: statusTransferencia,
      );
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return null;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
