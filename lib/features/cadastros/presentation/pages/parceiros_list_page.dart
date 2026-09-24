import 'package:costeira/app/app_route_data.dart';
import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/primary_app_bar.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_entity.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_kind.dart';
import 'package:costeira/features/cadastros/presentation/page_controllers/parceiros_list_page_controller.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ParceirosListPage extends StatefulWidget {
  const ParceirosListPage({super.key, required this.kind});

  final ParceiroKind kind;

  @override
  State<ParceirosListPage> createState() => _ParceirosListPageState();
}

class _ParceirosListPageState extends State<ParceirosListPage> {
  final ParceirosListPageController _pageController =
      Modular.get<ParceirosListPageController>();

  @override
  void initState() {
    super.initState();
    _pageController.init(widget.kind);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.loadInitialData();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openAdd() async {
    final farmId = _pageController.selectedFarmId;
    if (farmId == null) {
      _showMessage('Cadastre uma fazenda antes.');
      return;
    }

    final result = await Modular.to.pushNamed<Map<String, dynamic>?>(
      widget.kind == ParceiroKind.fornecedor
          ? AppRoutes.fornecedoresAdd
          : AppRoutes.compradoresAdd,
      arguments: ParceiroFormRouteData(
        kind: widget.kind,
        appFazendasId: farmId,
      ),
    );
    if (!mounted || result?['success'] != true) {
      return;
    }
    await _pageController.reload();
    if (!mounted) {
      return;
    }
    _showMessage(
      result?['message']?.toString() ?? 'Cadastro salvo com sucesso.',
      isError: false,
    );
  }

  Future<void> _openEdit(ParceiroEntity parceiro) async {
    final farmId = _pageController.selectedFarmId ?? parceiro.appFazendasId;
    final result = await Modular.to.pushNamed<Map<String, dynamic>?>(
      widget.kind == ParceiroKind.fornecedor
          ? AppRoutes.fornecedoresEdit
          : AppRoutes.compradoresEdit,
      arguments: ParceiroFormRouteData(
        kind: widget.kind,
        appFazendasId: farmId,
        parceiro: parceiro,
      ),
    );
    if (!mounted || result?['success'] != true) {
      return;
    }
    await _pageController.reload();
    if (!mounted) {
      return;
    }
    _showMessage(
      result?['message']?.toString() ?? 'Cadastro atualizado com sucesso.',
      isError: false,
    );
  }

  Future<void> _confirmDelete(ParceiroEntity parceiro) async {
    await showModalBottomSheet<void>(
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (modalContext) {
        return AnimatedBuilder(
          animation: _pageController,
          builder: (context, _) {
            return SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Excluir ${widget.kind.singular.toLowerCase()}?',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tem certeza que deseja excluir ${parceiro.nome}?',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF8692A8)),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _pageController.isDeleting
                            ? null
                            : () async {
                                final result = await _pageController
                                    .deleteParceiro(parceiro);
                                if (!context.mounted) {
                                  return;
                                }
                                Navigator.of(modalContext).pop();
                                _showMessage(
                                  result.message,
                                  isError: !result.isSuccess,
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: Text(
                          _pageController.isDeleting
                              ? 'Excluindo...'
                              : 'Excluir',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(modalContext).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showMessage(String message, {bool isError = true}) {
    AppSnackBar.show(context: context, message: message, isError: isError);
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
            title: widget.kind.title,
          ),
          floatingActionButton: _pageController.selectedFarmId == null
              ? null
              : FloatingActionButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(64),
                  ),
                  onPressed: _openAdd,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
          body: RefreshIndicator(
            onRefresh: () => _pageController.reload(),
            child: _buildBody(),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_pageController.isLoading &&
        _pageController.fazendas.isEmpty &&
        _pageController.parceiros.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 88),
      children: [
        if (_pageController.fazendas.isNotEmpty) ...[
          const Text(
            'Fazenda',
            style: TextStyle(
              color: Color(0xFF313131),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: _pageController.selectedFarmId,
            items: [
              for (final farm in _pageController.fazendas)
                DropdownMenuItem(
                  value: farm.id,
                  child: Text(
                    farm.nome.isEmpty ? 'Fazenda ${farm.id}' : farm.nome,
                  ),
                ),
            ],
            onChanged: (value) {
              if (value != null) {
                _pageController.selectFarm(value);
              }
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFEBEBEB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _pageController.nomeController,
            decoration: InputDecoration(
              hintText: 'Filtrar por nome',
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: const Color(0xFFEBEBEB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (_pageController.fazendas.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 80),
            child: Center(
              child: Text(
                'Cadastre uma fazenda para gerenciar fornecedores e compradores.',
                textAlign: TextAlign.center,
              ),
            ),
          )
        else if (_pageController.errorMessage != null &&
            _pageController.parceiros.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Center(child: Text(_pageController.errorMessage!)),
          )
        else if (_pageController.parceiros.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Center(
              child: Text(
                'Nenhum ${widget.kind.singular.toLowerCase()} cadastrado.',
              ),
            ),
          )
        else
          ..._pageController.parceiros.map(_buildCard),
      ],
    );
  }

  Widget _buildCard(ParceiroEntity parceiro) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openEdit(parceiro),
        onLongPress: () => _confirmDelete(parceiro),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Color(0xFFEBEBEB)),
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
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0x14128977),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.kind == ParceiroKind.fornecedor
                      ? LucideIcons.truck
                      : LucideIcons.shoppingBag,
                  size: 20,
                  color: MyColors.colorPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      parceiro.nome.isEmpty
                          ? widget.kind.singular
                          : parceiro.nome,
                      style: const TextStyle(
                        color: Color(0xFF313131),
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      parceiro.isPessoaFisica
                          ? 'Pessoa física'
                          : 'Pessoa jurídica',
                      style: const TextStyle(
                        color: Color(0xFF8C8C8C),
                        fontSize: 12,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    if (parceiro.email.isNotEmpty)
                      Text(
                        parceiro.email,
                        style: const TextStyle(
                          color: Color(0xFF8C8C8C),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _confirmDelete(parceiro),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
