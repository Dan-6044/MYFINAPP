import 'package:flutter/material.dart';

class MyfinFooter extends StatelessWidget {
  const MyfinFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Powered by MDM Solutions',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12,
        color: Color(0xFF4A90E2),
        letterSpacing: 0.4,
      ),
    );
  }
}
