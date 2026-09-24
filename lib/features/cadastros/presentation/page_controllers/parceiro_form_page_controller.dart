import 'dart:async';

import 'package:br_validators/validators/br_validators.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/auth/repositories/auth_repository.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_entity.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_kind.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_upsert_entity.dart';
import 'package:costeira/features/cadastros/presentation/controllers/save_parceiro_controller.dart';
import 'package:costeira/features/cadastros/presentation/page_controllers/page_action_result.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class ParceiroFormPageController extends ChangeNotifier {
  ParceiroFormPageController(this._saveController, this._authRepository) {
    _saveController.addListener(notifyListeners);
    for (final item in _controllers) {
      item.addListener(notifyListeners);
    }
  }

  final SaveParceiroController _saveController;
  final AuthRepository _authRepository;

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController celularController = TextEditingController();
  final TextEditingController cpfController = TextEditingController();
  final TextEditingController cnpjController = TextEditingController();
  final TextEditingController nomeFantasiaController = TextEditingController();
  final TextEditingController razaoSocialController = TextEditingController();
  final TextEditingController enderecoController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();
  final TextEditingController complementoController = TextEditingController();

  final MaskTextInputFormatter phoneMaskFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'\d')},
  );
  final MaskTextInputFormatter cpfMaskFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {'#': RegExp(r'\d')},
  );
  final MaskTextInputFormatter cnpjMaskFormatter = MaskTextInputFormatter(
    mask: '##.###.###/####-##',
    filter: {'#': RegExp(r'\d')},
  );

  ParceiroKind _kind = ParceiroKind.fornecedor;
  int _appFazendasId = 0;
  ParceiroEntity? _current;
  int _tipoPessoa = WSConstantes.tipoPessoaFisica;
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
    cpfController,
    cnpjController,
    nomeFantasiaController,
    razaoSocialController,
    enderecoController,
    numeroController,
    complementoController,
  ];

  bool get isLoading => _saveController.isLoading;
  bool get isEditing => _current != null;
  bool get isPessoaFisica => _tipoPessoa == WSConstantes.tipoPessoaFisica;
  int get tipoPessoa => _tipoPessoa;
  ParceiroKind get kind => _kind;
  bool get isLookingUpCnpj => _isLookingUpCnpj;
  bool get isCnpjApproved => _isCnpjApproved;
  String? get cnpjMessage => _cnpjMessage;
  bool get cnpjMessageIsError => _cnpjMessageIsError;

  bool get isFormValid {
    if (nomeController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        _digits(celularController.text).length < 10 ||
        enderecoController.text.trim().isEmpty ||
        numeroController.text.trim().isEmpty) {
      return false;
    }
    if (isPessoaFisica) {
      return BRValidators.validateCPF(_digits(cpfController.text));
    }
    return BRValidators.validateCNPJ(_digits(cnpjController.text)) &&
        nomeFantasiaController.text.trim().isNotEmpty &&
        razaoSocialController.text.trim().isNotEmpty;
  }

  void init({
    required ParceiroKind kind,
    required int appFazendasId,
    ParceiroEntity? parceiro,
  }) {
    _kind = kind;
    _appFazendasId = appFazendasId;
    _current = parceiro;

    if (parceiro == null) {
      notifyListeners();
      return;
    }

    nomeController.text = parceiro.nome;
    emailController.text = parceiro.email;
    celularController.text = phoneMaskFormatter.maskText(
      _digits(parceiro.celular),
    );
    enderecoController.text = parceiro.endereco;
    numeroController.text = parceiro.numero;
    complementoController.text = parceiro.complemento;
    _tipoPessoa = parceiro.tipoPessoa == WSConstantes.tipoPessoaJuridica
        ? WSConstantes.tipoPessoaJuridica
        : WSConstantes.tipoPessoaFisica;

    if (isPessoaFisica) {
      cpfController.text = cpfMaskFormatter.maskText(
        _digits(parceiro.documento),
      );
    } else {
      cnpjController.text = cnpjMaskFormatter.maskText(_digits(parceiro.cnpj));
      nomeFantasiaController.text = parceiro.nomeFantasia;
      razaoSocialController.text = parceiro.razaoSocial;
      _isCnpjApproved = _digits(parceiro.cnpj).length == 14;
    }
    notifyListeners();
  }

  void setTipoPessoa(int value) {
    if (_tipoPessoa == value) {
      return;
    }
    _tipoPessoa = value;
    _isLookingUpCnpj = false;
    _isCnpjApproved = false;
    _cnpjMessage = null;
    _lastLookedUpCnpj = '';
    notifyListeners();
  }

  Future<void> onCnpjChanged(String value) async {
    if (isPessoaFisica) {
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
        ParceiroUpsertEntity(
          kind: _kind,
          id: _current?.id,
          appFazendasId: _appFazendasId,
          tipoPessoa: _tipoPessoa,
          nome: nomeController.text.trim(),
          email: emailController.text.trim(),
          celular: _digits(celularController.text),
          documento: _digits(cpfController.text),
          cnpj: _digits(cnpjController.text),
          razaoSocial: razaoSocialController.text.trim(),
          nomeFantasia: nomeFantasiaController.text.trim(),
          endereco: enderecoController.text.trim(),
          numero: numeroController.text.trim(),
          complemento: complementoController.text.trim(),
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
            'Nao foi possivel salvar o cadastro.',
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
