import 'package:flutter/material.dart';

class AppWidget {
  static TextStyle headlineTextStyle(double fontSize) {
    return TextStyle(
      color: Color(0xff3d2846),
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle lightTextStyle(double fontSize) {
    return TextStyle(
      color: Colors.grey[600],
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle semiBoldTextStyle(double fontSize) {
    return TextStyle(
      color: Color(0xff3d2846),
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle boldTextStyle(double fontSize) {
    return TextStyle(
      color: Color(0xff3d2846),
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
    );
  }
}