import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/components/app_buttons.dart';
import 'package:costeira/core/components/app_form_field.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/platform/local_file.dart';
import 'package:costeira/core/services/image_picker_service.dart';
import 'package:costeira/features/account/models/account_profile.dart';
import 'package:costeira/features/account/repositories/account_repository.dart';
import 'package:costeira/features/auth/models/user_session.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class ProfileWebDataPanel extends StatefulWidget {
  const ProfileWebDataPanel({
    required this.session,
    required this.profile,
    required this.onReloadProfile,
    super.key,
  });

  final UserSession? session;
  final AccountProfile? profile;
  final Future<void> Function() onReloadProfile;

  @override
  State<ProfileWebDataPanel> createState() => _ProfileWebDataPanelState();
}

class _ProfileWebDataPanelState extends State<ProfileWebDataPanel> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _PanelHeading(
          title: 'Alterar dados cadastrais',
          subtitle: 'Mantenha seus dados pessoais e da fazenda atualizados.',
        ),
        const SizedBox(height: 24),
        Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFE7E4DD))),
          ),
          child: Row(
            children: [
              _TabButton(
                label: 'Meus dados',
                selected: _tab == 0,
                onTap: () => setState(() => _tab = 0),
              ),
              _TabButton(
                label: 'Fazenda',
                selected: _tab == 1,
                onTap: () => setState(() => _tab = 1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        if (_tab == 0)
          _PersonalDataForm(
            session: widget.session,
            profile: widget.profile,
            onReloadProfile: widget.onReloadProfile,
          )
        else
          _FarmData(profile: widget.profile),
      ],
    );
  }
}

class _PanelHeading extends StatelessWidget {
  const _PanelHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF252525),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13,
            height: 1.5,
            color: Color(0xFF777777),
          ),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 11),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? MyColors.colorPrimary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: selected ? MyColors.colorPrimary : const Color(0xFF777777),
          ),
        ),
      ),
    );
  }
}

class _PersonalDataForm extends StatefulWidget {
  const _PersonalDataForm({
    required this.session,
    required this.profile,
    required this.onReloadProfile,
  });

  final UserSession? session;
  final AccountProfile? profile;
  final Future<void> Function() onReloadProfile;

  @override
  State<_PersonalDataForm> createState() => _PersonalDataFormState();
}

