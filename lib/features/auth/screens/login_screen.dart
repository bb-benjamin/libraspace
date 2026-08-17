// ═══════════════════════════════════════════════════
// FILE: lib/features/auth/screens/login_screen.dart
// PURPOSE: Email + password sign-in form.
// ═══════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../shared/theme/app_theme.dart';

// StatefulWidget = screen that CAN CHANGE while visible.
// We need this because the password show/hide toggle changes the screen.
class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers capture what the user types in each field.
  // Read the value with: _emailController.text
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Remote control for the Form. Triggers validation on all fields at once.
  final _formKey = GlobalKey<FormState>();

  bool _hidePassword = true; // true = shows dots ●●●●

  @override
  void dispose() {
    // ALWAYS dispose controllers when screen closes — frees memory.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    // validate() checks all fields. Returns false if any field has an error.
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    // .read() gets the provider WITHOUT watching it.
    // Consumer handles the button's visual rebuild separately.

    final bool success = await auth.signIn(
      email: _emailController.text.trim(),
      // .trim() removes accidental spaces at start/end of email
      password: _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorText ?? 'Sign in failed.'),
          backgroundColor: AppColors.heatRed,
        ),
      );
    }
    // If success, AuthProvider detects login and app.dart shows MainShell.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),

      // SingleChildScrollView = allows screen to scroll when keyboard appears
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        // Form groups fields for validation
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              Text(
                'Welcome back 👋',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 8),
              const Text(
                'Sign in to find available library seats',
                style: TextStyle(color: AppColors.textGrey),
              ),
              const SizedBox(height: 40),

              // EMAIL FIELD
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                // emailAddress keyboard shows @ key prominently
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  // Return a String = show as error below field
                  // Return null = field is valid
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email address';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // PASSWORD FIELD
              TextFormField(
                controller: _passwordController,
                obscureText: _hidePassword, // true = shows dots ●●●●
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    // Eye icon button to show/hide password
                    icon: Icon(
                      _hidePassword
                          ? Icons
                                .visibility_outlined // "tap to show"
                          : Icons.visibility_off_outlined,
                    ), // "tap to hide"
                    onPressed: () {
                      setState(() {
                        _hidePassword = !_hidePassword;
                        // setState = "something changed, rebuild this screen"
                        // !_hidePassword flips the boolean (true→false, false→true)
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // SIGN IN BUTTON
              // Consumer watches AuthProvider and rebuilds ONLY this button.
              // More efficient than rebuilding the whole screen.
              Consumer<AuthProvider>(
                builder: (context, auth, child) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: auth.isBusy ? null : _handleSignIn,
                      // null = button is grayed out and disabled while loading
                      child: auth.isBusy
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Sign In'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
