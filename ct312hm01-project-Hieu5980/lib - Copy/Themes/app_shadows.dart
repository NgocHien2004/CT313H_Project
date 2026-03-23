import 'package:flutter/material.dart';

class AppShadows {
  static const soft = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.08),
      blurRadius: 15,
      offset: Offset(0, 2),
    ),
  ];

  static const card = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.25),
      blurRadius: 50,
      offset: Offset(0, 25),
    ),
  ];

  static const hover = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.35),
      blurRadius: 50,
      offset: Offset(0, 25),
    ),
  ];
}
