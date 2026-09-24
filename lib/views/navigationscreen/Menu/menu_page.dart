import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/common/get_list/domain/entities/app_menu_entity.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/settings_option_tile.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/menus/app_menus_controller.dart';
import 'package:costeira/core/menus/menu_action_resolver.dart';
import 'package:costeira/core/menus/menu_icon.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/account/models/account_profile.dart';
import 'package:costeira/features/account/repositories/account_repository.dart';
import 'package:costeira/features/auth/models/user_session.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late final AccountRepository _accountRepository;
  late final AppMenusController _menusController;
  UserSession? _user;
  AccountProfile? _profile;
  bool _isLoadingProfile = true;
  bool _isDeactivating = false;

  @override
  void initState() {
    super.initState();
    _accountRepository = Modular.get<AccountRepository>();
    _menusController = Modular.get<AppMenusController>();
    _menusController.addListener(_onMenus);
    _menusController.load();
    _loadProfile();
  }

  void _onMenus() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _menusController.removeListener(_onMenus);
    super.dispose();
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
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                children: [
                  const _SectionTitle('Dados'),
                  SettingsOptionTile(
                    title: 'Alterar dados cadastrais',
                    leading: _localIcon(
                      'icon/user-round.svg',
                      color: Colors.black,
                    ),
                    onTap: () => Modular.to.pushNamed(AppRoutes.profile),
                  ),
                  const SizedBox(height: 12),
                  SettingsOptionTile(
                    title: 'Alterar Senha',
                    leading: const Icon(
                      LucideIcons.lock,
                      size: 22,
                      color: Color(0xFF313131),
                    ),
                    onTap: () => Modular.to.pushNamed(AppRoutes.updatePassword),
                  ),
                  const SizedBox(height: 12),
                  SettingsOptionTile(
                    title: 'Desativar Conta',
                    textColor: Colors.red,
                    leading: _localIcon('icon/trash.svg', color: Colors.red),
                    onTap: _confirmDeactivateAccount,
                  ),
                  ..._buildApiOrFallbackSections(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: OutlinedButton(
                onPressed: _isDeactivating ? null : _showExitBottomSheet,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: const BorderSide(color: Color(0xFFFF3B30)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
          _profile?.email.isNotEmpty == true
              ? _profile!.email
              : _user?.email ?? '',
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
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
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

  List<Widget> _buildApiOrFallbackSections() {
    final groups = _menusController.profileMenu;
    if (groups.isEmpty) {
      return [
        const SizedBox(height: 24),
        const _SectionTitle('Módulos'),
        SettingsOptionTile(
          title: 'Potreiros',
          onTap: () => Modular.to.pushNamed(AppRoutes.potreirosHub),
        ),
        const SizedBox(height: 12),
        SettingsOptionTile(
          title: 'Estoque',
          onTap: () => Modular.to.pushNamed(AppRoutes.estoque),
        ),
        const SizedBox(height: 12),
        SettingsOptionTile(
          title: 'Tarefas',
          onTap: () => Modular.to.pushNamed(AppRoutes.tasks),
        ),
        const SizedBox(height: 12),
        SettingsOptionTile(
          title: 'Pluviosidade',
          onTap: () => Modular.to.pushNamed(AppRoutes.climateRain),
        ),
        const SizedBox(height: 24),
        const _SectionTitle('Cadastros'),
        SettingsOptionTile(
          title: 'Fornecedores',
          onTap: () => Modular.to.pushNamed(AppRoutes.fornecedores),
        ),
        const SizedBox(height: 12),
        SettingsOptionTile(
          title: 'Compradores',
          onTap: () => Modular.to.pushNamed(AppRoutes.compradores),
        ),
        const SizedBox(height: 12),
        SettingsOptionTile(
          title: 'Usuários e Acessos',
          onTap: () => Modular.to.pushNamed(AppRoutes.usuarios),
        ),
      ];
    }

    final widgets = <Widget>[];
    for (final group in groups) {
      final children = group.children;
      if (children.isEmpty) {
        continue;
      }
      widgets.add(const SizedBox(height: 24));
      widgets.add(_SectionTitle(group.name));
      for (var i = 0; i < children.length; i++) {
        if (i > 0) {
          widgets.add(const SizedBox(height: 12));
        }
        widgets.add(_buildMenuTile(children[i]));
      }
    }
    return widgets;
  }

  Widget _localIcon(String asset, {Color color = const Color(0xFF313131)}) {
    return SvgPicture.asset(
      asset,
      width: 22,
      height: 22,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  Widget? _menuLeading(AppMenuEntity item) {
    return MenuIcon.maybe(item: item, size: 22, color: const Color(0xFF313131));
  }

  Widget _buildMenuTile(AppMenuEntity item) {
    return SettingsOptionTile(
      title: item.name,
      leading: _menuLeading(item),
      onTap: () => _openProfileItem(item),
    );
  }

  Future<void> _openProfileItem(AppMenuEntity item) async {
    if (item.children.isNotEmpty) {
      await _showProfileChildren(item);
      return;
    }
    await MenuActionResolver.open(context, item, surface: MenuSurface.profile);
  }

  Future<void> _showProfileChildren(AppMenuEntity parent) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 72,
                    height: 3,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E2E2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  parent.name,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF313131),
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(sheetContext).size.height * 0.55,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: parent.children.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final child = parent.children[index];
                      return SettingsOptionTile(
                        title: child.name,
                        leading: _menuLeading(child),
                        onTap: () async {
                          Navigator.pop(sheetContext);
                          await _openProfileItem(child);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDeactivateAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Desativar conta?'),
          content: const Text('Tem certeza que deseja desativar sua conta?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'Desativar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deactivateAccount();
    }
  }

  Future<void> _deactivateAccount() async {
    if (_user == null) {
      _showMessage('Usuário não autenticado.');
      return;
    }

    setState(() {
      _isDeactivating = true;
    });

    try {
      final response = await _accountRepository.deactivateAccount(_user!.id);
      _showMessage(response.message, isError: !response.isSuccess);
      if (response.isSuccess) {
        await SessionStorage.clearAuthData();
        if (!mounted) {
          return;
        }
        Modular.to.navigate(AppRoutes.welcome);
      }
    } on ApiException catch (error) {
      _showMessage(error.message);
    } finally {
      if (mounted) {
        setState(() {
          _isDeactivating = false;
        });
      }
    }
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
        return SafeArea(
          top: false,
          child: Padding(
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
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await SessionStorage.clearAuthData();
                      if (!mounted) {
                        return;
                      }
                      Modular.to.navigate(AppRoutes.welcome);
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text(
                      'Sair',
                      style: TextStyle(color: Colors.black),
                    ),
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
          ),
        );
      },
    );
  }

  void _showMessage(String message, {bool isError = true}) {
    if (!mounted) {
      return;
    }
    AppSnackBar.show(context: context, message: message, isError: isError);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF313131),
          fontSize: 16,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

typedef Menu = MenuPage;
