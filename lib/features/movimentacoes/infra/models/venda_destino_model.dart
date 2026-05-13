import 'package:costeira/features/movimentacoes/infra/models/movimentacao_reference_model.dart';
import 'package:costeira/features/movimentacoes/vendas/domain/entities/venda_destino_entity.dart';

class VendaDestinoModel extends VendaDestinoEntity {
  const VendaDestinoModel({
    super.id,
    super.appMovimentacoesId,
    required super.destino,
    required super.tipo,
    super.data,
    super.destinoReference,
  });

  factory VendaDestinoModel.fromJson(Map<String, dynamic> json) {
    final destinoRef = MovimentacaoReferenceModel.maybeFromJson(
      json['destino'],
    );

    return VendaDestinoModel(
      id: int.tryParse(json['id']?.toString() ?? ''),
      appMovimentacoesId: int.tryParse(
        json['app_movimentacoes_id']?.toString() ?? '',
      ),
      destino:
          destinoRef?.id ??
          int.tryParse(json['destino']?.toString() ?? '') ??
          0,
      tipo: json['tipo']?.toString() ?? '',
      data: json['data']?.toString(),
      destinoReference: destinoRef,
    );
  }
}
