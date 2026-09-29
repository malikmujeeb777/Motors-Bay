import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../exports.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final Color? filledColor;
  final TextInputType textInputType;
  final String? Function(String?)? validator;
  final bool isValid;
  final bool isBorderRequired;
  final String? titleText;
  final int? maxline;
  final TextStyle? hintStyle;
  final TextStyle? titleStyle;
  final String? validateText;
  final bool? isShadowRequired;
  final Color? titleTextColor;
  final double? suffixWidth;
  final double? suffixHeight;
  final ValueChanged? onChanged;
  final GestureTapCallback? onTap;
  final bool? readOnly;
  final FocusNode? focusNode;
  final Color? hintTextColor;
  final double? height;
  final bool? isState;
  final String? labelText;
  final double? prefixWidth;
  final EdgeInsets? contentPadding;

  const AppTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.obscureText = false,
    required this.textInputType,
    this.suffixIcon,
    this.validator,
    this.prefixIcon,
    this.isValid = false,
    this.isBorderRequired = true,
    this.titleText = "",
    this.maxline = 1,
    this.labelText,
    this.validateText,
    this.isShadowRequired = false,
    this.titleTextColor,
    this.suffixWidth = 15,
    this.suffixHeight = 15,
    this.onChanged,
    this.contentPadding,
    this.onTap,
    this.readOnly,
    this.focusNode,
    this.hintTextColor,
    this.borderRadius,
    this.height,
    this.filledColor,
    this.hintStyle,
    this.isState,
    this.titleStyle,
    this.prefixWidth,
    this.enabled,
    this.style,
  });

  final double? borderRadius;
  final bool? enabled;
  final TextStyle? style;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}



class _AppTextFieldState extends State<AppTextField> {
  FocusNode? focusNode;
  String? Function(String?)? validator;
  bool isHide = false;
  @override
  void initState() {
    focusNode = widget.focusNode ?? FocusNode();
    validator = widget.validator ??
        (widget.validateText != null
            ? (v) => Validate.emptyCheck(v, widget.validateText)
            : null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1),
      ),
      child: TextFormField(
        onTap: widget.onTap,
        readOnly: widget.readOnly ?? false,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        // stylusHandwritingEnabled: true,
        focusNode: focusNode,
        enabled: widget.enabled,
        onTapOutside: (v) {
          focusNode?.unfocus();
        },
        textInputAction: TextInputAction.done,
        validator: validator,
        onChanged: widget.onChanged,
        keyboardType: widget.textInputType,
        obscureText: widget.isState != null ? !isHide : widget.obscureText,
        controller: widget.controller,
        maxLines: widget.maxline,
        style: widget.style ??
            themeData.textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.tertiary,
            ),
        cursorColor: themeData.colorScheme.primary,
        decoration: InputDecoration(
          hintText: widget.hintText,
          helperStyle: widget.hintStyle ?? themeData.textTheme.bodySmall,
          hintStyle: themeData.textTheme.bodyMedium!.copyWith(
            color: Theme.of(context).colorScheme.tertiary,
          ),
          prefixIcon: widget.prefixIcon,

          suffixIcon: widget.isState != null
              ? InkWell(
            onTap: () {
              //isHide=true;
              if (isHide == true) {
                isHide = false;
              } else {
                isHide = true;
              }
              setState(() {});
            },
            child: SizedBox(
              width: widget.suffixWidth ?? 20.w,
              height: widget.suffixHeight ?? 20.h,
              child: Center(
                child: SvgPicture.asset(
                  !isHide
                      ? 'assets/Icons/hideIcon.svg'
                      : 'assets/Icons/show_pass.svg',
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ),
          )
              : widget.suffixIcon != null
              ? Container(
            padding: const EdgeInsetsDirectional.only(end: 2.0),
            width: widget.suffixWidth ?? 20.w,
            height: widget.suffixHeight ?? 20.h,
            child: widget.suffixIcon,
          )
              : null,

          isDense: false,
          labelText: widget.labelText,
          labelStyle: themeData.textTheme.labelMedium,
          alignLabelWithHint: true,

          ///changess
          contentPadding: widget.contentPadding ??
              const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 12,
              ),

          // Border customization
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8), // Change this for rounded corners
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline, // Change color to your preferred border color
              width: 1.0, // Border width
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8), // Rounded corners when enabled
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline, // Border color when not focused
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8), // Rounded corners when focused
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary, // Border color when focused
              width: 2.0, // A thicker border when focused
            ),
          ),
        ),
      )

    );
  }
}


class ChatTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final Color? filledColor;
  final TextInputType textInputType;
  final String? Function(String?)? validator;
  final bool isValid;
  final bool isBorderRequired;
  final String? titleText;
  final int? maxline;
  final TextStyle? hintStyle;
  final TextStyle? titleStyle;
  final String? validateText;
  final bool? isShadowRequired;
  final Color? titleTextColor;
  final double? suffixWidth;
  final double? suffixHeight;
  final ValueChanged? onChanged;
  final GestureTapCallback? onTap;
  final bool? readOnly;
  final FocusNode? focusNode;
  final Color? hintTextColor;
  final double? height;
  final bool? isState;
  final String? labelText;
  final double? prefixWidth;
  final EdgeInsets? contentPadding;

  const ChatTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.obscureText = false,
    required this.textInputType,
    this.suffixIcon,
    this.validator,
    this.prefixIcon,
    this.isValid = false,
    this.isBorderRequired = true,
    this.titleText = "",
    this.maxline = 1,
    this.labelText,
    this.validateText,
    this.isShadowRequired = false,
    this.titleTextColor,
    this.suffixWidth = 15,
    this.suffixHeight = 15,
    this.onChanged,
    this.contentPadding,
    this.onTap,
    this.readOnly,
    this.focusNode,
    this.hintTextColor,
    this.borderRadius,
    this.height,
    this.filledColor,
    this.hintStyle,
    this.isState,
    this.titleStyle,
    this.prefixWidth,
    this.enabled,
    this.style,
  });

  final double? borderRadius;
  final bool? enabled;
  final TextStyle? style;

  @override
  State<ChatTextField> createState() => _ChatTextFieldState();
}



class _ChatTextFieldState extends State<ChatTextField> {
  FocusNode? focusNode;
  String? Function(String?)? validator;
  bool isHide = false;
  @override
  void initState() {
    focusNode = widget.focusNode ?? FocusNode();
    validator = widget.validator ??
        (widget.validateText != null
            ? (v) => Validate.emptyCheck(v, widget.validateText)
            : null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Theme(
      data: ThemeData(


      ),
      child: TextFormField(
        onTap: widget.onTap,
        readOnly: widget.readOnly ?? false,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        scribbleEnabled: false,
        focusNode: focusNode,
        enabled: widget.enabled,
        onTapOutside: (v) {
          focusNode?.unfocus();
        },
        textInputAction: TextInputAction.done,
        validator: validator,
        onChanged: widget.onChanged,
        keyboardType: widget.textInputType,
        obscureText: widget.isState != null ? !isHide : widget.obscureText,
        controller: widget.controller,
        maxLines: widget.maxline,
        style: widget.style ??
            themeData.textTheme.bodyMedium!.copyWith(
              color: themeData.colorScheme.tertiary,
            ),
        cursorColor: themeData.colorScheme.primary,
        decoration:  InputDecoration(
          hintText: widget.hintText,
          filled: false,
          border: const OutlineInputBorder(
              borderSide: BorderSide.none
          ),
          helperStyle: widget.hintStyle ?? themeData.textTheme.bodySmall,
          hintStyle: themeData.textTheme.bodyMedium!.copyWith(
            color: themeData.colorScheme.tertiary,
          ),
          prefixIcon: widget.prefixIcon,

          suffixIcon: widget.isState != null
              ? InkWell(
            onTap: () {
              //isHide=true;
              if (isHide == true) {
                isHide = false;
              } else {
                isHide = true;
              }
              setState(() {});
            },
            child: SizedBox(
              width: widget.suffixWidth ?? 20.w,
              height: widget.suffixHeight ?? 20.h,
              child: Center(
                child: SvgPicture.asset(
                  !isHide
                      ? "assets/Icons/hideIcon"
                      : 'assets/Icons/show_pass.svg',
                  color: themeData.colorScheme.tertiary,
                ),
              ),
            ),
          )
              : widget.suffixIcon != null
              ? Container(
            padding: const EdgeInsetsDirectional.only(end: 2.0),
            width: widget.suffixWidth ?? 20.w,
            height: widget.suffixHeight ?? 20.h,
            child: widget.suffixIcon,
          )
              : null,

          isDense: false,

          labelText: widget.labelText,
          labelStyle: themeData.textTheme.labelMedium,
          alignLabelWithHint: true,

          ///changess
          contentPadding: widget.contentPadding ??
              const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 12,
              ),
        ),
      ),
    );
  }
}
