import 'package:flutter/material.dart';
import 'package:ForUMHUB/widgets/login/login_text_field.dart';
import 'package:ForUMHUB/widgets/login/login_button.dart';
import 'package:ForUMHUB/services/auth_service.dart';
import 'package:ForUMHUB/utils/course_constants.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final AuthService _auth = AuthService();
  // 1. Controllers & State
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  
  String? _selectedCourse;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // 2. Logic Methods
  void _handleCreateAccount() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showSnackBar('Please fill in all fields');
      return;
    }

    if (!email.endsWith('@umindanao.edu.ph')) {
      _showSnackBar('Please use a valid @umindanao.edu.ph email');
      return;
    }

    if (password != confirm) {
      _showSnackBar('Passwords do not match');
      return;
    }

    dynamic result = await _auth.register(email, password, name, _selectedCourse ?? '');

    if (!mounted) return;

    if (result == null) {
      _showSnackBar('Error creating account');
    } else {
      _showSnackBar('Account created successfully');
      Navigator.pop(context);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // 3. Main Build Method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                _buildSubHeader(),
                const SizedBox(height: 32),
                _buildCourseDropdown(),
                const SizedBox(height: 16),
                _buildInputFields(),
                const SizedBox(height: 32),
                _buildSubmitButton(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 4. Extracted UI Components (Private Methods)
  
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Create Account',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(
            children: [
              Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.primary, size: 20),
              const SizedBox(width: 4),
              Text(
                'Back',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubHeader() {
    return RichText(
      text: TextSpan(
        style: TextStyle(color: Colors.grey[600], fontSize: 15, height: 1.5),
        children: [
          const TextSpan(text: 'Hi, Go! To create a '),
          TextSpan(
            text: 'ForUM',
            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: 'hub',
            style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold),
          ),
          const TextSpan(text: ' account, you must be currently enrolled.'),
        ],
      ),
    );
  }

  Widget _buildCourseDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCourse,
          hint: Text('Select course (optional)', style: TextStyle(color: Colors.grey[500])),
          isExpanded: true,
          menuMaxHeight: 300,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
          items: CourseConstants.allCourses.map((c) {
            return DropdownMenuItem(
              value: c,
              child: Text(
                c,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (v) => setState(() => _selectedCourse = v),
        ),
      ),
    );
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        LoginTextField(
          controller: _nameController,
          hintText: 'Full Name',
          icon: Icons.person_outline,
          isPassword: false,
        ),
        const SizedBox(height: 16),
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
        const SizedBox(height: 16),
        LoginTextField(
          controller: _confirmController,
          hintText: 'Confirm Password',
          icon: Icons.lock_outlined,
          isPassword: true,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return LoginButton(
      onPressed: _handleCreateAccount,
      color: Theme.of(context).colorScheme.secondary,
      label: 'NEXT',
    );
  }
}
