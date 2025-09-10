import 'package:flutter/material.dart';

class Ownbutton extends StatelessWidget {
  const Ownbutton(
      {super.key,
      required this.title,
      required this.onTap,
      required this.width});

  final String title;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[900],
              foregroundColor: Colors.white,
              shape: BeveledRectangleBorder(
                  borderRadius: BorderRadius.circular(5))),
          onPressed: onTap,
          child: Text(title, style: const TextStyle(fontSize: 18))),
    );
  }
}
