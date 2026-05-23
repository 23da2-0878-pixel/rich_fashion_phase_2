import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../auth/login_screen.dart';
import '../orders/order_history_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // ── Logout flow ─────────────────────────────────────────────────────────
  Future<void> _confirmAndLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('Are you sure you want to log out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await context.read<AuthProvider>().signOut();
    } catch (e) {
      debugPrint('Logout error: $e');
    }

    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
      LoginScreen.routeName,
      (route) => false,
    );
  }

  // ── Menu tap router ─────────────────────────────────────────────────────
  void _handleMenuTap(BuildContext context, String title) {
    switch (title) {
      case 'Log out':
        _confirmAndLogout(context);
        break;
      case 'My Profile':
        Navigator.pushNamed(context, EditProfileScreen.routeName);
        break;
      case 'My Orders':
        Navigator.pushNamed(context, OrderHistoryScreen.routeName);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title coming soon'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authUser = FirebaseAuth.instance.currentUser;

    if (authUser == null) {
      return const Center(child: Text('Please log in to view your profile'));
    }

    final items = [
      (Icons.person_outline_rounded,    'My Profile'),
      (Icons.shopping_bag_outlined,     'My Orders'),
      (Icons.currency_exchange_rounded, 'Refunds'),
      (Icons.lock_outline_rounded,      'Change Password'),
      (Icons.language_rounded,          'Change Language'),
      (Icons.logout_rounded,            'Log out'),
    ];

    return SafeArea(
      // Live stream of the user's Firestore doc — auto-updates when edited
      child: StreamBuilder<UserModel?>(
        stream: FirestoreService.userStream(authUser.uid),
        builder: (context, snapshot) {
          final user = snapshot.data;
          final displayName = user?.name.isNotEmpty == true
              ? user!.name
              : (authUser.displayName ?? 'User');
          final email   = user?.email   ?? authUser.email ?? '';
          final phone   = user?.phone   ?? '';
          final address = user?.address ?? '';

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            children: [
              Text('Profile',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 18),

              // ─── Avatar / identity card ───────────────────────────────
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE5DFD7)),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: const Color(0xFF1B1B1F),
                      child: Text(
                        displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(displayName,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(email,
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 18),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => Navigator.pushNamed(
                          context, EditProfileScreen.routeName),
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      label: const Text('Edit Profile'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ─── Contact info card ────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5DFD7)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Contact Info',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon:  Icons.phone_outlined,
                      label: 'Phone',
                      value: phone.isEmpty ? 'Not set' : phone,
                      isEmpty: phone.isEmpty,
                    ),
                    const SizedBox(height: 10),
                    _InfoRow(
                      icon:  Icons.home_outlined,
                      label: 'Address',
                      value: address.isEmpty ? 'Not set' : address,
                      isEmpty: address.isEmpty,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ─── Menu items ───────────────────────────────────────────
              ...items.map(
                (item) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE5DFD7)),
                  ),
                  child: ListTile(
                    leading: Icon(
                      item.$1,
                      color: item.$2 == 'Log out' ? AppColors.danger : null,
                    ),
                    title: Text(
                      item.$2,
                      style: TextStyle(
                        color: item.$2 == 'Log out' ? AppColors.danger : null,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _handleMenuTap(context, item.$2),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Helper widget for a row of "Phone: 077..." ─────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isEmpty;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.secondary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: isEmpty ? AppColors.secondary : null,
                  fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}