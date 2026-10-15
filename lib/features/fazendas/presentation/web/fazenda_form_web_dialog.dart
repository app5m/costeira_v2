import 'package:costeira/core/components/app_form_field.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_entity.dart';
import 'package:costeira/features/fazendas/presentation/page_controllers/fazenda_form_page_controller.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class FazendaFormWebDialog extends StatefulWidget {
  const FazendaFormWebDialog({super.key, this.fazenda});

  final FazendaEntity? fazenda;

  @override
  State<FazendaFormWebDialog> createState() => _FazendaFormWebDialogState();
}

class _FazendaFormWebDialogState extends State<FazendaFormWebDialog> {
  late final FazendaFormPageController _controller;
  final ScrollController _scrollController = ScrollController();
  String? _submitError;

  @override
  void initState() {
    super.initState();
    _controller = Modular.get<FazendaFormPageController>();
    _controller.addListener(_refresh);
    _controller.init(fazenda: widget.fazenda);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_controller.isLoading || !_controller.isFormValid) return;
    setState(() => _submitError = null);
    final result = await _controller.submit();
    if (!mounted) return;
    if (result.isSuccess) {
      Navigator.of(context).pop({'success': true, 'message': result.message});
      return;
    }
    setState(() => _submitError = result.message);
  }

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.sizeOf(context);
    final availableHeight = (viewport.height - 48).clamp(320.0, 760.0);
    final narrow = viewport.width < 620;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.all(narrow ? 12 : 24),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: SizedBox(
        width: 700,
        height: availableHeight,
        child: Column(
          children: [
            _header(),
            const Divider(height: 1, color: Color(0xFFE7E4DD)),
            Expanded(
              child: _controller.isLoadingProfile
                  ? const Center(child: CircularProgressIndicator())
                  : Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: EdgeInsets.fromLTRB(
                          narrow ? 18 : 28,
                          24,
                          narrow ? 26 : 44,
                          28,
                        ),
                        child: _form(),
                      ),
                    ),
            ),
            const Divider(height: 1, color: Color(0xFFE7E4DD)),
            if (_submitError != null)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  narrow ? 18 : 28,
                  12,
                  narrow ? 18 : 28,
                  0,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _submitError!,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFC4473A),
                    ),
                  ),
                ),
              ),
            _footer(narrow),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return SizedBox(
      height: 66,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _controller.isEditing ? 'Editar fazenda' : 'Adicionar fazenda',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF252525),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Fechar',
              onPressed: _controller.isLoading || _controller.isLoadingProfile
                  ? null
                  : () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
      ),
    );
  }

  Widget _form() {
    return Column(
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
        if (_controller.profileError != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFDE9B)),
            ),
            child: const Text(
              'Conta principal não encontrada na API v2. Use CNPJ novo ou entre com um usuário v2.',
              style: TextStyle(
                color: Color(0xFF8B6508),
                fontSize: 12,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: _ChoiceButton(
                label: 'Sim',
                selected: _controller.mesmoCnpj,
                enabled: _controller.hasMatrizProfile,
                onTap: () => _controller.setMesmoCnpj(true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ChoiceButton(
                label: 'Não',
                selected: !_controller.mesmoCnpj,
                onTap: () => _controller.setMesmoCnpj(false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        AppFormField(
          label: 'Nome',
          hintText: 'Nome da fazenda',
          controller: _controller.nomeController,
        ),
        const SizedBox(height: 18),
        AppFormField(
          label: 'E-mail',
          hintText: 'email@fazenda.com',
          keyboardType: TextInputType.emailAddress,
          controller: _controller.emailController,
        ),
        const SizedBox(height: 18),
        AppFormField(
          label: 'Celular',
          hintText: '(00) 00000-0000',
          keyboardType: TextInputType.phone,
          controller: _controller.celularController,
          inputFormatters: [_controller.phoneMaskFormatter],
        ),
        const SizedBox(height: 18),
        AppFormField(
          label: 'CNPJ',
          hintText: '00.000.000/0000-00',
          keyboardType: TextInputType.number,
          controller: _controller.cnpjController,
          readOnly: _controller.mesmoCnpj,
          inputFormatters: [_controller.cnpjMaskFormatter],
          onChanged: _controller.onCnpjChanged,
          suffixIcon: _cnpjSuffix(),
        ),
        if (_controller.cnpjMessage != null) ...[
          const SizedBox(height: 6),
          Text(
            _controller.cnpjMessage!,
            style: TextStyle(
              fontFamily: 'Montserrat',
              color: _controller.cnpjMessageIsError
                  ? const Color(0xFFC4473A)
                  : _controller.isLookingUpCnpj
                  ? const Color(0xFF6B6B6B)
                  : _controller.isCnpjApproved
                  ? MyColors.colorPrimary
                  : const Color(0xFF8B6508),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        const SizedBox(height: 18),
        AppFormField(
          label: 'Nome fantasia',
          hintText: 'Nome fantasia',
          controller: _controller.nomeFantasiaController,
          readOnly: _controller.mesmoCnpj,
        ),
        const SizedBox(height: 18),
        AppFormField(
          label: 'Razão social',
          hintText: 'Razão social',
          controller: _controller.razaoSocialController,
          readOnly: _controller.mesmoCnpj,
        ),
      ],
    );
  }

  Widget? _cnpjSuffix() {
    if (_controller.mesmoCnpj) return null;
    if (_controller.isLookingUpCnpj) {
      return const Padding(
        padding: EdgeInsets.all(14),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (_controller.isCnpjApproved) {
      return const Icon(Icons.check_circle, color: MyColors.colorPrimary);
    }
    return null;
  }

  Widget _footer(bool narrow) {
    return Padding(
      padding: EdgeInsets.fromLTRB(narrow ? 18 : 28, 14, narrow ? 18 : 28, 18),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _controller.isLoading || _controller.isLoadingProfile
                  ? null
                  : () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                foregroundColor: const Color(0xFF4F5652),
                side: const BorderSide(color: Color(0xFFD8DDD9)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed:
                  _controller.isLoading ||
                      _controller.isLoadingProfile ||
                      !_controller.isFormValid
                  ? null
                  : _submit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                elevation: 0,
                backgroundColor: MyColors.colorPrimary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFBFC9C5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _controller.isLoading
                  ? const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Salvar',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : .5,
      child: Material(
        color: selected ? const Color(0x1400823A) : const Color(0xFFF5F5F3),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected
                    ? MyColors.colorPrimary
                    : const Color(0xFFE2E2DE),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: selected
                    ? MyColors.colorPrimary
                    : const Color(0xFF313131),
                fontSize: 13,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
