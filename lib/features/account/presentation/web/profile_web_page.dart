import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/common/get_list/domain/entities/app_menu_entity.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/web_module_development_dialog.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/menus/app_menus_controller.dart';
import 'package:costeira/core/menus/menu_icon.dart';
import 'package:costeira/core/menus/menu_slug.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/account/models/account_profile.dart';
import 'package:costeira/features/account/presentation/web/profile_web_data_panel.dart';
import 'package:costeira/features/account/presentation/web/profile_web_password_panel.dart';
import 'package:costeira/features/account/repositories/account_repository.dart';
import 'package:costeira/features/auth/models/user_session.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_kind.dart';
import 'package:costeira/features/cadastros/presentation/web/parceiros_list_web_dialog.dart';
import 'package:costeira/features/usuarios/presentation/web/sub_usuarios_list_web_dialog.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProfileWebPage extends StatefulWidget {
  const ProfileWebPage({super.key});

  @override
  State<ProfileWebPage> createState() => _ProfileWebPageState();
}

class _ProfileWebPageState extends State<ProfileWebPage> {
  static const _summary = 'summary';
  static const _data = 'data';
  static const _password = 'password';
  static const _sideBySideMinWidth = 893.0;
  static const _railWidth = 252.0;

  late final AccountRepository _repository;
  late final AppMenusController _menus;
  UserSession? _user;
  AccountProfile? _profile;
  String _selected = _summary;
  bool _loadingProfile = true;
  bool _processingAccount = false;

  @override
  void initState() {
    super.initState();
    _repository = Modular.get<AccountRepository>();
    _menus = Modular.get<AppMenusController>();
    _menus.addListener(_onMenusChanged);
    _menus.load();
    _loadProfile();
  }

  @override
  void dispose() {
    _menus.removeListener(_onMenusChanged);
    super.dispose();
  }

