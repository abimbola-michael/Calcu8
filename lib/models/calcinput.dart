// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class CalcInput {
  String input;
  IconData? icon;
  CalcInput({required this.input, this.icon});

  @override
  String toString() => 'CalcInput(input: $input, icon: $icon)';
}
