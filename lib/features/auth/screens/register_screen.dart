// ═══════════════════════════════════════════════════
// FILE: lib/features/auth/screens/register_screen.dart
// PURPOSE: 5-field account creation form.
// ═══════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../shared/theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _programmeController = TextEditingController();
  final _institutionController = TextEditingController();
  bool _hidePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _programmeController.dispose();
    _institutionController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final bool success = await auth.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _nameController.text.trim(),
      programme: _programmeController.text.trim(),
      institution: _institutionController.text.trim(),
    );
    if (success && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorText ?? 'Registration failed.'),
          backgroundColor: AppColors.heatRed,
        ),
      );
    }
  }

  // HELPER: Builds ONE text field. We have 5 similar fields.
  // Writing this once and calling it 5 times is the DRY principle:
  // Don't Repeat Yourself. Saves writing 100+ repetitive lines.
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && _hidePassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _hidePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(() => _hidePassword = !_hidePassword),
              )
            : null,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your $label';
          // $label inserts the field name, e.g. "Please enter your Full Name"
        }
        if (label == 'Email Address' && !value.contains('@')) {
          return 'Please enter a valid email';
        }
        if (isPassword && value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Join LibraSpace 🎓',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Create your student account',
                style: TextStyle(color: AppColors.textGrey),
              ),
              const SizedBox(height: 32),

              // The 5 fields — each calls our helper function
              _buildField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person_outlined,
              ),
              const SizedBox(height: 16),

              _buildField(
                controller: _emailController,
                label: 'Email Address',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              _buildField(
                controller: _passwordController,
                label: 'Password',
                icon: Icons.lock_outlined,
                isPassword: true,
              ),
              const SizedBox(height: 16),

              _buildField(
                controller: _programmeController,
                label: 'Programme of Study',
                icon: Icons.school_outlined,
              ),
              const SizedBox(height: 16),

              _buildField(
                controller: _institutionController,
                label: 'Institution / University',
                icon: Icons.business_outlined,
              ),
              const SizedBox(height: 32),

              Consumer<AuthProvider>(
                builder: (context, auth, child) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: auth.isBusy ? null : _handleRegister,
                      child: auth.isBusy
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Create Account'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
