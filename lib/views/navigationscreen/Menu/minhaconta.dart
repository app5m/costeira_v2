import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/account/repositories/account_repository.dart';
import 'package:costeira/features/auth/models/user_session.dart';
import 'package:costeira/views/navigationscreen/Menu/meusdados.dart';
import 'package:costeira/views/navigationscreen/Menu/updatepassword.dart';
import 'package:costeira/views/navigationscreen/notification/notification.dart';
import 'package:costeira/views/shared/widgets/primary_app_bar.dart';
import 'package:costeira/views/shared/widgets/settings_option_tile.dart';
import 'package:costeira/views/teladeinicio/teladeinicio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Minhaconta extends StatefulWidget {
  const Minhaconta({super.key});

  @override
  State<Minhaconta> createState() => _MinhacontaState();
}

class _MinhacontaState extends State<Minhaconta> {
  final AccountRepository _accountRepository = AccountRepository();
  UserSession? _user;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await SessionStorage.getUserSession();
    if (!mounted) {
      return;
    }
    setState(() {
      _user = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PrimarySectionAppBar(context: context, title: 'Minha conta'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: const Color(0xFFEBEBEB),
                child: SvgPicture.asset(
                  'icon/user-round.svg',
                  width: 36,
                  height: 36,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _user?.name.isNotEmpty == true ? _user!.name : 'Usuário',
                style: const TextStyle(
                  color: Color(0xFF313131),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _user?.email ?? 'Sem e-mail',
                style: const TextStyle(
                  color: Color(0xFF8C8C8C),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SettingsOptionTile(
            title: 'Editar dados',
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const MeusDados()));
            },
          ),
          const SizedBox(height: 16),
          SettingsOptionTile(
            title: 'Notificações',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificacoesScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          SettingsOptionTile(
            title: 'Alterar senha',
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const UpdatePassword()));
            },
          ),
          const SizedBox(height: 16),
          SettingsOptionTile(
            title: 'Desativar conta',
            textColor: Colors.red,
            onTap: () => _showConfirmationDialog(
              context: context,
              title: 'Desativar conta?',
              description: 'Tem certeza que deseja desativar sua conta?',
              actionLabel: 'Desativar',
              actionColor: Colors.red,
              onConfirm: _deactivateAccount,
            ),
          ),
          const SizedBox(height: 16),
          SettingsOptionTile(
            title: 'Sair',
            textColor: Colors.red,
            onTap: () => _showConfirmationDialog(
              context: context,
              title: 'Sair do aplicativo?',
              description: 'Tem certeza que deseja sair da sua conta?',
              actionLabel: 'Sair',
              actionColor: Colors.red,
              onConfirm: _logout,
            ),
          ),
          if (_isLoading) ...[
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }

  Future<void> _deactivateAccount() async {
    if (_user == null) {
      _showMessage('Usuário não autenticado.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _accountRepository.deactivateAccount(_user!.id);
      _showMessage(response.message);
      if (response.isSuccess) {
        await SessionStorage.clearUserSession();
        if (!mounted) {
          return;
        }
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const Teladeinicio()),
          (route) => false,
        );
      }
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

  Future<void> _logout() async {
    await SessionStorage.clearUserSession();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const Teladeinicio()),
      (route) => false,
    );
  }

  Future<void> _showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String description,
    required String actionLabel,
    required Color actionColor,
    required Future<void> Function() onConfirm,
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(title),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await onConfirm();
              },
              child: Text(actionLabel, style: TextStyle(color: actionColor)),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
