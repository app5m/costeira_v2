import 'package:costeira/core/config/ws_constantes.dart';

enum ParceiroKind {
  fornecedor,
  comprador;

  String get title =>
      this == ParceiroKind.fornecedor ? 'Fornecedores' : 'Compradores';

  String get singular =>
      this == ParceiroKind.fornecedor ? 'Fornecedor' : 'Comprador';

  String get listPath => this == ParceiroKind.fornecedor
      ? WSConstantes.fornecedoresListar
      : WSConstantes.compradoresListar;

  String get savePath => this == ParceiroKind.fornecedor
      ? WSConstantes.fornecedoresAdicionar
      : WSConstantes.compradoresAdicionar;

  String get deletePath => this == ParceiroKind.fornecedor
      ? WSConstantes.fornecedoresExcluir
      : WSConstantes.compradoresExcluir;
}
