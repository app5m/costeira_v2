import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_entity.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_filter_entity.dart';
import 'package:costeira/features/fazendas/domain/usecases/get_fazendas_usecase.dart';
import 'package:costeira/features/usuarios/domain/entities/sub_usuario_entity.dart';
import 'package:costeira/features/usuarios/domain/entities/sub_usuario_upsert_entity.dart';
import 'package:costeira/features/usuarios/domain/entities/usuario_permissao_entity.dart';
import 'package:costeira/features/usuarios/domain/usecases/get_usuario_permissoes_usecase.dart';
import 'package:costeira/features/usuarios/presentation/controllers/save_sub_usuario_controller.dart';
import 'package:costeira/features/usuarios/presentation/page_controllers/page_action_result.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class SubUsuarioFormPageController extends ChangeNotifier {
  SubUsuarioFormPageController(
    this._saveController,
    this._getFazendasUsecase,
    this._getPermissoesUsecase,
  ) {
    _saveController.addListener(notifyListeners);
    for (final item in _controllers) {
      item.addListener(notifyListeners);
    }
  }

  final SaveSubUsuarioController _saveController;
  final GetFazendasUsecase _getFazendasUsecase;
  final GetUsuarioPermissoesUsecase _getPermissoesUsecase;

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController celularController = TextEditingController();
  final MaskTextInputFormatter phoneMaskFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'\d')},
  );

  SubUsuarioEntity? _current;
  List<FazendaEntity> fazendas = const [];
  List<UsuarioPermissaoEntity> permissoes = const [];
  final Set<int> selectedFarmIds = {};
  final Set<int> selectedPermissionIds = {};
  bool isLoadingLookups = false;
  String? lookupError;

  List<TextEditingController> get _controllers => [
    nomeController,
    emailController,
    celularController,
  ];

  bool get isLoading => _saveController.isLoading || isLoadingLookups;
  bool get isEditing => _current != null;
  String? get errorMessage => _saveController.errorMessage ?? lookupError;

  bool get isDadosComplete {
    return nomeController.text.trim().isNotEmpty &&
        emailController.text.trim().isNotEmpty &&
        celularController.text.trim().isNotEmpty;
  }

  bool get isFazendasComplete => selectedFarmIds.isNotEmpty;

  bool get isPermissoesComplete => selectedPermissionIds.isNotEmpty;

  bool get isAllPermissionsSelected =>
      permissoes.isNotEmpty &&
      selectedPermissionIds.length == permissoes.length;

  bool get isFormValid {
    return isDadosComplete && isFazendasComplete && isPermissoesComplete;
  }

  Future<void> init({SubUsuarioEntity? usuario}) async {
    _current = usuario;
    if (usuario != null) {
      nomeController.text = usuario.nome;
      emailController.text = usuario.email;
      celularController.text = phoneMaskFormatter.maskText(usuario.celular);
      selectedFarmIds.addAll(usuario.farmIds);
      selectedPermissionIds.addAll(usuario.permissionIds);
    }
    await _loadLookups();
  }

  Future<void> _loadLookups() async {
    isLoadingLookups = true;
    lookupError = null;
    notifyListeners();

    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuario nao autenticado.');
      }
      final farms = await _getFazendasUsecase(
        FazendaFilterEntity(appUsersId: user.id),
      );
      fazendas = farms.data;
      permissoes = await _getPermissoesUsecase();
    } catch (_) {
      lookupError = 'Nao foi possivel carregar fazendas e permissoes.';
    } finally {
      isLoadingLookups = false;
      notifyListeners();
    }
  }

  void toggleFarm(int id) {
    if (selectedFarmIds.contains(id)) {
      selectedFarmIds.remove(id);
    } else {
      selectedFarmIds.add(id);
    }
    notifyListeners();
  }

  void togglePermission(int id) {
    if (selectedPermissionIds.contains(id)) {
      selectedPermissionIds.remove(id);
    } else {
      selectedPermissionIds.add(id);
    }
    notifyListeners();
  }

  void toggleAllPermissions() {
    if (isAllPermissionsSelected) {
      selectedPermissionIds.clear();
    } else {
      selectedPermissionIds
        ..clear()
        ..addAll(permissoes.map((item) => item.id));
    }
    notifyListeners();
  }

  Future<PageActionResult> submit() async {
    if (!isFormValid) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Preencha os campos obrigatorios.',
      );
    }

    final user = await SessionStorage.getUserSession();
    if (user == null) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Usuario nao autenticado.',
      );
    }

    try {
      final result = await _saveController.save(
        SubUsuarioUpsertEntity(
          id: _current?.id,
          ownerUserId: user.id,
          nome: nomeController.text.trim(),
          email: emailController.text.trim(),
          celular: celularController.text.trim(),
          farmIds: selectedFarmIds.toList(),
          permissionIds: selectedPermissionIds.toList(),
        ),
      );
      return PageActionResult(isSuccess: true, message: result.message);
    } catch (_) {
      return PageActionResult(
        isSuccess: false,
        message: errorMessage ?? 'Nao foi possivel salvar o usuario.',
      );
    }
  }

  @override
  void dispose() {
    for (final item in _controllers) {
      item.removeListener(notifyListeners);
      item.dispose();
    }
    _saveController.removeListener(notifyListeners);
    super.dispose();
  }
}
