import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/account/models/account_profile.dart';
import 'package:costeira/features/account/repositories/account_repository.dart';
import 'package:costeira/features/auth/models/user_session.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/svg.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late final AccountRepository _accountRepository;
  UserSession? _user;
  AccountProfile? _profile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _accountRepository = Modular.get<AccountRepository>();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = await SessionStorage.getUserSession();
    if (!mounted) {
      return;
    }

    setState(() {
      _user = user;
      _isLoadingProfile = true;
    });

    if (user == null) {
      setState(() {
        _isLoadingProfile = false;
      });
      return;
    }

    try {
      final profile = await _accountRepository.fetchProfile(userId: user.id);
      if (!mounted) {
        return;
      }

      setState(() {
        _profile = profile;
        _isLoadingProfile = false;
      });
    } on ApiException {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  String? get _avatarUrl {
    final avatar = _profile?.avatar.trim() ?? '';
    if (avatar.isEmpty) {
      return null;
    }
    if (avatar.startsWith('http://') || avatar.startsWith('https://')) {
      return avatar;
    }
    if (avatar.startsWith('/')) {
      return '${Uri.parse(WSConstantes.urlBase).origin}$avatar';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildProfileHeader(),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _MenuCard(
                    icon: 'icon/minhaconta.svg',
                    title: 'Minha conta',
                    onTap: () => Modular.to.pushNamed(AppRoutes.myAccount),
                  ),
                  const SizedBox(height: 16),
                  _MenuCard(
                    icon: 'icon/modulos.svg',
                    title: 'Módulos',
                    onTap: () => Modular.to.pushNamed(AppRoutes.modules),
                  ),
                  const SizedBox(height: 16),
                  _MenuCard(
                    icon: 'icon/extras.svg',
                    title: 'Extras',
                    onTap: () => Modular.to.pushNamed(AppRoutes.extras),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: OutlinedButton(
                onPressed: _showExitBottomSheet,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: const BorderSide(color: Color(0xFFFF3B30)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Sair',
                  style: TextStyle(
                    color: Color(0xFFFF3B30),
                    fontSize: 12,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0xFFE6E6E6)),
              borderRadius: BorderRadius.circular(258),
            ),
          ),
          child: _buildProfileAvatar(),
        ),
        const SizedBox(height: 8),
        Text(
          _profile?.name.isNotEmpty == true
              ? _profile!.name
              : _user?.name.isNotEmpty == true
              ? _user!.name
              : 'Usuário',
          style: const TextStyle(
            color: Color(0xFF313131),
            fontSize: 24,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          _profile?.email.isNotEmpty == true ? _profile!.email : _user?.email ?? '',
          style: const TextStyle(
            color: Color(0xFF8C8C8C),
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileAvatar() {
    if (_isLoadingProfile) {
      return const Center(
        child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_avatarUrl != null) {
      return Image.network(
        _avatarUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildAvatarFallback(),
      );
    }

    return _buildAvatarFallback();
  }

  Widget _buildAvatarFallback() {
    return Container(
      color: const Color(0xFFEBEBEB),
      alignment: Alignment.center,
      child: const Icon(Icons.person, color: Colors.grey, size: 36),
    );
  }

  void _showExitBottomSheet() {
    showModalBottomSheet<void>(
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sair do aplicativo?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tem certeza que deseja sair da sua conta?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF8692A8)),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Modular.to.navigate(AppRoutes.welcome);
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text('Sair', style: TextStyle(color: Colors.black)),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    color: MyColors.colorOnPrimary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.icon, required this.title, required this.onTap});

  final String icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFEBEBEB)),
            borderRadius: BorderRadius.circular(12),
          ),
          shadows: const [
            BoxShadow(color: Color(0x0A000000), blurRadius: 24, offset: Offset(0, 0)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  icon,
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(Color(0xFF00823A), BlendMode.srcIn),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF313131),
                    fontSize: 14,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.10,
                  ),
                ),
              ],
            ),
            SvgPicture.asset('icon/Arrow.svg', width: 24, height: 24),
          ],
        ),
      ),
    );
  }
}

typedef Menu = MenuPage;
