import 'package:flutter/material.dart';

class Serie {
  int reps;
  int kg;
  String tipo;
  bool? check;
  TextEditingController? repsController;
  TextEditingController? pesoController;

  Serie({
    required this.reps,
    required this.kg,
    required this.tipo,
    this.check,
    this.repsController,
    this.pesoController,
  });
}
