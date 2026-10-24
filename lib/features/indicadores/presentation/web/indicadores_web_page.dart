import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/common/get_list/domain/usecases/get_list_usecase.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/animals/domain/usecases/get_animal_lots_usecase.dart';
import 'package:costeira/features/fazendas/domain/usecases/resolve_current_farm_id.dart';
import 'package:costeira/features/indicadores/infra/data/indicadores_datasource.dart';
import 'package:costeira/features/indicadores/presentation/indicadores_conteudo.dart';
import 'package:costeira/features/indicadores/presentation/indicadores_controller.dart';
import 'package:costeira/features/indicadores/presentation/web/indicadores_filter_web_dialog.dart';
import 'package:costeira/features/indicadores/presentation/widgets/indicador_ui.dart';
import 'package:costeira/features/potreiros/domain/usecases/get_potreiros_usecase.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:lucide_icons/lucide_icons.dart';

class IndicadoresWebPage extends StatefulWidget {
  const IndicadoresWebPage({super.key});

  @override
  State<IndicadoresWebPage> createState() => _IndicadoresWebPageState();
}

class _IndicadoresWebPageState extends State<IndicadoresWebPage> {
  late final IndicadoresController _controller;
  IndicadorModulo? _modulo;
  IndicadorId? _indicador;

  @override
  void initState() {
    super.initState();
    _controller = IndicadoresController(
      datasource: IndicadoresDatasource(Modular.get<ApiClient>()),
      getList: Modular.get<GetListUsecase>(),
      lotesUsecase: Modular.get<GetAnimalLotsUsecase>(),
      potreirosUsecase: Modular.get<GetPotreirosUsecase>(),
      fazenda: Modular.get<ResolveCurrentFarmId>(),
    );
    _controller.addListener(_refresh);
    _controller.preparar();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();
    super.dispose();
  }

  void _voltarInterno() {
    if (_indicador != null) {
      setState(() => _indicador = null);
      return;
    }
    if (_modulo != null) {
      setState(() => _modulo = null);
    }
  }

  Future<void> _recarregar() async {
    await _controller.carregar();
  }

