import 'package:flutter/material.dart';

class ButtonsMaterial extends StatelessWidget {
  final Function()? onTap;
  final String text;
  const ButtonsMaterial({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(25),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 157, 224, 245),
            borderRadius: BorderRadius.circular(8)),
        child: Center(
          child: Text(
            text,
            style:  const TextStyle(
                color: Color.fromARGB(255, 115, 116, 117),
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
        ),
      ),
    );
  }
}
