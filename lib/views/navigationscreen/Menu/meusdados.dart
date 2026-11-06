import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/platform/local_file.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/services/image_picker_service.dart';
import 'package:costeira/features/account/models/account_profile.dart';
import 'package:costeira/features/account/repositories/account_repository.dart';
import 'package:costeira/features/auth/models/user_session.dart';
import 'package:costeira/theme/colors.dart';
import 'package:costeira/core/components/app_buttons.dart';
import 'package:costeira/core/components/app_form_field.dart';
import 'package:costeira/core/components/primary_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class MeusDados extends StatefulWidget {
  const MeusDados({super.key});

  @override
  State<MeusDados> createState() => _MeusDadosState();
}

class _MeusDadosState extends State<MeusDados>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final AccountRepository _accountRepository = AccountRepository();

  UserSession? _user;
  AccountProfile? _profile;
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    final user = await SessionStorage.getUserSession();
    if (!mounted) {
      return;
    }

    if (user == null) {
      setState(() {
        _user = null;
        _profile = null;
        _isLoading = false;
        _loadError = 'Usuário não autenticado.';
      });
      return;
    }

    try {
      final profile = await _accountRepository.fetchProfile(userId: user.id);
      final updatedSession = _profileToSession(profile, currentUser: user);
      await SessionStorage.saveUserSession(updatedSession);

      if (!mounted) {
        return;
      }

      setState(() {
        _user = updatedSession;
        _profile = profile;
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _user = user;
        _profile = null;
        _isLoading = false;
        _loadError = error.message;
      });
    }
  }

  UserSession _profileToSession(
    AccountProfile profile, {
    required UserSession currentUser,
  }) {
    return UserSession(
      id: profile.id,
      name: profile.name,
      email: profile.email,
      phone: profile.phone,
      document: profile.cpf.isNotEmpty ? profile.cpf : profile.cnpj,
      nickname: currentUser.nickname,
      tipo: profile.tipoPessoa.toString(),
      appSubUsersId: currentUser.appSubUsersId,
      ownerUserId: currentUser.ownerUserId,
      idGrupo: profile.idGrupo ?? currentUser.idGrupo,
      managedClientId: currentUser.managedClientId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PrimarySectionAppBar(context: context, title: 'Meus dados'),
      body: SafeArea(
        child: Column(
          children: [
            if (_loadError != null && !_isLoading)
              _ProfileErrorBanner(message: _loadError!, onRetry: _loadProfile),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Meus dados'),
                Tab(text: 'Fazenda'),
              ],
              indicatorColor: MyColors.colorPrimary2,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _ResponsibleDataTab(
                          session: _user,
                          profile: _profile,
                          onReloadProfile: _loadProfile,
                        ),
                        _FarmDataTab(profile: _profile),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResponsibleDataTab extends StatefulWidget {
  const _ResponsibleDataTab({
    required this.session,
    required this.profile,
    required this.onReloadProfile,
  });

  final UserSession? session;
  final AccountProfile? profile;
  final Future<void> Function() onReloadProfile;

  @override
  State<_ResponsibleDataTab> createState() => _ResponsibleDataTabState();
}

class _ResponsibleDataTabState extends State<_ResponsibleDataTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _cpfController = TextEditingController();
  final _accountRepository = AccountRepository();
  final _imagePickerService = ImagePickerService();
  final _phoneMaskFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );
  final _birthDateMaskFormatter = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {'#': RegExp(r'[0-9]')},
  );
  final _cpfMaskFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {'#': RegExp(r'[0-9]')},
  );

  ImageProvider<Object>? _selectedImage;
  bool _isUploadingImage = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _applyProfile();
  }

  @override
  void didUpdateWidget(covariant _ResponsibleDataTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile ||
        oldWidget.session != widget.session) {
      _applyProfile();
    }
  }

  void _applyProfile() {
    final profile = widget.profile;
    final session = widget.session;

    _nameController.text = profile?.name ?? session?.name ?? '';
    _emailController.text = profile?.email ?? session?.email ?? '';
    _phoneController.text = _phoneMaskFormatter.maskText(
      profile?.phone ?? session?.phone ?? '',
    );
    _birthDateController.text = _birthDateMaskFormatter.maskText(
      profile?.birthDate ?? '',
    );
    _cpfController.text = _cpfMaskFormatter.maskText(
      profile?.cpf ?? session?.document ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _cpfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        onChanged: () => setState(() {}),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFFEBEBEB),
                    backgroundImage: _selectedImage,
                    child: _selectedImage == null
                        ? SvgPicture.asset(
                            'icon/user-round.svg',
                            width: 40,
                            height: 40,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _isUploadingImage ? null : _pickAndUploadImage,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFE6E6E6)),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _isUploadingImage
                            ? const Padding(
                                padding: EdgeInsets.all(6),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.image_outlined,
                                color: Colors.grey,
                                size: 18,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppFormField(
              label: 'Nome completo',
              hintText: 'Informe o nome completo',
              controller: _nameController,
              validator: _requiredField,
            ),
            const SizedBox(height: 16),
            AppFormField(
              label: 'E-mail',
              hintText: 'Informe o e-mail',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              readOnly: true,
            ),
            const SizedBox(height: 16),
            AppFormField(
              label: 'WhatsApp',
              hintText: '(00) 00000-0000',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              validator: _requiredField,
              inputFormatters: [_phoneMaskFormatter],
            ),
            const SizedBox(height: 16),
            AppFormField(
              label: 'Data de nascimento',
              hintText: '00/00/0000',
              controller: _birthDateController,
              keyboardType: TextInputType.number,
              inputFormatters: [_birthDateMaskFormatter],
            ),
            const SizedBox(height: 16),
            AppFormField(
              label: 'CPF',
              hintText: '000.000.000-00',
              controller: _cpfController,
              keyboardType: TextInputType.number,
              validator: _requiredField,
              inputFormatters: [_cpfMaskFormatter],
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Salvar',
              isLoading: _isSaving,
              onPressed: _canSubmit ? _saveProfile : null,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    final session = widget.session;
    final profile = widget.profile;

    if (session == null) {
      _showMessage('Usuário não autenticado.');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final response = await _accountRepository.updateUser(
        id: profile?.id ?? session.id,
        tipoPessoa: profile?.tipoPessoa ?? int.tryParse(session.tipo) ?? 1,
        name: _nameController.text.trim(),
        phone: _phoneMaskFormatter.getUnmaskedText(),
        birthDate: _birthDateController.text.trim(),
        cpf: _cpfController.text.trim(),
      );

      _showMessage(response.message, isError: !response.isSuccess);

      if (response.isSuccess) {
        await widget.onReloadProfile();
      }
    } on ApiException catch (error) {
      _showMessage(error.message);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final session = widget.session;
    if (session == null) {
      _showMessage('Usuário não autenticado.');
      return;
    }

    final pickedFile = await _imagePickerService.pickProfileImage();
    if (pickedFile == null) {
      return;
    }

    final preview = await imageProviderFromPath(pickedFile.path);
    if (!mounted) {
      return;
    }

    setState(() {
      _isUploadingImage = true;
      _selectedImage = preview;
    });

    try {
      final response = await _accountRepository.updateAvatar(
        userId: session.id,
        imagePath: pickedFile.path,
      );
      _showMessage(response.message, isError: !response.isSuccess);
      await widget.onReloadProfile();
    } on ApiException catch (error) {
      _showMessage(error.message);
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  String? _requiredField(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }

  bool get _canSubmit =>
      _requiredField(_nameController.text) == null &&
      _requiredField(_emailController.text) == null &&
      _requiredField(_phoneController.text) == null &&
      _requiredField(_cpfController.text) == null;

  void _showMessage(String message, {bool isError = true}) {
    if (!mounted) {
      return;
    }

    AppSnackBar.show(context: context, message: message, isError: isError);
  }
}

class _FarmDataTab extends StatelessWidget {
  const _FarmDataTab({required this.profile});

  final AccountProfile? profile;

  @override
  Widget build(BuildContext context) {
    final profile = this.profile;
    final farm = profile?.farm;

    if (profile == null || !profile.hasFarmCadastro) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Os dados da fazenda não estão disponíveis no momento.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF8C8C8C),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    final farmName = _orDash(
      farm?.name.isNotEmpty == true ? farm!.name : profile.nomeFantasia,
    );

    final rows = <({String label, String value})>[
      (label: 'Nome fantasia', value: _orDash(profile.nomeFantasia)),
      (label: 'Razão social', value: _orDash(profile.razaoSocial)),
      (label: 'CNPJ', value: _orDash(profile.cnpj)),
      (label: 'Inscrição estadual', value: _orDash(profile.ie)),
    ];

    if (farm != null) {
      if (farm.address.trim().isNotEmpty) {
        rows.add((label: 'Endereço', value: farm.address.trim()));
      }
      if (farm.totalArea.trim().isNotEmpty) {
        rows.add((label: 'Área total', value: _formatArea(farm.totalArea)));
      }
      if (farm.usefulArea.trim().isNotEmpty) {
        rows.add((label: 'Área útil', value: _formatArea(farm.usefulArea)));
      }
      if (farm.summerLivestockArea.trim().isNotEmpty) {
        rows.add((
          label: 'Pecuária (verão)',
          value: _formatArea(farm.summerLivestockArea),
        ));
      }
      if (farm.winterLivestockArea.trim().isNotEmpty) {
        rows.add((
          label: 'Pecuária (inverno)',
          value: _formatArea(farm.winterLivestockArea),
        ));
      }
      if (farm.activities.isNotEmpty) {
        rows.add((label: 'Atividades', value: _joinItems(farm.activities)));
      }
      if (farm.productionSystems.isNotEmpty) {
        rows.add((
          label: 'Sistema produtivo',
          value: _joinItems(farm.productionSystems),
        ));
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0xFFEBEBEB)),
              borderRadius: BorderRadius.circular(12),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 24,
                offset: Offset(0, 0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0x14128977),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      LucideIcons.warehouse,
                      size: 20,
                      color: MyColors.colorPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Fazenda',
                          style: TextStyle(
                            color: Color(0xFF8C8C8C),
                            fontSize: 12,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          farmName,
                          style: const TextStyle(
                            color: Color(0xFF313131),
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFEBEBEB)),
              const SizedBox(height: 8),
              for (var i = 0; i < rows.length; i++) ...[
                _FarmInfoRow(label: rows[i].label, value: rows[i].value),
                if (i < rows.length - 1)
                  const Divider(height: 1, color: Color(0xFFF3F3F3)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _joinItems(List<ProfileNamedItem> items) {
    if (items.isEmpty) {
      return 'Não informado';
    }
    return items
        .map((item) => item.name)
        .where((name) => name.isNotEmpty)
        .join(' • ');
  }

  String _formatArea(String value) {
    if (value.trim().isEmpty) {
      return 'Não informado';
    }
    return '$value ha';
  }

  String _orDash(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? 'Não informado' : trimmed;
  }
}

class _FarmInfoRow extends StatelessWidget {
  const _FarmInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 128,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF8C8C8C),
                fontSize: 12,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.trim().isEmpty ? 'Não informado' : value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF313131),
                fontSize: 13,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileErrorBanner extends StatelessWidget {
  const _ProfileErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD7A3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF9A6100)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF7A4B00),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Tentar novamente')),
        ],
      ),
    );
  }
}