  Future<void> _abrirFiltros() async {
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => IndicadoresFilterWebDialog(controller: _controller),
    );
  }

  void _abrirModulo(IndicadorModulo modulo) {
    if (!modulo.aberto) {
      AppSnackBar.show(
        context: context,
        message: 'Em desenvolvimento',
        isError: false,
      );
      return;
    }
    setState(() {
      _modulo = modulo;
      _indicador = null;
    });
  }

  void _abrirIndicador(IndicadorId id) {
    setState(() => _indicador = id);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF6F7F4),
      child: Column(
        children: [
          _toolbar(),
          const Divider(height: 1, color: Color(0xFFE7E4DD)),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _toolbar() {
    final nested = _modulo != null || _indicador != null;
    final caption = _indicador != null
        ? tituloIndicador(_indicador!)
        : _modulo?.titulo ?? 'Módulos de indicadores';
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;
        return ColoredBox(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              compact ? 16 : 28,
              compact ? 16 : 22,
              compact ? 16 : 28,
              compact ? 16 : 22,
            ),
            child: Row(
              children: [
                if (nested) ...[
                  IconButton(
                    tooltip: 'Voltar',
                    onPressed: _voltarInterno,
                    style: IconButton.styleFrom(
                      foregroundColor: const Color(0xFF313131),
                      backgroundColor: const Color(0xFFF0F2ED),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(LucideIcons.chevronLeft, size: 18),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: compact ? 16 : 19,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF252A27),
                        ),
                      ),
                      if (_indicador == null) ...[
                        const SizedBox(height: 3),
                        Text(
                          _modulo == null
                              ? 'Explore os resultados da fazenda por área de análise'
                              : _modulo!.subtitulo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF7B827D),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (_indicador != null) ...[
                  IconButton(
                    tooltip: 'Filtros',
                    onPressed: _controller.carregando ? null : _abrirFiltros,
                    style: IconButton.styleFrom(
                      foregroundColor: _controller.filtrosAtivos
                          ? MyColors.colorPrimary
                          : const Color(0xFF313131),
                      backgroundColor: _controller.filtrosAtivos
                          ? const Color(0x14128977)
                          : const Color(0xFFF0F2ED),
                      side: BorderSide(
                        color: _controller.filtrosAtivos
                            ? MyColors.colorPrimary
                            : Colors.transparent,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.tune_rounded, size: 18),
                  ),
                  const SizedBox(width: 8),
                ],
                IconButton(
                  tooltip: 'Atualizar',
                  onPressed: _controller.carregando ? null : _recarregar,
                  style: IconButton.styleFrom(
                    foregroundColor: MyColors.colorPrimary,
                    backgroundColor: const Color(0xFFF0F2ED),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: _controller.carregando
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(LucideIcons.refreshCw, size: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _body() {
    if (_indicador != null) {
      return _detalhe(_indicador!);
    }
    if (_modulo != null) {
      return _listaIndicadores(_modulo!);
    }
    return _listaModulos();
  }

  Widget _listaModulos() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;
        final columns = constraints.maxWidth >= 1280
            ? 4
            : constraints.maxWidth >= 960
            ? 3
            : 2;
        final padding = EdgeInsets.fromLTRB(
          wide ? 28 : 16,
          wide ? 28 : 20,
          wide ? 28 : 16,
          32,
        );
        if (!wide) {
          return ListView.separated(
            padding: padding,
            itemCount: indicadoresModulos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _ModuloCard(
              modulo: indicadoresModulos[index],
              onTap: () => _abrirModulo(indicadoresModulos[index]),
            ),
          );
        }
        return GridView.builder(
          padding: padding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            mainAxisExtent: 176,
          ),
          itemCount: indicadoresModulos.length,
          itemBuilder: (context, index) => _ModuloCard(
            modulo: indicadoresModulos[index],
            onTap: () => _abrirModulo(indicadoresModulos[index]),
          ),
        );
      },
    );
  }

  Widget _listaIndicadores(IndicadorModulo modulo) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;
        final columns = constraints.maxWidth >= 1280
            ? 4
            : constraints.maxWidth >= 960
            ? 3
            : 2;
        final padding = EdgeInsets.fromLTRB(
          wide ? 28 : 16,
          wide ? 28 : 20,
          wide ? 28 : 16,
          32,
        );
        if (!wide) {
          return ListView.separated(
            padding: padding,
            itemCount: modulo.itens.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = modulo.itens[index];
              return _IndicadorCard(
                id: item.$1,
                titulo: item.$2,
                onTap: () => _abrirIndicador(item.$1),
              );
            },
          );
        }
        return GridView.builder(
          padding: padding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            mainAxisExtent: 156,
          ),
          itemCount: modulo.itens.length,
          itemBuilder: (context, index) {
            final item = modulo.itens[index];
            return _IndicadorCard(
              id: item.$1,
              titulo: item.$2,
              onTap: () => _abrirIndicador(item.$1),
            );
          },
        );
      },
    );
  }

  Widget _detalhe(IndicadorId id) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 40),
          children: [
            if (_controller.carregando)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_controller.erro != null)
              CaixaNota(texto: _controller.erro!)
            else
              ...conteudoIndicador(id, _controller.lista),
          ],
        );
      },
    );
  }
}

class _ModuloCard extends StatelessWidget {
  const _ModuloCard({required this.modulo, required this.onTap});

