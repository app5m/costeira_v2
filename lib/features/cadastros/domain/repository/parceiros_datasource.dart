import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/cadastros/domain/entities/delete_parceiro_entity.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_filter_entity.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_list_entity.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_upsert_entity.dart';

abstract interface class ParceirosDatasource {
  Future<ParceiroListEntity> getParceiros(ParceiroFilterEntity filter);
  Future<ApiMessage> createParceiro(ParceiroUpsertEntity parceiro);
  Future<ApiMessage> updateParceiro(ParceiroUpsertEntity parceiro);
  Future<ApiMessage> deleteParceiro(DeleteParceiroEntity parceiro);
}
