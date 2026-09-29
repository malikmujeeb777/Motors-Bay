import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DynamicAppIconHandler {
  static Widget buildIcon({
    required BuildContext context,
    IconData? icon,
    String? svg,
    double? iconHeight,
    double? iconWidth,
    EdgeInsetsGeometry margins = EdgeInsets.zero,
    Color? iconColor,
  }) {
    if (svg != null) {
      return Padding(
        padding: margins,
        child: SvgPicture.asset(
          svg,
          height: iconHeight,
          width: iconWidth,
          fit: BoxFit.scaleDown,
          color: iconColor,
        ),
      );
    } else if (icon != null) {
      return Padding(
        padding: margins,
        child: Icon(
          icon,
          color: iconColor ?? Theme.of(context).colorScheme.surface,
          size: iconHeight,
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
