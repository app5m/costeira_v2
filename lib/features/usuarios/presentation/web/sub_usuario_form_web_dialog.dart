import 'package:costeira/core/components/app_form_field.dart';
import 'package:costeira/core/menus/menu_icon.dart';
import 'package:costeira/features/usuarios/domain/entities/sub_usuario_entity.dart';
import 'package:costeira/features/usuarios/domain/entities/usuario_permissao_entity.dart';
import 'package:costeira/features/usuarios/presentation/page_controllers/sub_usuario_form_page_controller.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class SubUsuarioFormWebDialog extends StatefulWidget {
  const SubUsuarioFormWebDialog({super.key, this.usuario});

  final SubUsuarioEntity? usuario;

  @override
  State<SubUsuarioFormWebDialog> createState() =>
      _SubUsuarioFormWebDialogState();
}

class _SubUsuarioFormWebDialogState extends State<SubUsuarioFormWebDialog> {
  late final SubUsuarioFormPageController _controller;
  final ScrollController _scrollController = ScrollController();
  String? _submitError;

  @override
  void initState() {
    super.initState();
    _controller = Modular.get<SubUsuarioFormPageController>();
    _controller.addListener(_refresh);
    _controller.init(usuario: widget.usuario);
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
    final narrow = viewport.width < 620;
    final height = (viewport.height - 48).clamp(320.0, 760.0);
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.all(narrow ? 8 : 24),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: SizedBox(
        width: 700,
        height: height,
        child: Column(
          children: [
            _header(),
            const Divider(height: 1, color: Color(0xFFE7E4DD)),
            Expanded(child: _body(narrow)),
            const Divider(height: 1, color: Color(0xFFE7E4DD)),
            if (_submitError != null || _controller.errorMessage != null)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  narrow ? 16 : 28,
                  12,
                  narrow ? 16 : 28,
                  0,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _submitError ?? _controller.errorMessage!,
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
                _controller.isEditing ? 'Editar usuário' : 'Novo usuário',
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
              onPressed: _controller.isLoading
                  ? null
                  : () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(bool narrow) {
    if (_controller.isLoadingLookups) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_controller.lookupError != null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Text(
            'Nao foi possivel carregar fazendas e permissoes.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFFC4473A),
            ),
          ),
        ),
      );
    }
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(
          narrow ? 16 : 28,
          22,
          narrow ? 24 : 40,
          28,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Section(title: 'Dados', child: _dados()),
            const SizedBox(height: 18),
            _Section(title: 'Fazendas', child: _farms()),
            const SizedBox(height: 18),
            _Section(title: 'Permissões', child: _permissions()),
          ],
        ),
      ),
    );
  }

  Widget _dados() {
    return Column(
      children: [
        AppFormField(
          label: 'Nome',
          hintText: 'Nome completo',
          controller: _controller.nomeController,
        ),
        const SizedBox(height: 16),
        AppFormField(
          label: 'E-mail',
          hintText: 'email@exemplo.com',
          keyboardType: TextInputType.emailAddress,
          controller: _controller.emailController,
        ),
        const SizedBox(height: 16),
        AppFormField(
          label: 'Celular',
          hintText: '(00) 00000-0000',
          keyboardType: TextInputType.phone,
          controller: _controller.celularController,
          inputFormatters: [_controller.phoneMaskFormatter],
        ),
      ],
    );
  }

  Widget _farms() {
    if (_controller.fazendas.isEmpty) {
      return const Text(
        'Cadastre uma fazenda antes de vincular o acesso.',
        style: TextStyle(
          fontFamily: 'Montserrat',
          color: Color(0xFFC4473A),
          fontSize: 13,
        ),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final farm in _controller.fazendas)
          FilterChip(
            label: Text(farm.nome.isEmpty ? 'Fazenda ${farm.id}' : farm.nome),
            selected: _controller.selectedFarmIds.contains(farm.id),
            selectedColor: const Color(0x1400823A),
            checkmarkColor: MyColors.colorPrimary,
            side: const BorderSide(color: Color(0xFFE7E4DD)),
            onSelected: (_) => _controller.toggleFarm(farm.id),
          ),
      ],
    );
  }

  Widget _permissions() {
    if (_controller.permissoes.isEmpty) {
      return const Text(
        'Nenhuma permissão disponível.',
        style: TextStyle(
          fontFamily: 'Montserrat',
          color: Color(0xFF6B6B6B),
          fontSize: 13,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _controller.toggleAllPermissions,
            child: Text(
              _controller.isAllPermissionsSelected
                  ? 'Limpar todas'
                  : 'Selecionar todas',
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                color: MyColors.colorPrimary,
              ),
            ),
          ),
        ),
        for (var i = 0; i < _controller.permissoes.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _PermissionTile(
            item: _controller.permissoes[i],
            selected: _controller.selectedPermissionIds.contains(
              _controller.permissoes[i].id,
            ),
            onTap: () =>
                _controller.togglePermission(_controller.permissoes[i].id),
          ),
        ],
      ],
    );
  }

  Widget _footer(bool narrow) {
    return Padding(
      padding: EdgeInsets.all(narrow ? 16 : 20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${_controller.selectedFarmIds.length} fazenda(s) · '
              '${_controller.selectedPermissionIds.length} permissão(ões)',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF777777),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _controller.isLoading || !_controller.isFormValid
                ? null
                : _submit,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              minimumSize: const Size(120, 44),
              backgroundColor: MyColors.colorPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              _controller.isLoading
                  ? 'Salvando...'
                  : _controller.isEditing
                  ? 'Salvar'
                  : 'Cadastrar',
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7E4DD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF313131),
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final UsuarioPermissaoEntity item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = MenuIcon.maybe(
      icon: item.icon,
      size: 21,
      color: selected ? MyColors.colorPrimary : const Color(0xFF5E6E64),
    );
    final description = item.descricao?.trim() ?? '';
    return Material(
      color: selected ? const Color(0x1400823A) : const Color(0xFFF8F7F3),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Padding(padding: const EdgeInsets.only(top: 2), child: icon),
                const SizedBox(width: 11),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nome,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? MyColors.colorPrimary
                            : const Color(0xFF313131),
                      ),
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        description,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 11,
                          color: Color(0xFF6B6B6B),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IgnorePointer(
                child: Checkbox(
                  value: selected,
                  onChanged: (_) {},
                  activeColor: MyColors.colorPrimary,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
