import 'dart:async';

import 'package:br_validators/validators/br_validators.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/account/models/account_profile.dart';
import 'package:costeira/features/account/repositories/account_repository.dart';
import 'package:costeira/features/auth/repositories/auth_repository.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_entity.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_upsert_entity.dart';
import 'package:costeira/features/fazendas/presentation/controllers/save_fazenda_controller.dart';
import 'package:costeira/features/fazendas/presentation/page_controllers/page_action_result.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class FazendaFormPageController extends ChangeNotifier {
  FazendaFormPageController(
    this._saveController,
    this._accountRepository,
    this._authRepository,
  ) {
    _saveController.addListener(notifyListeners);
    for (final item in _controllers) {
      item.addListener(notifyListeners);
    }
  }

  final SaveFazendaController _saveController;
  final AccountRepository _accountRepository;
  final AuthRepository _authRepository;

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController celularController = TextEditingController();
  final TextEditingController cnpjController = TextEditingController();
  final TextEditingController nomeFantasiaController = TextEditingController();
  final TextEditingController razaoSocialController = TextEditingController();

  final MaskTextInputFormatter phoneMaskFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'\d')},
  );
  final MaskTextInputFormatter cnpjMaskFormatter = MaskTextInputFormatter(
    mask: '##.###.###/####-##',
    filter: {'#': RegExp(r'\d')},
  );

  FazendaEntity? _currentFazenda;
  AccountProfile? _profile;
  String? _profileError;
  bool _mesmoCnpj = true;
  bool _isLoadingProfile = true;
  bool _isLookingUpCnpj = false;
  bool _isCnpjApproved = false;
  String? _cnpjMessage;
  bool _cnpjMessageIsError = false;
  String _lastLookedUpCnpj = '';
  int _cnpjLookupRequestId = 0;
  Timer? _cnpjDebounce;

  List<TextEditingController> get _controllers => [
    nomeController,
    emailController,
    celularController,
    cnpjController,
    nomeFantasiaController,
    razaoSocialController,
  ];

  bool get isLoading => _saveController.isLoading;
  bool get isLoadingProfile => _isLoadingProfile;
  bool get mesmoCnpj => _mesmoCnpj;
  bool get isLookingUpCnpj => _isLookingUpCnpj;
  bool get isCnpjApproved => _isCnpjApproved;
  String? get cnpjMessage => _cnpjMessage;
  bool get cnpjMessageIsError => _cnpjMessageIsError;
  bool get isEditing => _currentFazenda != null;
  AccountProfile? get profile => _profile;
  String? get profileError => _profileError;
  bool get hasMatrizProfile =>
      _profile != null && _profile!.id > 0 && _profile!.cnpj.trim().isNotEmpty;

  bool get isFormValid {
    if (nomeController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        _digits(celularController.text).length < 10) {
      return false;
    }
    if (_mesmoCnpj) {
      return true;
    }
    final cnpj = _digits(cnpjController.text);
    return BRValidators.validateCNPJ(cnpj) &&
        nomeFantasiaController.text.trim().isNotEmpty &&
        razaoSocialController.text.trim().isNotEmpty;
  }

  Future<void> init({FazendaEntity? fazenda}) async {
    _currentFazenda = fazenda;
    _isLoadingProfile = true;
    notifyListeners();

    try {
      final user = await SessionStorage.getUserSession();
      if (user != null) {
        _profile = await _accountRepository.fetchProfile(userId: user.id);
        _profileError = null;
      }
    } on ApiException catch (error) {
      _profile = null;
      _profileError = error.message;
    }

    if (!hasMatrizProfile) {
      _mesmoCnpj = false;
    }

    if (fazenda != null) {
      nomeController.text = fazenda.nome;
      emailController.text = fazenda.email;
      celularController.text = phoneMaskFormatter.maskText(
        _digits(fazenda.celular),
      );
      _mesmoCnpj = fazenda.usesSameCnpj;
      if (!_mesmoCnpj) {
        cnpjController.text = cnpjMaskFormatter.maskText(_digits(fazenda.cnpj));
        nomeFantasiaController.text = fazenda.nomeFantasia;
        razaoSocialController.text = fazenda.razaoSocial;
        _isCnpjApproved = _digits(fazenda.cnpj).length == 14;
      }
    } else {
      _applyMatrizCnpj();
    }

    _isLoadingProfile = false;
    notifyListeners();
  }

  void setMesmoCnpj(bool value) {
    if (value && !hasMatrizProfile) {
      return;
    }
    if (_mesmoCnpj == value) {
      return;
    }
    _mesmoCnpj = value;
    if (value) {
      _applyMatrizCnpj();
      _isLookingUpCnpj = false;
      _cnpjMessage = null;
      _cnpjMessageIsError = false;
    } else {
      cnpjController.clear();
      nomeFantasiaController.clear();
      razaoSocialController.clear();
      _isCnpjApproved = false;
      _lastLookedUpCnpj = '';
      cnpjMaskFormatter.clear();
    }
    notifyListeners();
  }

  Future<void> onCnpjChanged(String value) async {
    if (_mesmoCnpj) {
      return;
    }

    final cleanValue = _digits(value);
    if (cleanValue.length < 14) {
      _cnpjDebounce?.cancel();
      _isCnpjApproved = false;
      _isLookingUpCnpj = false;
      _cnpjMessage = null;
      _cnpjMessageIsError = false;
      notifyListeners();
      return;
    }

    if (!BRValidators.validateCNPJ(cleanValue)) {
      _isCnpjApproved = false;
      _isLookingUpCnpj = false;
      _cnpjMessage = 'CNPJ invalido.';
      _cnpjMessageIsError = true;
      _lastLookedUpCnpj = cleanValue;
      notifyListeners();
      return;
    }

    if (_lastLookedUpCnpj == cleanValue) {
      return;
    }

    _cnpjDebounce?.cancel();
    _cnpjDebounce = Timer(const Duration(milliseconds: 700), () {
      _lookupCnpj(cleanValue);
    });
  }

  Future<PageActionResult> submit() async {
    if (!isFormValid) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Preencha os campos obrigatorios.',
      );
    }

    try {
      final result = await _saveController.save(
        FazendaUpsertEntity(
          id: _currentFazenda?.id,
          mesmoCnpj: _mesmoCnpj
              ? WSConstantes.mesmoCnpjSim
              : WSConstantes.mesmoCnpjNao,
          nome: nomeController.text.trim(),
          email: emailController.text.trim(),
          celular: _digits(celularController.text),
          tipoPessoa: WSConstantes.tipoPessoaJuridica,
          documento: '',
          cnpj: _digits(cnpjController.text),
          razaoSocial: razaoSocialController.text.trim(),
          nomeFantasia: nomeFantasiaController.text.trim(),
          status: _currentFazenda?.status ?? 1,
        ),
      );

      return PageActionResult(
        isSuccess: result.isSuccess,
        message: result.message,
      );
    } catch (_) {
      return PageActionResult(
        isSuccess: false,
        message:
            _saveController.errorMessage ??
            'Nao foi possivel salvar a fazenda.',
      );
    }
  }

  Future<void> _lookupCnpj(String cleanValue) async {
    final requestId = ++_cnpjLookupRequestId;
    _isLookingUpCnpj = true;
    _isCnpjApproved = false;
    _cnpjMessage = 'Consultando CNPJ. Pode demorar alguns segundos.';
    _cnpjMessageIsError = false;
    notifyListeners();

    try {
      final result = await _authRepository.lookupCnpj(
        cnpjController.text.trim(),
      );
      if (requestId != _cnpjLookupRequestId) {
        return;
      }

      if (result.nomeFantasia.isNotEmpty) {
        nomeFantasiaController.text = result.nomeFantasia;
      }
      if (result.razaoSocial.isNotEmpty) {
        razaoSocialController.text = result.razaoSocial;
      }

      _lastLookedUpCnpj = cleanValue;
      _isLookingUpCnpj = false;
      _isCnpjApproved = true;
      _cnpjMessage = result.situacaoCadastral.isEmpty
          ? 'CNPJ validado com sucesso.'
          : 'CNPJ ${result.situacaoCadastral}.';
      _cnpjMessageIsError = false;
      notifyListeners();
    } on ApiException catch (error) {
      if (requestId != _cnpjLookupRequestId) {
        return;
      }
      _isLookingUpCnpj = false;
      if (error.isTimeout) {
        _cnpjMessage =
            'Consulta do CNPJ demorou. Preencha fantasia e razão social para salvar.';
        _cnpjMessageIsError = false;
        notifyListeners();
        return;
      }
      _lastLookedUpCnpj = cleanValue;
      _isCnpjApproved = false;
      _cnpjMessage = error.message;
      _cnpjMessageIsError = true;
      notifyListeners();
    }
  }

  void _applyMatrizCnpj() {
    final profile = _profile;
    if (profile == null) {
      return;
    }
    if (profile.cnpj.isNotEmpty) {
      cnpjController.text = cnpjMaskFormatter.maskText(_digits(profile.cnpj));
    }
    nomeFantasiaController.text = profile.nomeFantasia;
    razaoSocialController.text = profile.razaoSocial;
    _isCnpjApproved = _digits(profile.cnpj).length == 14;
  }

  String _digits(String value) => value.replaceAll(RegExp(r'\D'), '');

  @override
  void dispose() {
    _cnpjDebounce?.cancel();
    _saveController.removeListener(notifyListeners);
    for (final item in _controllers) {
      item.removeListener(notifyListeners);
      item.dispose();
    }
    super.dispose();
  }
}
