import 'package:flutter/material.dart';
import 'package:ForUMHUB/widgets/forgot_password/forgot_password_header.dart';
import 'package:ForUMHUB/widgets/login/login_text_field.dart';
import 'package:ForUMHUB/widgets/login/login_button.dart';
import 'package:ForUMHUB/services/auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleNext() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email')),
      );
      return;
    }
    if (!email.endsWith('@umindanao.edu.ph')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please use a valid @umindanao.edu.ph email')),
      );
      return;
    }
    try {
      final error = await _authService.sendPasswordResetEmail(email);
      if (!mounted) return;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent. Please check your inbox.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ForgotPasswordHeader(),
              const SizedBox(height: 60),
              LoginTextField(
                controller: _emailController,
                hintText: '@umindanao.edu.ph',
                icon: Icons.email_outlined,
                isPassword: false,
              ),
              const SizedBox(height: 24),
              LoginButton(
                onPressed: _handleNext,
                label: 'NEXT',
                color: const Color(0xFFBD2C15), // Deep red color from image
              ),
            ],
          ),
        ),
      ),
    );
  }
}
