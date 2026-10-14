import 'package:costeira/app/app_route_data.dart';
import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/components/app_buttons.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/models/user_coordinates.dart';
import 'package:costeira/core/services/push_token_service.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/auth/auth_bypass.dart';
import 'package:costeira/features/auth/models/user_session.dart';
import 'package:costeira/features/auth/presentation/web/auth_web_frame.dart';
import 'package:costeira/features/auth/repositories/auth_repository.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:pinput/pinput.dart';

class ValidationCodeWebPage extends StatefulWidget {
  const ValidationCodeWebPage({
    super.key,
    required this.email,
    required this.password,
    required this.lat,
    required this.long,
    required this.tipo,
    this.pendingUser,
  });

  final String email;
  final String password;
  final String lat;
  final String long;
  final int tipo;
  final UserSession? pendingUser;

  @override
  State<ValidationCodeWebPage> createState() => _ValidationCodeWebPageState();
}

class _ValidationCodeWebPageState extends State<ValidationCodeWebPage> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  late final AuthRepository _authRepository;
  late final PushTokenService _pushTokenService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _authRepository = Modular.get<AuthRepository>();
    _pushTokenService = Modular.get<PushTokenService>();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Color(0xFF313131),
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD9D9D9)),
        color: Colors.white,
      ),
    );

    return AuthWebFrame(
      title: 'Autenticação',
      subtitle: 'Digite o código enviado para o seu e-mail\n${widget.email}',
      fallbackRoute: AppRoutes.login,
      body: Form(
        key: _formKey,
        onChanged: () => setState(() {}),
        child: Column(
          children: [
            Pinput(
              controller: _pinController,
              focusNode: _focusNode,
              length: 4,
              defaultPinTheme: defaultPinTheme,
              separatorBuilder: (_) => const SizedBox(width: 8),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if ((value ?? '').length != 4) {
                  return 'Informe o código completo';
                }
                return null;
              },
              focusedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  border: Border.all(color: MyColors.colorPrimary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Não recebeu o código?',
              style: TextStyle(
                color: Color(0xFF8A8A8A),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: _isLoading ? null : _resendCode,
              child: Text(
                'Reenviar código',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: MyColors.colorPrimary,
                  decoration: TextDecoration.underline,
                  decorationColor: MyColors.colorPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
      footer: PrimaryButton(
        label: 'Avançar',
        isLoading: _isLoading,
        onPressed: _canSubmit ? _submit : null,
      ),
    );
  }

  bool get _canSubmit => _pinController.text.trim().length == 4;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authRepository.login(
        email: widget.email,
        password: widget.password,
        code: _pinController.text.trim(),
        tipo: widget.tipo,
      );

      if (!mounted) {
        return;
      }

      if (result.message.status == '02' &&
          AuthBypass.isPendingApprovalMessage(result.message.message)) {
        await SessionStorage.saveWebPendingApproval(
          message: result.message.message,
          email: widget.email,
        );
        if (!mounted) {
          return;
        }
        Modular.to.navigate(
          AppRoutes.pendingApproval,
          arguments: PendingApprovalRouteData(
            message: result.message.message,
            email: widget.email,
          ),
        );
        return;
      }

      _showMessage(
        result.message.message,
        isError:
            !result.message.isSuccess &&
            !AuthBypass.shouldBypass(
              result.message.status,
              result.message.message,
            ),
      );

      var user = result.user;
      if (user == null || user.id <= 0) {
        final existing = await SessionStorage.getUserSession();
        if (existing != null && existing.id > 0) {
          user = existing;
        }
      }
      if (user == null || user.id <= 0) {
        final pending =
            widget.pendingUser ??
            await SessionStorage.getPendingUser(email: widget.email);
        if (pending != null && pending.id > 0) {
          user = pending;
        }
      }

      if ((!result.message.isSuccess &&
              !AuthBypass.shouldBypass(
                result.message.status,
                result.message.message,
              )) ||
          user == null ||
          user.id <= 0) {
        if (result.message.isSuccess ||
            AuthBypass.shouldBypass(
              result.message.status,
              result.message.message,
            )) {
          _showMessage(
            'Login não retornou app_users_id. Entre com uma conta aprovada.',
          );
        }
        return;
      }

      await SessionStorage.saveUserSession(user);
      await SessionStorage.clearWebPendingApproval();
      await _saveFcmIfAvailable(user.id);

      if (!mounted) {
        return;
      }

      Modular.to.navigate(AppRoutes.appShell);
    } on ApiException catch (error) {
      _showMessage(error.message);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendCode() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _authRepository.sendTwoFactor(
        email: widget.email,
        password: widget.password,
        coordinates: UserCoordinates(
          latitude: widget.lat,
          longitude: widget.long,
        ),
      );
      _showMessage(response.message, isError: !response.isSuccess);
    } on ApiException catch (error) {
      _showMessage(error.message);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveFcmIfAvailable(int userId) async {
    final pushToken = await _pushTokenService.getDeviceToken();
    final platformType = _pushTokenService.platformType;
    if (pushToken == null || pushToken.isEmpty || platformType == 0) {
      return;
    }

    try {
      await _authRepository.saveFcm(
        userId: userId,
        type: platformType,
        registrationId: pushToken,
      );
    } on ApiException {
      // O login não deve falhar por causa do FCM.
    }
  }

  void _showMessage(String message, {bool isError = true}) {
    if (!mounted) {
      return;
    }
    AppSnackBar.show(context: context, message: message, isError: isError);
  }
}
