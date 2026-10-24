import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/common/get_list/domain/usecases/get_list_usecase.dart';
import 'package:costeira/features/animals/domain/usecases/get_animal_lots_usecase.dart';
import 'package:costeira/features/fazendas/domain/usecases/resolve_current_farm_id.dart';
import 'package:costeira/features/indicadores/infra/data/indicadores_datasource.dart';
import 'package:costeira/features/indicadores/presentation/indicadores_conteudo.dart';
import 'package:costeira/features/indicadores/presentation/indicadores_controller.dart';
import 'package:costeira/features/indicadores/presentation/widgets/indicador_ui.dart';
import 'package:costeira/features/potreiros/domain/usecases/get_potreiros_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

export 'package:costeira/features/indicadores/presentation/indicadores_conteudo.dart'
    show IndicadorId;

class IndicadoresPage extends StatefulWidget {
  const IndicadoresPage({super.key});

  @override
  State<IndicadoresPage> createState() => _IndicadoresPageState();
}

class _IndicadoresPageState extends State<IndicadoresPage> {
  late final IndicadoresController controller;
  IndicadorModulo? modulo;
  IndicadorId? indicador;

  @override
  void initState() {
    super.initState();
    controller = IndicadoresController(
      datasource: IndicadoresDatasource(Modular.get<ApiClient>()),
      getList: Modular.get<GetListUsecase>(),
      lotesUsecase: Modular.get<GetAnimalLotsUsecase>(),
      potreirosUsecase: Modular.get<GetPotreirosUsecase>(),
      fazenda: Modular.get<ResolveCurrentFarmId>(),
    );
    controller.addListener(_atualizar);
    controller.preparar();
  }

  void _atualizar() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    controller.removeListener(_atualizar);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titulo = indicador != null
        ? tituloIndicador(indicador!)
        : modulo?.titulo ?? 'Indicadores';
    return Scaffold(
      backgroundColor: IndicadorCores.fundo,
      appBar: AppBar(
        backgroundColor: IndicadorCores.fundo,
        foregroundColor: IndicadorCores.texto,
        elevation: 0,
        title: Text(titulo, style: tituloPagina),
        actions: [
          if (indicador != null) FiltrosIndicador(controller: controller),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (indicador != null) {
              setState(() => indicador = null);
              return;
            }
            if (modulo != null) {
              setState(() => modulo = null);
              return;
            }
            Modular.to.pop();
          },
        ),
      ),
      body: indicador != null
          ? _Detalhe(id: indicador!, controller: controller)
          : modulo != null
          ? _ListaModulo(
              modulo: modulo!,
              aoAbrir: (id) => setState(() => indicador = id),
            )
          : _ListaModulos(aoAbrir: (item) => setState(() => modulo = item)),
    );
  }
}

class _ListaModulos extends StatelessWidget {
  const _ListaModulos({required this.aoAbrir});

  final ValueChanged<IndicadorModulo> aoAbrir;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: paddingIndicadores(context),
      itemCount: indicadoresModulos.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final modulo = indicadoresModulos[index];
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: ListTile(
            title: Text(modulo.titulo, style: tituloLista),
            subtitle: Text(modulo.subtitulo, style: subtituloLista),
            trailing: Icon(
              modulo.aberto ? Icons.chevron_right : Icons.lock_outline,
              color: IndicadorCores.verde,
            ),
            onTap: modulo.aberto
                ? () => aoAbrir(modulo)
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Em desenvolvimento')),
                    );
                  },
          ),
        );
      },
    );
  }
}

class _ListaModulo extends StatelessWidget {
  const _ListaModulo({required this.modulo, required this.aoAbrir});

  final IndicadorModulo modulo;
  final ValueChanged<IndicadorId> aoAbrir;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: paddingIndicadores(context),
      itemCount: modulo.itens.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = modulo.itens[index];
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: ListTile(
            title: Text(item.$2, style: tituloLista),
            trailing: const Icon(Icons.chevron_right, color: IndicadorCores.verde),
            onTap: () => aoAbrir(item.$1),
          ),
        );
      },
    );
  }
}

class _Detalhe extends StatelessWidget {
  const _Detalhe({required this.id, required this.controller});

  final IndicadorId id;
  final IndicadoresController controller;

  @override
  Widget build(BuildContext context) {
    final lista = controller.lista;
    return ListView(
      padding: paddingIndicadores(context),
      children: [
        if (controller.carregando)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (controller.erro != null)
          CaixaNota(texto: controller.erro!)
        else
          ...conteudoIndicador(id, lista),
      ],
    );
  }
}
