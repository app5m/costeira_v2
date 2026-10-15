import 'package:costeira/core/common/get_list/domain/entities/app_menu_entity.dart';
import 'package:costeira/core/menus/menu_icon_resolver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MenuIcon extends StatelessWidget {
  const MenuIcon({super.key, this.item, this.icon, this.size = 22, this.color});

  final AppMenuEntity? item;
  final String? icon;
  final double size;
  final Color? color;

  static const _webIconFiles = <String>{
    'abigeato.svg',
    'aborto.svg',
    'animais.svg',
    'baixa_estoque.svg',
    'compra.svg',
    'compradores.svg',
    'consumo.svg',
    'dashboard.svg',
    'entrada.svg',
    'estoque.svg',
    'fazendas.svg',
    'financeiro.svg',
    'fornecedores.svg',
    'indicadores.svg',
    'manejo.svg',
    'manejo_animal.svg',
    'manejo_campo.svg',
    'manejo_reprodutivo.svg',
    'manejos.svg',
    'morte.svg',
    'movimentacao_de_piquete.svg',
    'movimentacoes.svg',
    'nascimento.svg',
    'parto.svg',
    'perfil.svg',
    'pluviosidade.svg',
    'potreiros.svg',
    'relatorios.svg',
    'saida.svg',
    'sanitario.svg',
    'suplementacao.svg',
    'tarefas.svg',
    'transferencia_enviada.svg',
    'transferencia_recebida.svg',
    'troca_de_categoria.svg',
    'usuarios.svg',
    'venda.svg',
  };

  static const _webIconAliases = <String, String>{
    'abortos.svg': 'aborto.svg',
    'compras.svg': 'compra.svg',
    'mortes.svg': 'morte.svg',
    'nascimentos.svg': 'nascimento.svg',
    'trocas_categoria.svg': 'troca_de_categoria.svg',
    'transferencias.svg': 'transferencia_enviada.svg',
    'vendas.svg': 'venda.svg',
  };

  static Widget? maybe({
    AppMenuEntity? item,
    String? icon,
    double size = 22,
    Color? color,
  }) {
    if (MenuIconResolver.resolveUrl(icon ?? item?.icon) == null) {
      return null;
    }
    return MenuIcon(item: item, icon: icon, size: size, color: color);
  }

  @override
  Widget build(BuildContext context) {
    final rawIcon = icon ?? item?.icon;
    final url = MenuIconResolver.resolveUrl(rawIcon);
    if (url == null) {
      return const SizedBox.shrink();
    }

    final empty = SizedBox(width: size, height: size);
    final filter = color == null
        ? null
        : ColorFilter.mode(color!, BlendMode.srcIn);

    if (MenuIconResolver.isSvg(url)) {
      final webAsset = kIsWeb ? _webAssetFor(rawIcon) : null;
      if (webAsset != null) {
        return SvgPicture.asset(
          webAsset,
          width: size,
          height: size,
          colorFilter: filter,
        );
      }
      return SvgPicture.network(
        url,
        width: size,
        height: size,
        colorFilter: filter,
        placeholderBuilder: (_) => empty,
      );
    }

    return Image.network(
      url,
      width: size,
      height: size,
      color: color,
      colorBlendMode: color == null ? null : BlendMode.srcIn,
      errorBuilder: (_, __, ___) => empty,
    );
  }

  String? _webAssetFor(String? raw) {
    var value = raw?.trim() ?? '';
    if (value.isEmpty || value == 'null') {
      return null;
    }
    final uri = Uri.tryParse(value);
    if (uri != null && uri.pathSegments.isNotEmpty) {
      value = uri.pathSegments.last;
    } else {
      value = value.split('/').last;
    }
    value = value.split('?').first.toLowerCase();
    if (!value.contains('.')) {
      value = '$value.svg';
    }
    value = _webIconAliases[value] ?? value;
    if (!_webIconFiles.contains(value)) {
      return null;
    }
    return 'docs/icons-backend/$value';
  }
}
