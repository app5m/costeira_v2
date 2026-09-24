import 'dart:async';

import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_entity.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_kind.dart';
import 'package:costeira/features/cadastros/presentation/controllers/delete_parceiro_controller.dart';
import 'package:costeira/features/cadastros/presentation/controllers/list_parceiros_controller.dart';
import 'package:costeira/features/cadastros/presentation/page_controllers/page_action_result.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_entity.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_filter_entity.dart';
import 'package:costeira/features/fazendas/domain/usecases/get_fazendas_usecase.dart';
import 'package:flutter/material.dart';

class ParceirosListPageController extends ChangeNotifier {
  ParceirosListPageController(
    this._listController,
    this._deleteController,
    this._getFazendasUsecase,
  ) {
    _listController.addListener(notifyListeners);
    _deleteController.addListener(notifyListeners);
    nomeController.addListener(_onNomeChanged);
  }

  final ListParceirosController _listController;
  final DeleteParceiroController _deleteController;
  final GetFazendasUsecase _getFazendasUsecase;
  final TextEditingController nomeController = TextEditingController();

  ParceiroKind _kind = ParceiroKind.fornecedor;
  List<FazendaEntity> _fazendas = const [];
  int? _selectedFarmId;
  Timer? _nomeDebounce;
  bool _isLoadingFarms = false;
  String? _farmsError;

  ParceiroKind get kind => _kind;
  List<FazendaEntity> get fazendas => _fazendas;
  int? get selectedFarmId => _selectedFarmId;
  List<ParceiroEntity> get parceiros => _listController.parceiros;
  bool get isLoading => _listController.isLoading || _isLoadingFarms;
  bool get isDeleting => _deleteController.isLoading;
  String? get errorMessage => _farmsError ?? _listController.errorMessage;

  FazendaEntity? get selectedFarm {
    final id = _selectedFarmId;
    if (id == null) {
      return null;
    }
    for (final farm in _fazendas) {
      if (farm.id == id) {
        return farm;
      }
    }
    return null;
  }

  void init(ParceiroKind kind) {
    _kind = kind;
  }

  Future<PageActionResult?> loadInitialData() async {
    _isLoadingFarms = true;
    _farmsError = null;
    notifyListeners();

    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw Exception('Usuario nao autenticado.');
      }

      final result = await _getFazendasUsecase(
        FazendaFilterEntity(appUsersId: user.id),
      );
      _fazendas = result.data;
      final savedFarmId = await SessionStorage.getSelectedFarmId();
      if (savedFarmId != null &&
          _fazendas.any((farm) => farm.id == savedFarmId)) {
        _selectedFarmId = savedFarmId;
      } else {
        _selectedFarmId = _fazendas.isEmpty ? null : _fazendas.first.id;
      }
    } catch (_) {
      _farmsError = 'Nao foi possivel carregar as fazendas.';
      _isLoadingFarms = false;
      notifyListeners();
      return PageActionResult(isSuccess: false, message: _farmsError!);
    }

    _isLoadingFarms = false;
    notifyListeners();

    if (_selectedFarmId == null) {
      _listController.clear();
      return null;
    }

    return _loadParceiros();
  }

  Future<PageActionResult?> selectFarm(int farmId) async {
    if (_selectedFarmId == farmId) {
      return null;
    }
    _selectedFarmId = farmId;
    notifyListeners();
    return _loadParceiros();
  }

  Future<PageActionResult?> reload() {
    return _loadParceiros();
  }

  Future<PageActionResult> deleteParceiro(ParceiroEntity parceiro) async {
    try {
      final result = await _deleteController.delete(
        kind: _kind,
        id: parceiro.id,
      );
      _listController.removeById(parceiro.id);
      return PageActionResult(isSuccess: true, message: result.message);
    } catch (_) {
      return PageActionResult(
        isSuccess: false,
        message:
            _deleteController.errorMessage ??
            'Nao foi possivel excluir o cadastro.',
      );
    }
  }

  Future<PageActionResult?> _loadParceiros() async {
    final farmId = _selectedFarmId;
    if (farmId == null) {
      _listController.clear();
      return null;
    }

    try {
      final nome = nomeController.text.trim();
      await _listController.load(
        kind: _kind,
        appFazendasId: farmId,
        nome: nome.isEmpty ? null : nome,
      );
      return null;
    } catch (_) {
      return PageActionResult(
        isSuccess: false,
        message:
            _listController.errorMessage ??
            'Nao foi possivel carregar os cadastros.',
      );
    }
  }

  void _onNomeChanged() {
    _nomeDebounce?.cancel();
    _nomeDebounce = Timer(const Duration(milliseconds: 400), () {
      _loadParceiros();
    });
    notifyListeners();
  }

  @override
  void dispose() {
    _nomeDebounce?.cancel();
    nomeController.removeListener(_onNomeChanged);
    nomeController.dispose();
    _listController.removeListener(notifyListeners);
    _deleteController.removeListener(notifyListeners);
    super.dispose();
  }
}