  final IndicadorModulo modulo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = modulo.aberto
        ? MyColors.colorPrimary
        : const Color(0xFF7F8581);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        hoverColor: const Color(0x07128977),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: modulo.aberto
                  ? const Color(0xFFDCE5DE)
                  : const Color(0xFFE4E5E2),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A17251C),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _CardIcon(icon: _iconeModulo(modulo), enabled: modulo.aberto),
                  const Spacer(),
                  _StatusPill(enabled: modulo.aberto),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                modulo.titulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF252A27),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                modulo.subtitulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: subtituloLista,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      modulo.aberto
                          ? '${modulo.itens.length} indicadores disponíveis'
                          : 'Módulo em preparação',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: accent,
                      ),
                    ),
                  ),
                  Icon(
                    modulo.aberto ? LucideIcons.arrowUpRight : LucideIcons.lock,
                    size: 16,
                    color: accent,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IndicadorCard extends StatelessWidget {
  const _IndicadorCard({
    required this.id,
    required this.titulo,
    required this.onTap,
  });

  final IndicadorId id;
  final String titulo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        hoverColor: const Color(0x07128977),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFDCE5DE)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A17251C),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _CardIcon(icon: _iconeIndicador(id), enabled: true),
                  const Spacer(),
                  const Icon(
                    LucideIcons.arrowUpRight,
                    size: 16,
                    color: IndicadorCores.verde,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                titulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF252A27),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _descricaoIndicador(id),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: subtituloLista,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardIcon extends StatelessWidget {
  const _CardIcon({required this.icon, required this.enabled});

  final IconData icon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: enabled ? const Color(0x12128977) : const Color(0xFFF0F1EE),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        size: 18,
        color: enabled ? MyColors.colorPrimary : const Color(0xFF858A86),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: enabled ? const Color(0x10128977) : const Color(0xFFF0F1EE),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        enabled ? 'Disponível' : 'Em breve',
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: enabled ? MyColors.colorPrimary : const Color(0xFF7F8581),
        ),
      ),
    );
  }
}

IconData _iconeModulo(IndicadorModulo modulo) {
  switch (modulo.titulo) {
    case 'Produção e rebanho':
      return LucideIcons.beef;
    case 'Reprodução':
      return LucideIcons.heartPulse;
    case 'Desfrute e saídas':
      return LucideIcons.trendingUp;
    case 'Financeiro':
      return LucideIcons.wallet;
    default:
      return LucideIcons.barChart3;
  }
}

IconData _iconeIndicador(IndicadorId id) {
  switch (id) {
    case IndicadorId.gmdGlobal:
    case IndicadorId.gmdLote:
      return LucideIcons.trendingUp;
    case IndicadorId.kgProduzido:
      return LucideIcons.scale;
    case IndicadorId.lotacaoUa:
    case IndicadorId.lotacaoCab:
      return LucideIcons.map;
    case IndicadorId.rebanhoMedio:
      return LucideIcons.beef;
    case IndicadorId.areaMedia:
      return LucideIcons.areaChart;
    case IndicadorId.taxaDesfrute:
    case IndicadorId.taxaAbate:
    case IndicadorId.taxaGiro:
    case IndicadorId.mortalidade:
      return LucideIcons.percent;
  }
}

String _descricaoIndicador(IndicadorId id) {
  switch (id) {
    case IndicadorId.gmdGlobal:
      return 'Ganho médio diário consolidado';
    case IndicadorId.gmdLote:
      return 'Compare o desempenho dos lotes';
    case IndicadorId.kgProduzido:
      return 'Produção acumulada no período';
    case IndicadorId.lotacaoUa:
      return 'Unidades animais por hectare';
    case IndicadorId.lotacaoCab:
      return 'Cabeças por hectare utilizado';
    case IndicadorId.rebanhoMedio:
      return 'Média mensal do estoque animal';
    case IndicadorId.areaMedia:
      return 'Área produtiva média utilizada';
    case IndicadorId.taxaDesfrute:
      return 'Eficiência produtiva do rebanho';
    case IndicadorId.taxaAbate:
      return 'Peso vendido sobre o estoque';
    case IndicadorId.taxaGiro:
      return 'Rotatividade do rebanho';
    case IndicadorId.mortalidade:
      return 'Perdas sobre o estoque médio';
  }
}
