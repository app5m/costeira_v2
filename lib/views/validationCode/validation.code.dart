import 'package:costeira/theme/colors.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/user_coordinates.dart';
import 'package:costeira/core/services/push_token_service.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/auth/repositories/auth_repository.dart';
import 'package:costeira/views/login/pendingapproval/pending_approval.dart';
import 'package:costeira/views/navigationscreen/navigationscreen.dart';
import 'package:costeira/views/shared/widgets/app_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';

class ValidationCode extends StatefulWidget {
  const ValidationCode({
    super.key,
    required this.email,
    required this.password,
    required this.lat,
    required this.long,
    required this.tipo,
  });

  final String email;
  final String password;
  final String lat;
  final String long;
  final int tipo;

  @override
  State<ValidationCode> createState() => _ValidationCodeState();
}

class _ValidationCodeState extends State<ValidationCode> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  final AuthRepository _authRepository = AuthRepository();
  final PushTokenService _pushTokenService = PushTokenService.instance;
  bool _isLoading = false;

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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('images/costeira_tela.png', fit: BoxFit.cover),
          ),
          SafeArea(
            top: false,
            bottom: false,
            child: SingleChildScrollView(
              reverse: true,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: screenHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: double.infinity,
                        constraints: BoxConstraints(
                          maxHeight: screenHeight * 0.93,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          onChanged: () => setState(() {}),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 32),
                                  IconButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    icon: const Icon(
                                      Icons.arrow_back_ios,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Autenticação',
                                    style: TextStyle(
                                      color: Color(0xFF313131),
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Digite o código enviado para o seu e-mail\n${widget.email}',
                                    style: const TextStyle(
                                      color: Color(0xFF8691A8),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  const SizedBox(height: 32),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Directionality(
                                        textDirection: TextDirection.ltr,
                                        child: Pinput(
                                          controller: _pinController,
                                          focusNode: _focusNode,
                                          length: 4,
                                          defaultPinTheme: defaultPinTheme,
                                          separatorBuilder: (_) =>
                                              const SizedBox(width: 8),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          validator: (value) {
                                            if ((value ?? '').length != 4) {
                                              return 'Informe o código completo';
                                            }
                                            return null;
                                          },
                                          hapticFeedbackType:
                                              HapticFeedbackType.lightImpact,
                                          focusedPinTheme: defaultPinTheme
                                              .copyWith(
                                                decoration: defaultPinTheme
                                                    .decoration!
                                                    .copyWith(
                                                      border: Border.all(
                                                        color: MyColors
                                                            .colorPrimary,
                                                      ),
                                                    ),
                                              ),
                                          submittedPinTheme: defaultPinTheme
                                              .copyWith(
                                                decoration: defaultPinTheme
                                                    .decoration!
                                                    .copyWith(
                                                      border: Border.all(
                                                        color: const Color(
                                                          0xFFD9D9D9,
                                                        ),
                                                      ),
                                                    ),
                                              ),
                                        ),
                                      ),
                                    ],
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
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 24,
                                  bottom: 32,
                                ),
                                child: PrimaryButton(
                                  label: 'Avançar',
                                  isLoading: _isLoading,
                                  onPressed: _canSubmit ? _submit : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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

      _showMessage(result.message.message);

      if (!mounted) {
        return;
      }

      if (result.message.status == '02') {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => PendingApprovalPage(
              message: result.message.message,
              email: widget.email,
            ),
          ),
          (route) => false,
        );
        return;
      }

      if (!result.message.isSuccess || result.user == null) {
        return;
      }

      await SessionStorage.saveUserSession(result.user!);
      await _saveFcmIfAvailable(result.user!.id);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const NavigationScreen()),
        (route) => false,
      );
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
      _showMessage(response.message);
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

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool get _canSubmit => _pinController.text.trim().length == 4;
}