  void _onMenusChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadProfile() async {
    final user = await SessionStorage.getUserSession();
    if (!mounted) return;
    setState(() {
      _user = user;
      _loadingProfile = true;
    });
    if (user == null) {
      setState(() => _loadingProfile = false);
      return;
    }
    try {
      final profile = await _repository.fetchProfile(userId: user.id);
      final updatedUser = UserSession(
        id: profile.id > 0 ? profile.id : user.id,
        name: profile.name,
        email: profile.email,
        phone: profile.phone,
        document: profile.cpf.isNotEmpty ? profile.cpf : profile.cnpj,
        nickname: user.nickname,
        tipo: profile.tipoPessoa.toString(),
        appSubUsersId: user.appSubUsersId,
        ownerUserId: user.ownerUserId,
      );
      await SessionStorage.saveUserSession(updatedUser);
      if (!mounted) return;
      setState(() {
        _user = updatedUser;
        _profile = profile;
        _loadingProfile = false;
      });
    } on ApiException {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  String get _name {
    final profileName = _profile?.name.trim() ?? '';
    if (profileName.isNotEmpty) return profileName;
    final sessionName = _user?.name.trim() ?? '';
    return sessionName.isEmpty ? 'Usuário' : sessionName;
  }

  String get _email {
    final profileEmail = _profile?.email.trim() ?? '';
    return profileEmail.isNotEmpty ? profileEmail : _user?.email.trim() ?? '';
  }

  String? get _avatarUrl {
    final avatar = _profile?.avatar.trim() ?? '';
    if (avatar.isEmpty) return null;
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
    return ColoredBox(
      color: Colors.white,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final sideBySide = constraints.maxWidth >= _sideBySideMinWidth;
          if (sideBySide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: _railWidth, child: _buildRail()),
                const VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: Color(0xFFE7E4DD),
                ),
                Expanded(child: _buildPanelScroller()),
              ],
            );
          }
          return _buildCompactLayout();
        },
      ),
    );
  }

  Widget _buildRail() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
          child: _UserSummary(
            name: _name,
            email: _email,
            avatarUrl: _avatarUrl,
            loading: _loadingProfile,
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE7E4DD)),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 18),
            children: [
              const _MenuSectionLabel('Dados'),
              const SizedBox(height: 6),
              _fixedTile(
                id: _summary,
                label: 'Resumo',
                icon: LucideIcons.userCircle2,
              ),
              _fixedTile(
                id: _data,
                label: 'Alterar dados cadastrais',
                icon: LucideIcons.user,
              ),
              _fixedTile(
                id: _password,
                label: 'Alterar senha',
                icon: LucideIcons.lock,
              ),
              _ProfileMenuTile(
                label: 'Desativar conta',
                icon: const Icon(
                  LucideIcons.trash2,
                  size: 19,
                  color: Color(0xFFC4473A),
                ),
                danger: true,
                onTap: _processingAccount ? null : _confirmDeactivate,
              ),
              ..._dynamicGroups(compact: false),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE7E4DD)),
        Padding(
          padding: const EdgeInsets.all(12),
          child: _ProfileMenuTile(
            label: 'Sair',
            icon: const Icon(
              LucideIcons.logOut,
              size: 19,
              color: Color(0xFFC4473A),
            ),
            danger: true,
            onTap: _processingAccount ? null : _confirmLogout,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactLayout() {
    return Scrollbar(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _CompactNavigation(
            selectedLabel: _selectedLabel,
            userSummary: _UserSummary(
              name: _name,
              email: _email,
              avatarUrl: _avatarUrl,
              loading: _loadingProfile,
            ),
            fixedItems: [
              _fixedTile(
                id: _summary,
                label: 'Resumo',
                icon: LucideIcons.userCircle2,
              ),
              _fixedTile(
                id: _data,
                label: 'Alterar dados cadastrais',
                icon: LucideIcons.user,
              ),
              _fixedTile(
                id: _password,
                label: 'Alterar senha',
                icon: LucideIcons.lock,
              ),
              _ProfileMenuTile(
                label: 'Desativar conta',
                icon: const Icon(
                  LucideIcons.trash2,
                  size: 19,
                  color: Color(0xFFC4473A),
                ),
                danger: true,
                onTap: _processingAccount ? null : _confirmDeactivate,
              ),
            ],
            dynamicGroups: _dynamicGroups(compact: true),
            onLogout: _processingAccount ? null : _confirmLogout,
          ),
          const SizedBox(height: 28),
          Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 830),
              child: _panelContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelScroller() {
    return Scrollbar(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 40),
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 830),
            child: _panelContent(),
          ),
        ),
      ),
    );
  }

  Widget _panelContent() {
    return switch (_selected) {
      _data => ProfileWebDataPanel(
        session: _user,
        profile: _profile,
        onReloadProfile: _loadProfile,
      ),
      _password => const ProfileWebPasswordPanel(),
      _ => _SummaryPanel(
        name: _name,
        email: _email,
        phone: _profile?.phone ?? _user?.phone ?? '',
        document: _profile?.cpf.isNotEmpty == true
            ? _profile!.cpf
            : _user?.document ?? '',
        avatarUrl: _avatarUrl,
        loading: _loadingProfile,
        onEdit: () => _select(_data),
      ),
    };
  }

  Widget _fixedTile({
    required String id,
    required String label,
    required IconData icon,
  }) {
    final selected = _selected == id;
    final color = selected ? MyColors.colorPrimary : const Color(0xFF5E6E64);
    return _ProfileMenuTile(
      label: label,
      selected: selected,
      icon: Icon(icon, size: 19, color: color),
      onTap: () => _select(id),
    );
  }

  List<Widget> _dynamicGroups({required bool compact}) {
    final widgets = <Widget>[];
    for (final group in _menus.profileMenu) {
      if (group.children.isEmpty) continue;
      widgets.add(SizedBox(height: compact ? 12 : 20));
      widgets.add(_MenuSectionLabel(group.name));
      widgets.add(const SizedBox(height: 6));
      widgets.addAll(_menuChildren(group.children, depth: 0));
    }
    if (_menus.profileMenu.isEmpty && _menus.loaded) {
      widgets.add(const SizedBox(height: 18));
      widgets.add(
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Nenhum módulo disponível.',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              color: Color(0xFF8C8C8C),
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  List<Widget> _menuChildren(List<AppMenuEntity> items, {required int depth}) {
    final widgets = <Widget>[];
    for (final item in items) {
      if (item.children.isNotEmpty) {
        widgets.add(
          Padding(
            padding: EdgeInsets.fromLTRB(12.0 + depth * 12, 10, 8, 5),
            child: Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF777777),
              ),
            ),
          ),
        );
        widgets.addAll(_menuChildren(item.children, depth: depth + 1));
        continue;
      }
      widgets.add(
        Padding(
          padding: EdgeInsets.only(left: depth * 12.0),
          child: _ProfileMenuTile(
            label: item.name,
            icon: MenuIcon.maybe(
              item: item,
              size: 19,
              color: const Color(0xFF5E6E64),
            ),
            onTap: () => _openModule(item),
          ),
        ),
      );
    }
    return widgets;
  }

  String get _selectedLabel => switch (_selected) {
    _data => 'Alterar dados cadastrais',
    _password => 'Alterar senha',
    _ => 'Resumo',
  };

  void _select(String value) {
    if (_selected == value) return;
    setState(() => _selected = value);
  }

  Future<void> _openModule(AppMenuEntity item) async {
    final slug = MenuSlug.resolve(action: item.action, name: item.name);
    final Widget? availableDialog = switch (slug) {
      MenuSlug.fornecedores => const ParceirosListWebDialog(
        kind: ParceiroKind.fornecedor,
      ),
      MenuSlug.compradores => const ParceirosListWebDialog(
        kind: ParceiroKind.comprador,
      ),
      MenuSlug.usuarios => const SubUsuariosListWebDialog(),
      _ => null,
    };
    await showDialog<void>(
      context: context,
      barrierDismissible: availableDialog == null,
      builder: (_) =>
          availableDialog ?? WebModuleDevelopmentDialog(moduleName: item.name),
    );
  }

  Future<void> _confirmDeactivate() async {
    final confirmed = await _confirmation(
      title: 'Desativar conta?',
      message: 'Tem certeza que deseja desativar sua conta?',
      confirmLabel: 'Desativar',
    );
    if (confirmed != true || !mounted) return;
    final user = _user;
    if (user == null) {
      _message('Usuário não autenticado.');
      return;
    }
    setState(() => _processingAccount = true);
    try {
      final response = await _repository.deactivateAccount(user.id);
      _message(response.message, isError: !response.isSuccess);
      if (response.isSuccess) await _leaveAccount();
    } on ApiException catch (error) {
      _message(error.message);
    } finally {
      if (mounted) setState(() => _processingAccount = false);
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await _confirmation(
      title: 'Sair do aplicativo?',
      message: 'Tem certeza que deseja sair da sua conta?',
      confirmLabel: 'Sair',
    );
    if (confirmed == true) await _leaveAccount();
  }

  Future<bool?> _confirmation({
    required String title,
    required String message,
    required String confirmLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Montserrat'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              confirmLabel,
              style: const TextStyle(color: Color(0xFFC4473A)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _leaveAccount() async {
    await SessionStorage.clearAuthData();
    if (!mounted) return;
    Modular.to.navigate(AppRoutes.welcome);
  }

  void _message(String message, {bool isError = true}) {
    if (!mounted) return;
    AppSnackBar.show(context: context, message: message, isError: isError);
  }
}

class _CompactNavigation extends StatelessWidget {
  const _CompactNavigation({
    required this.selectedLabel,
    required this.userSummary,
    required this.fixedItems,
    required this.dynamicGroups,
    required this.onLogout,
  });

  final String selectedLabel;
  final Widget userSummary;
  final List<Widget> fixedItems;
  final List<Widget> dynamicGroups;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE7E4DD)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          leading: const Icon(
            LucideIcons.settings2,
            size: 20,
            color: MyColors.colorPrimary,
          ),
          title: const Text(
            'Navegação do perfil',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              color: Color(0xFF777777),
            ),
          ),
          subtitle: Text(
            selectedLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF313131),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 14),
              child: userSummary,
            ),
            const Divider(height: 1, color: Color(0xFFE7E4DD)),
            const SizedBox(height: 8),
            ...fixedItems,
            ...dynamicGroups,
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFE7E4DD)),
            const SizedBox(height: 8),
            _ProfileMenuTile(
              label: 'Sair',
              icon: const Icon(
                LucideIcons.logOut,
                size: 19,
                color: Color(0xFFC4473A),
              ),
              danger: true,
              onTap: onLogout,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.label,
    required this.icon,
    required this.onTap,
    this.selected = false,
    this.danger = false,
  });

  final String label;
  final Widget? icon;
  final VoidCallback? onTap;
  final bool selected;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger
        ? const Color(0xFFC4473A)
        : selected
        ? MyColors.colorPrimary
        : const Color(0xFF4F5652);
    return Material(
      color: selected ? const Color(0x1400823A) : Colors.transparent,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
          child: Row(
            children: [
              SizedBox(width: 22, height: 22, child: Center(child: icon)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              if (selected)
                Container(
                  width: 3,
                  height: 18,
                  decoration: BoxDecoration(
                    color: MyColors.colorPrimary,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuSectionLabel extends StatelessWidget {
  const _MenuSectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 11),
      child: Text(
        label.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: .5,
          color: Color(0xFF8A8A8A),
        ),
      ),
    );
  }
}

class _UserSummary extends StatelessWidget {
  const _UserSummary({
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.loading,
  });

  final String name;
  final String email;
  final String? avatarUrl;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            color: Color(0xFFEAF3ED),
            shape: BoxShape.circle,
          ),
          child: loading
              ? const Padding(
                  padding: EdgeInsets.all(13),
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : avatarUrl != null
              ? Image.network(
                  avatarUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.person_outline,
                    color: MyColors.colorPrimary,
                  ),
                )
              : const Icon(Icons.person_outline, color: MyColors.colorPrimary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF313131),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 10,
                  color: Color(0xFF777777),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel({
    required this.name,
    required this.email,
    required this.phone,
    required this.document,
    required this.avatarUrl,
    required this.loading,
    required this.onEdit,
  });

  final String name;
  final String email;
  final String phone;
  final String document;
  final String? avatarUrl;
  final bool loading;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SizedBox(
        height: 320,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumo do perfil',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF252525),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Confira as principais informações da sua conta.',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13,
            color: Color(0xFF777777),
          ),
        ),
        const SizedBox(height: 28),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF3ED),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE7E4DD)),
              ),
              child: avatarUrl == null
                  ? const Icon(
                      Icons.person_outline,
                      size: 42,
                      color: MyColors.colorPrimary,
                    )
                  : Image.network(
                      avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person_outline,
                        size: 42,
                        color: MyColors.colorPrimary,
                      ),
                    ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF313131),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13,
                      color: Color(0xFF777777),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        const Divider(height: 1, color: Color(0xFFE7E4DD)),
        const SizedBox(height: 22),
        _SummaryRow(label: 'Nome', value: name),
        const SizedBox(height: 18),
        _SummaryRow(label: 'E-mail', value: email),
        const SizedBox(height: 18),
        _SummaryRow(label: 'Celular', value: phone),
        const SizedBox(height: 18),
        _SummaryRow(label: 'CPF', value: document),
        const SizedBox(height: 28),
        SizedBox(
          width: 210,
          height: 46,
          child: ElevatedButton.icon(
            onPressed: onEdit,
            icon: const Icon(LucideIcons.pencil, size: 16),
            label: const Text('Editar meus dados'),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: MyColors.colorPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 145,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              color: Color(0xFF777777),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.trim().isEmpty ? 'Não informado' : value,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF313131),
            ),
          ),
        ),
      ],
    );
  }
}
