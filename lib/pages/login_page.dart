import 'package:flutter/material.dart';
import 'package:ForUMHUB/widgets/login/forumhub_logo.dart';
import 'package:ForUMHUB/widgets/login/login_text_field.dart';
import 'package:ForUMHUB/widgets/login/login_button.dart';
import 'package:ForUMHUB/widgets/login/login_footer_links.dart';
import 'package:ForUMHUB/pages/create_account_page.dart';
import 'package:ForUMHUB/pages/forgot_password_page.dart';
import 'package:ForUMHUB/pages/home_page.dart';
import 'package:ForUMHUB/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  AuthService? _auth;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const ForUMHubLogo(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                LoginTextField(
                  controller: _emailController,
                  hintText: '@umindanao.edu.ph',
                  icon: Icons.email_outlined,
                  isPassword: false,
                ),
                const SizedBox(height: 16),
                LoginTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  icon: Icons.lock_outlined,
                  isPassword: true,
                ),
                const SizedBox(height: 24),
                LoginButton(
                  onPressed: _handleLogin,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(height: 20),
                LoginFooterLinks(
                  onCreateAccount: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateAccountPage(),
                      ),
                    );
                  },
                  onForgotPassword: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Please fill in all fields');
      return;
    }

    final auth = _auth ??= AuthService();
    dynamic result = await auth.signIn(email, password);

    if (!mounted) return;

    if (result == null) {
      _showSnackBar('Invalid credentials');
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
