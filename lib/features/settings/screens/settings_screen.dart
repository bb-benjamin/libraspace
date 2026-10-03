import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 52,
              backgroundColor: AppColors.primary,
              child: Text(
                user?.fullName.isNotEmpty == true
                    ? user!.fullName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.fullName ?? '',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user?.emailAddress ?? '',
              style: const TextStyle(color: AppColors.textGrey),
            ),
            const SizedBox(height: 32),
            _ProfileTile(
              icon: Icons.school_outlined,
              label: 'Programme',
              value: user?.programme ?? '',
            ),
            const SizedBox(height: 12),
            _ProfileTile(
              icon: Icons.business_outlined,
              label: 'Institution',
              value: user?.institution ?? '',
            ),
            const SizedBox(height: 32),

            // ── SIGN OUT BUTTON ────────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => auth.signOut(),
              ),
            ),

            const SizedBox(height: 12),

            // ── DELETE ACCOUNT BUTTON ──────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(
                  Icons.delete_forever_outlined,
                  color: Colors.red,
                ),
                label: const Text(
                  'Delete Account',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _showDeleteConfirmation(context, auth),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showDeleteConfirmation(BuildContext context, AuthProvider auth) {
  final TextEditingController passwordController = TextEditingController();

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Are you sure you want to delete your account? '
            'This action cannot be undone. '
            'All your data will be permanently deleted.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Enter your password',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            passwordController.dispose();
            Navigator.pop(ctx);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            final password = passwordController.text.trim();

            if (password.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter your password.'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            Navigator.pop(ctx);

            final bool success = await auth.deleteAccount(password);

            passwordController.dispose();

            if (!success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(auth.errorText ?? 'Could not delete account.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
