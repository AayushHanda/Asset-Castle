import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/utils/helpers.dart';
import '../../../domain/enums/user_role.dart';
import '../providers/user_provider.dart';
import '../../auth/providers/auth_provider.dart';
import 'user_form_screen.dart';

class UserManagementScreen extends ConsumerWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersStreamProvider);
    final currentUser = ref.watch(authNotifierProvider).user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UserFormScreen()),
            ),
            icon: const Icon(Icons.person_add_outlined),
          ),
        ],
      ),
      body: usersAsync.when(
        data: (users) {
          if (users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.people_outline, size: 64, color: isDark ? AppColors.textOnDarkMuted : AppColors.textLight),
                   const SizedBox(height: 16),
                   const Text('No users found'),
                ],
              ),
            );
          }

          // Filter out current user from the list if desired, or keep it.
          // System admin sees everyone.
          
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final user = users[index];
              final isMe = user.uid == currentUser?.uid;

              return Container(
                decoration: AppStyles.cardDecoration(context),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        user.name[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                  ),
                  title: Text(
                    user.name + (isMe ? ' (You)' : ''),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.email, style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _RoleChip(role: user.role),
                          if (user.companyId != 'system') ...[
                            const SizedBox(width: 8),
                            _CompanyChip(company: user.companyId),
                          ],
                        ],
                      ),
                    ],
                  ),
                  trailing: isMe || !currentUser!.role.canDeleteUsers 
                    ? null 
                    : IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                        onPressed: () async {
                          final confirm = await Helpers.showConfirmDialog(
                            context,
                            title: 'Delete User',
                            message: 'Are you sure you want to delete ${user.name}? This will remove their data record. (Auth account requires admin cleanup)',
                            confirmText: 'Delete',
                            confirmColor: AppColors.error,
                          );
                          if (confirm) {
                            await ref.read(userNotifierProvider.notifier).deleteUser(user.uid, user.name);
                          }
                        },
                      ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final UserRole role;
  const _RoleChip({required this.role});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (role) {
      case UserRole.admin: color = Colors.purple; break;
      case UserRole.itDepartment: color = Colors.blue; break;
      case UserRole.engineer: color = Colors.teal; break;
      case UserRole.employee: color = Colors.grey; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        role.label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _CompanyChip extends StatelessWidget {
  final String company;
  const _CompanyChip({required this.company});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Text(
        company.toUpperCase(),
        style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
