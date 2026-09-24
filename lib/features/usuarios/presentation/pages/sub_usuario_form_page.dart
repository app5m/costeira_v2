import 'package:costeira/app/app_route_data.dart';
import 'package:costeira/core/components/app_form_field.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/form_accordion.dart';
import 'package:costeira/core/components/primary_app_bar.dart';
import 'package:costeira/core/menus/menu_icon.dart';
import 'package:costeira/features/usuarios/domain/entities/usuario_permissao_entity.dart';
import 'package:costeira/features/usuarios/presentation/page_controllers/sub_usuario_form_page_controller.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class SubUsuarioFormPage extends StatefulWidget {
  const SubUsuarioFormPage({super.key, this.data});

  final SubUsuarioFormRouteData? data;

  @override
  State<SubUsuarioFormPage> createState() => _SubUsuarioFormPageState();
}

class _SubUsuarioFormPageState extends State<SubUsuarioFormPage> {
  final SubUsuarioFormPageController _pageController =
      Modular.get<SubUsuarioFormPageController>();

  @override
  void initState() {
    super.initState();
    _pageController.init(usuario: widget.data?.usuario);
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
          backgroundColor: const Color(0xFFF6F4EE),
          appBar: PrimarySectionAppBar(
            context: context,
            title: _pageController.isEditing
                ? 'Editar usuário'
                : 'Novo usuário',
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    FormAccordion(
                      title: 'Dados',
                      initiallyExpanded: true,
                      complete: _pageController.isDadosComplete,
                      child: Column(
                        children: [
                          AppFormField(
                            label: 'Nome',
                            hintText: 'Nome completo',
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
                            inputFormatters: [
                              _pageController.phoneMaskFormatter,
                            ],
                          ),
                        ],
                      ),
                    ),
                    FormAccordion(
                      title: 'Fazendas',
                      initiallyExpanded: true,
                      complete: _pageController.isFazendasComplete,
                      child: _buildFarms(),
                    ),
                    FormAccordion(
                      title: 'Permissões',
                      initiallyExpanded: true,
                      complete: _pageController.isPermissoesComplete,
                      child: _buildPermissions(),
                    ),
                    if (_pageController.errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _pageController.errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              FormStickyFooter(
                lines: [
                  ('Fazendas', '${_pageController.selectedFarmIds.length}'),
                  (
                    'Permissões',
                    '${_pageController.selectedPermissionIds.length}',
                  ),
                ],
                buttonText: _pageController.isEditing ? 'Salvar' : 'Cadastrar',
                enabled: _pageController.isFormValid,
                isLoading: _pageController.isLoading,
                onSubmit: _submit,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFarms() {
    if (_pageController.fazendas.isEmpty) {
      return const Text(
        'Cadastre uma fazenda antes de vincular o acesso.',
        style: TextStyle(color: Colors.red, fontSize: 13),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final farm in _pageController.fazendas)
          FilterChip(
            label: Text(farm.nome.isEmpty ? 'Fazenda ${farm.id}' : farm.nome),
            selected: _pageController.selectedFarmIds.contains(farm.id),
            selectedColor: const Color(0x1400823A),
            checkmarkColor: MyColors.colorPrimary,
            onSelected: (_) => _pageController.toggleFarm(farm.id),
          ),
      ],
    );
  }

  Widget _buildPermissions() {
    if (_pageController.permissoes.isEmpty) {
      return const Text(
        'Nenhuma permissão disponível.',
        style: TextStyle(color: Color(0xFF6B6B6B), fontSize: 13),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _pageController.toggleAllPermissions,
            child: Text(
              _pageController.isAllPermissionsSelected
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
        for (var i = 0; i < _pageController.permissoes.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _PermissionTile(
            item: _pageController.permissoes[i],
            selected: _pageController.selectedPermissionIds.contains(
              _pageController.permissoes[i].id,
            ),
            onTap: () => _pageController.togglePermission(
              _pageController.permissoes[i].id,
            ),
          ),
        ],
      ],
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
      size: 22,
      color: selected ? MyColors.colorPrimary : const Color(0xFF313131),
    );
    final descricao = item.descricao?.trim() ?? '';

    return Material(
      color: selected ? const Color(0x1400823A) : const Color(0xFFF7F6F2),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Padding(padding: const EdgeInsets.only(top: 2), child: icon),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nome,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? MyColors.colorPrimary
                            : const Color(0xFF313131),
                      ),
                    ),
                    if (descricao.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        descricao,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B6B6B),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              IgnorePointer(
                child: Checkbox(
                  value: selected,
                  activeColor: MyColors.colorPrimary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  onChanged: (_) {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
