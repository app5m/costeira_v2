import 'package:costeira/features/movimentacoes/domain/entities/aborto_charts_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/abigeato_charts_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/compra_charts_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/consumo_charts_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/morte_charts_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_charts_filter_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_filter_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacoes_list_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/nascimento_charts_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/troca_categoria_charts_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/transferencia_charts_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/venda_charts_entity.dart';

abstract interface class MovimentacoesDatasource {
  Future<MovimentacoesListEntity> getMovimentacoes(
    MovimentacaoFilterEntity filter,
  );
  Future<CompraChartsEntity> getCompraCharts(
    MovimentacaoChartsFilterEntity filter,
  );
  Future<VendaChartsEntity> getVendaCharts(
    MovimentacaoChartsFilterEntity filter,
  );
  Future<MorteChartsEntity> getMorteCharts(
    MovimentacaoChartsFilterEntity filter,
  );
  Future<NascimentoChartsEntity> getNascimentoCharts(
    MovimentacaoChartsFilterEntity filter,
  );
  Future<TrocaCategoriaChartsEntity> getTrocaCategoriaCharts(
    MovimentacaoChartsFilterEntity filter,
  );
  Future<AbigeatoChartsEntity> getAbigeatoCharts(
    MovimentacaoChartsFilterEntity filter,
  );
  Future<AbortoChartsEntity> getAbortoCharts(
    MovimentacaoChartsFilterEntity filter,
  );
  Future<ConsumoChartsEntity> getConsumoCharts(
    MovimentacaoChartsFilterEntity filter,
  );
  Future<TransferenciaChartsEntity> getTransferenciaCharts(
    MovimentacaoChartsFilterEntity filter,
  );
}
