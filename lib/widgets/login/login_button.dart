import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color? color;
  final String label;

  const LoginButton({
    Key? key,
    required this.onPressed,
    this.color,
    this.label = 'LOG IN',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Colors.amber[600],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
