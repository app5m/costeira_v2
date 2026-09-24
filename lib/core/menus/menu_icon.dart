import 'package:costeira/core/common/get_list/domain/entities/app_menu_entity.dart';
import 'package:costeira/core/menus/menu_icon_resolver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MenuIcon extends StatelessWidget {
  const MenuIcon({super.key, this.item, this.icon, this.size = 22, this.color});

  final AppMenuEntity? item;
  final String? icon;
  final double size;
  final Color? color;

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
    final url = MenuIconResolver.resolveUrl(icon ?? item?.icon);
    if (url == null) {
      return const SizedBox.shrink();
    }

    final empty = SizedBox(width: size, height: size);
    final filter = color == null
        ? null
        : ColorFilter.mode(color!, BlendMode.srcIn);

    if (MenuIconResolver.isSvg(url)) {
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
}
