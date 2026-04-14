import 'dart:io';

import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/services/image_picker_service.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/account/repositories/account_repository.dart';
import 'package:costeira/features/auth/models/user_session.dart';
import 'package:costeira/theme/colors.dart';
import 'package:costeira/views/shared/widgets/app_buttons.dart';
import 'package:costeira/views/shared/widgets/app_form_field.dart';
import 'package:costeira/views/shared/widgets/primary_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MeusDados extends StatefulWidget {
  const MeusDados({super.key});

  @override
  State<MeusDados> createState() => _MeusDadosState();
}

class _MeusDadosState extends State<MeusDados>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  UserSession? _user;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PrimarySectionAppBar(
        context: context,
        title: 'Meus dados',
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Empresa'),
              Tab(text: 'Responsável'),
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
            child: TabBarView(
              controller: _tabController,
              children: [
                const _CompanyDataTab(),
                _ResponsibleDataTab(user: _user),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyDataTab extends StatefulWidget {
  const _CompanyDataTab();

  @override
  State<_CompanyDataTab> createState() => _CompanyDataTabState();
}

class _CompanyDataTabState extends State<_CompanyDataTab> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _tradeNameController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  @override
  void dispose() {
    _companyNameController.dispose();
    _tradeNameController.dispose();
    _cnpjController.dispose();
    _cityController.dispose();
    _stateController.dispose();
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
            AppFormField(
              label: 'Razão social',
              hintText: 'Informe a razão social',
              controller: _companyNameController,
              validator: _requiredField,
            ),
            const SizedBox(height: 16),
            AppFormField(
              label: 'Nome fantasia',
              hintText: 'Informe o nome fantasia',
              controller: _tradeNameController,
              validator: _requiredField,
            ),
            const SizedBox(height: 16),
            AppFormField(
              label: 'CNPJ',
              hintText: '00.000.000/0000-00',
              controller: _cnpjController,
              keyboardType: TextInputType.number,
              validator: _requiredField,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppFormField(
                    label: 'Cidade',
                    hintText: 'Cidade',
                    controller: _cityController,
                    validator: _requiredField,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppFormField(
                    label: 'UF',
                    hintText: 'UF',
                    controller: _stateController,
                    maxLength: 2,
                    validator: _requiredField,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Salvar',
              onPressed: _canSubmit
                  ? () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Aguardando contrato da API para atualização da empresa.',
                      ),
                    ),
                  );
                }
                    }
                  : null,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String? _requiredField(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }

  bool get _canSubmit =>
      _requiredField(_companyNameController.text) == null &&
      _requiredField(_tradeNameController.text) == null &&
      _requiredField(_cnpjController.text) == null &&
      _requiredField(_cityController.text) == null &&
      _requiredField(_stateController.text) == null;
}

class _ResponsibleDataTab extends StatefulWidget {
  const _ResponsibleDataTab({required this.user});

  final UserSession? user;

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
  final AccountRepository _accountRepository = AccountRepository();
  final ImagePickerService _imagePickerService = ImagePickerService();

  File? _selectedImage;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _applyUser();
  }

  @override
  void didUpdateWidget(covariant _ResponsibleDataTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user != widget.user) {
      _applyUser();
    }
  }

  void _applyUser() {
    _nameController.text = widget.user?.name ?? '';
    _emailController.text = widget.user?.email ?? '';
    _phoneController.text = widget.user?.phone ?? '';
    _cpfController.text = widget.user?.document ?? '';
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
                    backgroundImage:
                        _selectedImage != null ? FileImage(_selectedImage!) : null,
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
                                child: CircularProgressIndicator(strokeWidth: 2),
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
              validator: _requiredField,
            ),
            const SizedBox(height: 16),
            AppFormField(
              label: 'WhatsApp',
              hintText: 'Informe o WhatsApp',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              validator: _requiredField,
            ),
            const SizedBox(height: 16),
            AppFormField(
              label: 'Data de nascimento',
              hintText: '00/00/0000',
              controller: _birthDateController,
            ),
            const SizedBox(height: 16),
            AppFormField(
              label: 'CPF',
              hintText: '000.000.000-00',
              controller: _cpfController,
              validator: _requiredField,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Salvar',
              onPressed: _canSubmit
                  ? () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Aguardando contrato da API para atualização do responsável.',
                      ),
                    ),
                  );
                }
                    }
                  : null,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage() async {
    if (widget.user == null) {
      _showMessage('Usuário não autenticado.');
      return;
    }

    final pickedFile = await _imagePickerService.pickProfileImage();
    if (pickedFile == null) {
      return;
    }

    setState(() {
      _isUploadingImage = true;
      _selectedImage = File(pickedFile.path);
    });

    try {
      final response = await _accountRepository.updateAvatar(
        userId: widget.user!.id,
        imageFile: File(pickedFile.path),
      );
      _showMessage(response.message);
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

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
