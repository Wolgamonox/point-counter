

import 'package:flutter/material.dart';

class SimpleAddButton extends StatelessWidget {
  const SimpleAddButton(
      {super.key, required this.number, required this.addFunc});

  final int number;
  final Function(int number) addFunc;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FilledButton(
        onPressed: () {
          addFunc(number);
        },
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // <-- Radius
          ),
        ),
        child: Text(
          number.toString(),
          style: const TextStyle(
            fontSize: 32,
          ),
        ),
      ),
    );
  }
}