class _PersonalDataFormState extends State<_PersonalDataForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _cpfController = TextEditingController();
  final _phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );
  final _birthDateMask = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {'#': RegExp(r'[0-9]')},
  );
  final _cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {'#': RegExp(r'[0-9]')},
  );

  late final AccountRepository _repository;
  late final ImagePickerService _imagePicker;
  ImageProvider<Object>? _preview;
  bool _saving = false;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _repository = Modular.get<AccountRepository>();
    _imagePicker = ImagePickerService();
    _applyData();
  }

  @override
  void didUpdateWidget(covariant _PersonalDataForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile ||
        oldWidget.session != widget.session) {
      _applyData();
    }
  }

  void _applyData() {
    final profile = widget.profile;
    final session = widget.session;
    _nameController.text = profile?.name ?? session?.name ?? '';
    _emailController.text = profile?.email ?? session?.email ?? '';
    _phoneController.text = _phoneMask.maskText(
      profile?.phone ?? session?.phone ?? '',
    );
    _birthDateController.text = _birthDateMask.maskText(
      profile?.birthDate ?? '',
    );
    _cpfController.text = _cpfMask.maskText(
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

  String? get _avatarUrl {
    final avatar = widget.profile?.avatar.trim() ?? '';
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
    return Form(
      key: _formKey,
      onChanged: () => setState(() {}),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 82,
                    height: 82,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F2F0),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE7E4DD)),
                    ),
                    child: _avatar(),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Material(
                      color: MyColors.colorPrimary,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _uploading ? null : _pickAvatar,
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: _uploading
                              ? const Padding(
                                  padding: EdgeInsets.all(7),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.camera_alt_outlined,
                                  size: 16,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 18),
              const Expanded(
                child: Text(
                  'Clique no ícone para escolher uma nova foto de perfil.',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    height: 1.5,
                    color: Color(0xFF777777),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          LayoutBuilder(
            builder: (context, constraints) {
              final twoColumns = constraints.maxWidth >= 650;
              if (!twoColumns) {
                return Column(children: _fields(withSpacing: true));
              }
              final fields = _fields(withSpacing: false);
              return Column(
                children: [
                  for (var i = 0; i < fields.length; i += 2) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: fields[i]),
                        const SizedBox(width: 18),
                        Expanded(
                          child: i + 1 < fields.length
                              ? fields[i + 1]
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                    if (i + 2 < fields.length) const SizedBox(height: 18),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: 220,
            child: PrimaryButton(
              label: 'Salvar alterações',
              isLoading: _saving,
              onPressed: _canSubmit ? _save : null,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _fields({required bool withSpacing}) {
    final fields = <Widget>[
      AppFormField(
        label: 'Nome completo',
        hintText: 'Informe o nome completo',
        controller: _nameController,
        validator: _required,
      ),
      AppFormField(
        label: 'E-mail',
        hintText: 'Informe o e-mail',
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        readOnly: true,
      ),
      AppFormField(
        label: 'Celular',
        hintText: '(00) 00000-0000',
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        validator: _required,
        inputFormatters: [_phoneMask],
      ),
      AppFormField(
        label: 'Data de nascimento',
        hintText: '00/00/0000',
        controller: _birthDateController,
        keyboardType: TextInputType.number,
        inputFormatters: [_birthDateMask],
      ),
      AppFormField(
        label: 'CPF',
        hintText: '000.000.000-00',
        controller: _cpfController,
        keyboardType: TextInputType.number,
        validator: _required,
        inputFormatters: [_cpfMask],
      ),
    ];
    if (!withSpacing) return fields;
    return [
      for (var i = 0; i < fields.length; i++) ...[
        fields[i],
        if (i < fields.length - 1) const SizedBox(height: 18),
      ],
    ];
  }

  Widget _avatar() {
    if (_preview != null) {
      return Image(image: _preview!, fit: BoxFit.cover);
    }
    if (_avatarUrl != null) {
      return Image.network(
        _avatarUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _avatarFallback(),
      );
    }
    return _avatarFallback();
  }

  Widget _avatarFallback() {
    return Center(
      child: SvgPicture.asset(
        'icon/user-round.svg',
        width: 38,
        height: 38,
        colorFilter: const ColorFilter.mode(Color(0xFF7D8A82), BlendMode.srcIn),
      ),
    );
  }

  Future<void> _save() async {
    final session = widget.session;
    if (session == null) {
      _message('Usuário não autenticado.');
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final response = await _repository.updateUser(
        id: widget.profile?.id ?? session.id,
        tipoPessoa:
            widget.profile?.tipoPessoa ?? int.tryParse(session.tipo) ?? 1,
        name: _nameController.text.trim(),
        phone: _phoneMask.getUnmaskedText(),
        birthDate: _birthDateController.text.trim(),
        cpf: _cpfController.text.trim(),
      );
      _message(response.message, isError: !response.isSuccess);
      if (response.isSuccess) await widget.onReloadProfile();
    } on ApiException catch (error) {
      _message(error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickAvatar() async {
    final session = widget.session;
    if (session == null) {
      _message('Usuário não autenticado.');
      return;
    }
    final file = await _imagePicker.pickProfileImage();
    if (file == null) return;
    final preview = await imageProviderFromPath(file.path);
    if (!mounted) return;
    setState(() {
      _preview = preview;
      _uploading = true;
    });
    try {
      final response = await _repository.updateAvatar(
        userId: session.id,
        imagePath: file.path,
      );
      _message(response.message, isError: !response.isSuccess);
      if (response.isSuccess) await widget.onReloadProfile();
    } on ApiException catch (error) {
      _message(error.message);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  String? _required(String? value) =>
      (value ?? '').trim().isEmpty ? 'Campo obrigatório' : null;

  bool get _canSubmit =>
      _required(_nameController.text) == null &&
      _required(_emailController.text) == null &&
      _required(_phoneController.text) == null &&
      _required(_cpfController.text) == null;

  void _message(String message, {bool isError = true}) {
    if (!mounted) return;
    AppSnackBar.show(context: context, message: message, isError: isError);
  }
}

class _FarmData extends StatelessWidget {
  const _FarmData({required this.profile});

  final AccountProfile? profile;

  @override
  Widget build(BuildContext context) {
    final farm = profile?.farm;
    if (farm == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Text(
          'Os dados da fazenda não estão disponíveis no momento.',
          style: TextStyle(fontFamily: 'Montserrat', color: Color(0xFF777777)),
        ),
      );
    }

    final values = <({String label, String value})>[
      (label: 'Nome da fazenda', value: farm.name),
      (label: 'Endereço', value: farm.address),
      (label: 'Área total', value: _area(farm.totalArea)),
      (label: 'Área útil', value: _area(farm.usefulArea)),
      (
        label: 'Área utilizada para pecuária (verão)',
        value: _area(farm.summerLivestockArea),
      ),
      (
        label: 'Área utilizada para pecuária (inverno)',
        value: _area(farm.winterLivestockArea),
      ),
      (label: 'Atividades', value: _items(farm.activities)),
      (label: 'Sistemas de produção', value: _items(farm.productionSystems)),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 650;
        if (!twoColumns) {
          return Column(
            children: [
              for (var i = 0; i < values.length; i++) ...[
                _ReadonlyField(label: values[i].label, value: values[i].value),
                if (i < values.length - 1) const SizedBox(height: 16),
              ],
            ],
          );
        }
        return Column(
          children: [
            for (var i = 0; i < values.length; i += 2) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _ReadonlyField(
                      label: values[i].label,
                      value: values[i].value,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: _ReadonlyField(
                      label: values[i + 1].label,
                      value: values[i + 1].value,
                    ),
                  ),
                ],
              ),
              if (i + 2 < values.length) const SizedBox(height: 18),
            ],
          ],
        );
      },
    );
  }

  String _area(String value) =>
      value.trim().isEmpty ? 'Não informado' : '$value ha';

  String _items(List<ProfileNamedItem> items) {
    final names = items
        .map((item) => item.name.trim())
        .where((name) => name.isNotEmpty)
        .join(' • ');
    return names.isEmpty ? 'Não informado' : names;
  }
}

class _ReadonlyField extends StatelessWidget {
  const _ReadonlyField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13,
            color: Color(0xFF555555),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 50),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE7E4DD)),
          ),
          child: Text(
            value.trim().isEmpty ? 'Não informado' : value,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.4,
              color: Color(0xFF313131),
            ),
          ),
        ),
      ],
    );
  }
}
