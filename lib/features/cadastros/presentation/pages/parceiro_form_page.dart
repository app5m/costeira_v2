import 'package:costeira/app/app_route_data.dart';
import 'package:costeira/core/components/app_form_field.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/primary_app_bar.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/services/places_service.dart';
import 'package:costeira/features/cadastros/presentation/page_controllers/parceiro_form_page_controller.dart';
import 'package:costeira/features/cadastros/presentation/widgets/address_autocomplete_field.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class ParceiroFormPage extends StatefulWidget {
  const ParceiroFormPage({super.key, required this.data});

  final ParceiroFormRouteData data;

  @override
  State<ParceiroFormPage> createState() => _ParceiroFormPageState();
}

class _ParceiroFormPageState extends State<ParceiroFormPage> {
  final ParceiroFormPageController _pageController =
      Modular.get<ParceiroFormPageController>();
  final PlacesService _placesService = Modular.get<PlacesService>();

  @override
  void initState() {
    super.initState();
    _pageController.init(
      kind: widget.data.kind,
      appFazendasId: widget.data.appFazendasId,
      parceiro: widget.data.parceiro,
    );
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
                ? 'Editar ${_pageController.kind.singular.toLowerCase()}'
                : 'Adicionar ${_pageController.kind.singular.toLowerCase()}',
          ),
          body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tipo de pessoa',
                    style: TextStyle(
                      color: Color(0xFF313131),
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _ChoiceChipButton(
                          label: 'Pessoa física',
                          selected: _pageController.isPessoaFisica,
                          onTap: () => _pageController.setTipoPessoa(
                            WSConstantes.tipoPessoaFisica,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ChoiceChipButton(
                          label: 'Pessoa jurídica',
                          selected: !_pageController.isPessoaFisica,
                          onTap: () => _pageController.setTipoPessoa(
                            WSConstantes.tipoPessoaJuridica,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  AppFormField(
                    label: 'Nome completo',
                    hintText: 'Nome',
                    controller: _pageController.nomeController,
                  ),
                  const SizedBox(height: 16),
                  AppFormField(
                    label: 'E-mail',
                    hintText: 'email@exemplo.com',
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
                  if (_pageController.isPessoaFisica)
                    AppFormField(
                      label: 'CPF',
                      hintText: '000.000.000-00',
                      keyboardType: TextInputType.number,
                      controller: _pageController.cpfController,
                      inputFormatters: [_pageController.cpfMaskFormatter],
                    )
                  else ...[
                    AppFormField(
                      label: 'CNPJ',
                      hintText: '00.000.000/0000-00',
                      keyboardType: TextInputType.number,
                      controller: _pageController.cnpjController,
                      inputFormatters: [_pageController.cnpjMaskFormatter],
                      onChanged: _pageController.onCnpjChanged,
                      suffixIcon: _pageController.isLookingUpCnpj
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
                          ? const Icon(Icons.check_circle, color: Colors.green)
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
                    ),
                    const SizedBox(height: 16),
                    AppFormField(
                      label: 'Razão social',
                      hintText: 'Razão social',
                      controller: _pageController.razaoSocialController,
                    ),
                  ],
                  const SizedBox(height: 16),
                  AddressAutocompleteField(
                    controller: _pageController.enderecoController,
                    placesService: _placesService,
                  ),
                  const SizedBox(height: 16),
                  AppFormField(
                    label: 'Número',
                    hintText: '100',
                    keyboardType: TextInputType.text,
                    controller: _pageController.numeroController,
                  ),
                  const SizedBox(height: 16),
                  AppFormField(
                    label: 'Complemento',
                    hintText: 'Casa, sala...',
                    controller: _pageController.complementoController,
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
                        _pageController.isLoading ? 'Salvando...' : 'Salvar',
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
            fontSize: 13,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
