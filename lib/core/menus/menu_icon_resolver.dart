import 'package:costeira/core/config/ws_constantes.dart';

class MenuIconResolver {
  const MenuIconResolver._();

  static String? resolveUrl(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty || value == 'null') {
      return null;
    }
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    if (value.startsWith('/')) {
      return '${Uri.parse(WSConstantes.urlBase).origin}$value';
    }
    final file = value.contains('.') ? value : '$value.svg';
    return '${WSConstantes.menuIconsBase}/$file';
  }

  static bool isSvg(String url) {
    final path = url.split('?').first.toLowerCase();
    return path.endsWith('.svg');
  }
}
