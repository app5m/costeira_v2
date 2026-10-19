import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/common/get_list/domain/entities/get_list_params_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/list_category_entity.dart';
import 'package:costeira/core/common/get_list/domain/usecases/get_list_usecase.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/storage/sub_user_payload.dart';
import 'package:costeira/features/animals/domain/entities/animal_lot_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_lots_filter_entity.dart';
import 'package:costeira/features/animals/domain/usecases/get_animal_lots_usecase.dart';
import 'package:costeira/features/dashboard/domain/entities/dashboard_filter_entity.dart';
import 'package:costeira/features/fazendas/domain/usecases/resolve_current_farm_id.dart';
import 'package:costeira/features/indicadores/domain/indicadores_lista.dart';
import 'package:costeira/features/indicadores/infra/data/indicadores_datasource.dart';
import 'package:costeira/features/indicadores/infra/models/indicadores_request_model.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiro_entity.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiros_filter_entity.dart';
import 'package:costeira/features/potreiros/domain/usecases/get_potreiros_usecase.dart';
import 'package:flutter/foundation.dart';

enum TipoPeriodoIndicador { todo, anoAgricola, ultimosDias, personalizado }

class IndicadoresController extends ChangeNotifier {
  IndicadoresController({
    required IndicadoresDatasource datasource,
    required GetListUsecase getList,
    required GetAnimalLotsUsecase lotesUsecase,
    required GetPotreirosUsecase potreirosUsecase,
    required ResolveCurrentFarmId fazenda,
  }) : _datasource = datasource,
       _getList = getList,
       _lotesUsecase = lotesUsecase,
       _potreirosUsecase = potreirosUsecase,
       _fazenda = fazenda;

  final IndicadoresDatasource _datasource;
  final GetListUsecase _getList;
  final GetAnimalLotsUsecase _lotesUsecase;
  final GetPotreirosUsecase _potreirosUsecase;
  final ResolveCurrentFarmId _fazenda;

  bool carregando = false;
  String? erro;
  IndicadoresLista lista = IndicadoresLista.vazia;
  TipoPeriodoIndicador periodo = TipoPeriodoIndicador.anoAgricola;
  int? loteId;
  int? categoriaId;
  int? piqueteId;
  int ultimosDias = 30;
  DateTime? dataDe;
  DateTime? dataAte;
  List<AgriculturalYearRange> anos = const [];
  AgriculturalYearRange? anoAtual;
  List<AnimalLotEntity> lotes = const [];
  List<ListCategoryEntity> categorias = const [];
  List<PotreiroEntity> piquetes = const [];

  String get rotuloPeriodo {
    switch (periodo) {
      case TipoPeriodoIndicador.todo:
        return 'Todo o período';
      case TipoPeriodoIndicador.anoAgricola:
        return 'Ano agrícola atual';
      case TipoPeriodoIndicador.ultimosDias:
        return 'Últimos $ultimosDias dias';
      case TipoPeriodoIndicador.personalizado:
        return 'Personalizado';
    }
  }

  Future<void> preparar() async {
    final sessao = await SessionStorage.getUserSession();
    if (sessao == null || sessao.id <= 0) {
      erro = 'Usuário não autenticado.';
      notifyListeners();
      return;
    }
    final userId = sessionAccountUserId(sessao.id);
    final fazendaId = await _fazenda(userId: userId);
    try {
      final listas = await _getList(GetListParamsEntity(sexo: 1, userId: userId));
      anos = listas.anosAgricolas;
      anoAtual = _anoDeHoje(anos);
      categorias = listas.animaisCategorias;
    } catch (_) {}
    if (fazendaId != null) {
      try {
        final lotesLista = await _lotesUsecase(
          AnimalLotsFilterEntity(appUsersId: userId, appFazendasId: fazendaId),
        );
        lotes = lotesLista.data;
      } catch (_) {}
      try {
        final piquetesLista = await _potreirosUsecase(
          PotreirosFilterEntity(appUsersId: userId, appFazendasId: fazendaId),
        );
        piquetes = piquetesLista.data;
      } catch (_) {}
    }
    notifyListeners();
    await carregar();
  }

  Future<void> carregar() async {
    carregando = true;
    erro = null;
    notifyListeners();
    try {
      final sessao = await SessionStorage.getUserSession();
      if (sessao == null || sessao.id <= 0) {
        throw ApiException('Usuário não autenticado.');
      }
      final userId = sessionAccountUserId(sessao.id);
      final fazendaId = await _fazenda(userId: userId);
      if (fazendaId == null || fazendaId <= 0) {
        throw ApiException('Selecione uma fazenda.');
      }
      final datas = _datas();
      lista = await _datasource.listar(
        IndicadoresRequestModel(
          appUsersId: userId,
          appFazendasId: fazendaId,
          appAnimaisLotesId: loteId,
          appAnimaisCategoriasId: categoriaId,
          appPotreirosId: piqueteId,
          idAnoAgricola: datas.$1,
          dataIn: datas.$2,
          dataOut: datas.$3,
        ),
      );
    } on ApiException catch (error) {
      erro = error.message;
    } catch (_) {
      erro = 'Não foi possível carregar os indicadores.';
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  void setPeriodo(TipoPeriodoIndicador valor) {
    periodo = valor;
    if (valor == TipoPeriodoIndicador.personalizado) {
      final hoje = DateTime.now();
      dataDe ??= DateTime(hoje.year, hoje.month, 1);
      dataAte ??= hoje;
      notifyListeners();
      return;
    }
    notifyListeners();
    carregar();
  }

  void setUltimosDias(int dias) {
    if (dias <= 0) {
      return;
    }
    ultimosDias = dias;
    notifyListeners();
  }

  void setDatas(DateTime? de, DateTime? ate) {
    dataDe = de;
    dataAte = ate;
    notifyListeners();
  }

  void setLote(int? id) {
    loteId = id;
    carregar();
  }

  void setCategoria(int? id) {
    categoriaId = id;
    carregar();
  }

  void setPiquete(int? id) {
    piqueteId = id;
    carregar();
  }

  (int?, String?, String?) _datas() {
    switch (periodo) {
      case TipoPeriodoIndicador.todo:
        return (null, null, null);
      case TipoPeriodoIndicador.anoAgricola:
        final ano = anoAtual;
        if (ano == null) {
          return (null, null, null);
        }
        return (ano.id, _dataBr(ano.dataIn), _dataBr(ano.dataOut));
      case TipoPeriodoIndicador.ultimosDias:
        final hoje = DateTime.now();
        final inicio = hoje.subtract(Duration(days: ultimosDias));
        return (null, _dataBr(inicio), _dataBr(hoje));
      case TipoPeriodoIndicador.personalizado:
        if (dataDe == null || dataAte == null) {
          return (null, null, null);
        }
        return (null, _dataBr(dataDe!), _dataBr(dataAte!));
    }
  }

  static AgriculturalYearRange? _anoDeHoje(List<AgriculturalYearRange> anos) {
    final hoje = DateTime.now();
    for (final ano in anos) {
      if (!hoje.isBefore(ano.dataIn) && !hoje.isAfter(ano.dataOut)) {
        return ano;
      }
    }
    return anos.isEmpty ? null : anos.last;
  }

  static String formatar(DateTime data) => _dataBr(data);

  static String _dataBr(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }
}
