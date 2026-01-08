import 'package:flutter/material.dart';

class ForUMHubLogo extends StatelessWidget {
  const ForUMHubLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/frontlogo.png',
      height: 200, // Reduced size to prevent overflow
      width: 200,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback if image is missing
        return const Column(
          children: [
            Icon(Icons.school, size: 80, color: Color(0xFF8D2C2C)),
            Text(
              'ForUMhub',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8D2C2C),
              ),
            ),
          ],
        );
      },
    );
  }
}
