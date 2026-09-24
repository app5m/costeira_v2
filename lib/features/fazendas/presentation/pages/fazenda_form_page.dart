import 'package:costeira/core/components/app_form_field.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/primary_app_bar.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_entity.dart';
import 'package:costeira/features/fazendas/presentation/page_controllers/fazenda_form_page_controller.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class FazendaFormPage extends StatefulWidget {
  const FazendaFormPage({super.key, this.fazenda});

  final FazendaEntity? fazenda;

  @override
  State<FazendaFormPage> createState() => _FazendaFormPageState();
}

class _FazendaFormPageState extends State<FazendaFormPage> {
  final FazendaFormPageController _pageController =
      Modular.get<FazendaFormPageController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.init(fazenda: widget.fazenda);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final result = await _pageController.submit();
    if (!mounted) {
      return;
    }
    if (result.isSuccess) {
      Modular.to.pop({'success': true, 'message': result.message});
      return;
    }
    AppSnackBar.show(context: context, message: result.message, isError: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: PrimarySectionAppBar(
            context: context,
            title: _pageController.isEditing
                ? 'Editar fazenda'
                : 'Adicionar fazenda',
          ),
          body: _pageController.isLoadingProfile
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mesmo CNPJ?',
                          style: TextStyle(
                            color: Color(0xFF313131),
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_pageController.profileError != null) ...[
                          Text(
                            'Conta principal nao encontrada na API v2. Use CNPJ novo ou entre com um usuario v2.',
                            style: const TextStyle(
                              color: Color(0xFFB8860B),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        Row(
                          children: [
                            Expanded(
                              child: _ChoiceChipButton(
                                label: 'Sim',
                                selected: _pageController.mesmoCnpj,
                                onTap: _pageController.hasMatrizProfile
                                    ? () => _pageController.setMesmoCnpj(true)
                                    : () {},
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ChoiceChipButton(
                                label: 'Não',
                                selected: !_pageController.mesmoCnpj,
                                onTap: () =>
                                    _pageController.setMesmoCnpj(false),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        AppFormField(
                          label: 'Nome',
                          hintText: 'Nome da fazenda',
                          controller: _pageController.nomeController,
                        ),
                        const SizedBox(height: 16),
                        AppFormField(
                          label: 'E-mail',
                          hintText: 'email@fazenda.com',
                          keyboardType: TextInputType.emailAddress,
                          controller: _pageController.emailController,
                        ),
                        const SizedBox(height: 16),
                        AppFormField(
                          label: 'Celular',
                          hintText: '(00) 00000-0000',
                          keyboardType: TextInputType.phone,
                          controller: _pageController.celularController,
                          inputFormatters: [_pageController.phoneMaskFormatter],
                        ),
                        const SizedBox(height: 16),
                        AppFormField(
                          label: 'CNPJ',
                          hintText: '00.000.000/0000-00',
                          keyboardType: TextInputType.number,
                          controller: _pageController.cnpjController,
                          readOnly: _pageController.mesmoCnpj,
                          inputFormatters: [_pageController.cnpjMaskFormatter],
                          onChanged: _pageController.onCnpjChanged,
                          suffixIcon: _pageController.mesmoCnpj
                              ? null
                              : _pageController.isLookingUpCnpj
                              ? const Padding(
                                  padding: EdgeInsets.all(14),
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : _pageController.isCnpjApproved
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )
                              : null,
                        ),
                        if (_pageController.cnpjMessage != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            _pageController.cnpjMessage!,
                            style: TextStyle(
                              color: _pageController.cnpjMessageIsError
                                  ? Colors.red
                                  : _pageController.isLookingUpCnpj
                                  ? const Color(0xFF6B6B6B)
                                  : _pageController.isCnpjApproved
                                  ? Colors.green
                                  : const Color(0xFFB8860B),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        AppFormField(
                          label: 'Nome fantasia',
                          hintText: 'Nome fantasia',
                          controller: _pageController.nomeFantasiaController,
                          readOnly: _pageController.mesmoCnpj,
                        ),
                        const SizedBox(height: 16),
                        AppFormField(
                          label: 'Razão social',
                          hintText: 'Razão social',
                          controller: _pageController.razaoSocialController,
                          readOnly: _pageController.mesmoCnpj,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: MyColors.colorPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed:
                                _pageController.isLoading ||
                                    !_pageController.isFormValid
                                ? null
                                : _submit,
                            child: Text(
                              _pageController.isLoading
                                  ? 'Salvando...'
                                  : 'Salvar',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _ChoiceChipButton extends StatelessWidget {
  const _ChoiceChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0x14128977) : const Color(0xFFEBEBEB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? MyColors.colorPrimary : const Color(0xFFE6E6E6),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? MyColors.colorPrimary : const Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
