import 'package:flutter/material.dart';

class AppTextStyles {

  AppTextStyles._();
  static final  AppTextStyles _instance = AppTextStyles._();
  static AppTextStyles get instance => _instance;


  static TextStyle bold({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    required String locale,
  }) {
    return TextStyle(
        fontSize: fontSize ?? 15,
        letterSpacing: letterSpacing ?? 0,
        color: color,
        fontFamily: locale == 'en' ? 'Artico Bold' : 'Bhaijaan Bold',
        fontWeight: fontWeight ?? FontWeight.bold);
  }

  //
  static TextStyle medium({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    required String locale,
  }) {
    return TextStyle(
        fontSize: fontSize ?? 14,
        letterSpacing: letterSpacing ?? 0,
        color: color,
        fontFamily: locale == 'en' ? 'Artico Medium' : 'Bhaijaan Medium',
        fontWeight: fontWeight ?? FontWeight.w500);
  }

  //
  static TextStyle regular({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    required String locale,
  }) {
    return TextStyle(
        fontSize: fontSize ?? 13,
        letterSpacing: letterSpacing ?? 0,
        color: color,
        fontFamily: locale == 'en' ? 'Artico Regular' : 'Bhaijaan Regular',
        fontWeight: fontWeight ?? FontWeight.normal);
  }

//
  static TextStyle light({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    required String locale,
  }) {
    return TextStyle(
        fontSize: fontSize ?? 11,
        letterSpacing: letterSpacing ?? 0,
        color: color,
        fontFamily: locale == 'en' ? 'Artico Regular' : 'Bhaijaan Regular',
        fontWeight: fontWeight ?? FontWeight.w300);
  }
}
