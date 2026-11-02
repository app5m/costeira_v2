import 'package:uuid/uuid.dart';

class ChaveIdempotencia {
  const ChaveIdempotencia._();

  static const teto = 64;
  static const tetoApi = 160;

  static const acoes = {
    'criar',
    'confirmar',
    'baixa',
    'editar',
    'estornar',
    'estornar-baixa',
    'conta',
    'saldo',
    'inativar',
    'excluir',
    'parte',
    'parceria',
    'entrada',
    'venda',
    'apuracao',
  };

  static final _uuid = Uuid();

  static String nova(String acao) => montar(_uuid.v4(), acao);

  static ({String uuid, String criar, String confirmar, String baixa}) loteSalvar() {
    final uuid = _uuid.v4();
    return (
      uuid: uuid,
      criar: montar(uuid, 'criar'),
      confirmar: montar(uuid, 'confirmar'),
      baixa: montar(uuid, 'baixa'),
    );
  }

  static String montar(String uuid, String acao) {
    if (!acoes.contains(acao)) {
      throw ArgumentError('Ação de chave não prevista: $acao');
    }
    final chave = '$uuid-$acao';
    if (chave.length > teto || chave.length > tetoApi) {
      throw ArgumentError('chave_idempotencia com ${chave.length} caracteres');
    }
    return chave;
  }
}
