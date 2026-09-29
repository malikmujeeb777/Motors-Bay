import 'package:flutter/material.dart';

class AppText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final int? maxLine;
  final VoidCallback? onTap;

  const AppText(
      this.text, {
        super.key,
        this.style,
        this.overflow,
        this.maxLine,
        this.onTap,
        this.textAlign = TextAlign.start,
      });

  @override
  State<AppText> createState() => _AppTextState();
}

class _AppTextState extends State<AppText> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Text(
        widget.text,
        maxLines: widget.maxLine,
        textAlign: widget.textAlign,
        //locale: Locale('ur'),
        textScaler: const TextScaler.linear(1),
        overflow: widget.overflow ?? TextOverflow.ellipsis,
        style: widget.style),
    );
  }
}