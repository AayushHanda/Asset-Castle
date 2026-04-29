import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../data/services/csv_service.dart';
import '../../../data/repositories/asset_repository.dart';
import '../../../data/repositories/employee_repository.dart';
import '../../auth/providers/auth_provider.dart';
import '../../assets/providers/asset_provider.dart';
import '../../employees/providers/employee_provider.dart';
import 'user_management_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authNotifierProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Profile Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppStyles.cardDecoration(context),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      (user?.name ?? 'A')[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Admin',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        user?.email ?? '',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          user?.role.label ?? 'Admin',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Appearance
          Text('Appearance',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            decoration: AppStyles.cardDecoration(context),
            child: SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: Text(
                isDark ? 'Dark theme enabled' : 'Light theme enabled',
              ),
              secondary: Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: AppColors.primary,
              ),
              value: isDark,
              activeTrackColor: AppColors.primary,
              onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // User Management
          if (user?.role.canManageUsers ?? false) ...[
             Text('Administration', style: Theme.of(context).textTheme.titleMedium),
             const SizedBox(height: 8),
             Container(
               decoration: AppStyles.cardDecoration(context),
               child: ListTile(
                 leading: const Icon(Icons.people_alt_outlined, color: AppColors.primary),
                 title: const Text('User Management'),
                 subtitle: const Text('Manage team members and roles'),
                 trailing: const Icon(Icons.chevron_right, size: 20),
                 onTap: () => Navigator.push(
                   context,
                   MaterialPageRoute(builder: (_) => const UserManagementScreen()),
                 ),
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(16),
                 ),
               ),
             ),
             const SizedBox(height: 20),
          ],

          // Data Management
          Text('Data Management',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            decoration: AppStyles.cardDecoration(context),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.file_upload_outlined,
                      color: AppColors.primary),
                  title: const Text('Import Assets (CSV)'),
                  subtitle: const Text('Bulk import from CSV file'),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => _importAssets(context, ref),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                Divider(
                  height: 1,
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                ListTile(
                  leading: const Icon(Icons.file_upload_outlined,
                      color: AppColors.secondary),
                  title: const Text('Import Employees (CSV)'),
                  subtitle: const Text('Bulk import employees'),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => _importEmployees(context, ref),
                ),
                Divider(
                  height: 1,
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                ListTile(
                  leading: const Icon(Icons.file_download_outlined,
                      color: AppColors.success),
                  title: const Text('Export Assets (CSV)'),
                  subtitle: const Text('Download all assets as CSV'),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => _exportAssets(context, ref),
                ),
                Divider(
                  height: 1,
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                ListTile(
                  leading: const Icon(Icons.file_download_outlined,
                      color: AppColors.warning),
                  title: const Text('Export Employees (CSV)'),
                  subtitle: const Text('Download all employees as CSV'),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => _exportEmployees(context, ref),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // About
          Text('About',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            decoration: AppStyles.cardDecoration(context),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline,
                      color: AppColors.primary),
                  title: const Text(AppStrings.appName),
                  subtitle: const Text(AppStrings.version),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Logout
          Container(
            decoration: AppStyles.cardDecoration(context),
            child: ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: const Text(
                'Logout',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () => _handleLogout(context, ref),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await Helpers.showConfirmDialog(
      context,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
      confirmColor: AppColors.error,
    );
    if (confirmed) {
      await ref.read(authNotifierProvider.notifier).signOut();
    }
  }

  Future<void> _importAssets(BuildContext context, WidgetRef ref) async {
    try {
      final user = ref.read(authNotifierProvider).user;
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
      if (result == null || result.files.single.path == null) return;

      final file = File(result.files.single.path!);
      final csvService = CsvService();
      final assets = await csvService.importAssets(file, user?.companyId ?? 'default');

      final repo = AssetRepository();
      int count = 0;
      for (final asset in assets) {
        await repo.addAsset(asset);
        count++;
      }

      if (context.mounted) {
        Helpers.showSnackBar(context, 'Imported $count assets successfully');
      }
    } catch (e) {
      if (context.mounted) {
        Helpers.showSnackBar(context, 'Import failed: $e', isError: true);
      }
    }
  }

  Future<void> _importEmployees(BuildContext context, WidgetRef ref) async {
    try {
      final user = ref.read(authNotifierProvider).user;
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
      if (result == null || result.files.single.path == null) return;

      final file = File(result.files.single.path!);
      final csvService = CsvService();
      final employees = await csvService.importEmployees(file, user?.companyId ?? 'default');

      final repo = EmployeeRepository();
      int count = 0;
      for (final emp in employees) {
        await repo.addEmployee(emp);
        count++;
      }

      if (context.mounted) {
        Helpers.showSnackBar(
            context, 'Imported $count employees successfully');
      }
    } catch (e) {
      if (context.mounted) {
        Helpers.showSnackBar(context, 'Import failed: $e', isError: true);
      }
    }
  }

  Future<void> _exportAssets(BuildContext context, WidgetRef ref) async {
    try {
      final assetsAsync = ref.read(assetsStreamProvider);
      final assets = assetsAsync.when(
        data: (list) => list,
        loading: () => <dynamic>[],
        error: (_, _) => <dynamic>[],
      );
      if (assets.isEmpty) {
        if (context.mounted) {
          Helpers.showSnackBar(context, 'No assets to export', isError: true);
        }
        return;
      }

      final csvService = CsvService();
      final csv = csvService.exportAssetsCsv(assets.cast());
      final dir = await getApplicationDocumentsDirectory();
      final file = File(
          '${dir.path}/assets_export_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(csv);

      if (context.mounted) {
        Helpers.showSnackBar(
            context, 'Exported ${assets.length} assets');
      }
    } catch (e) {
      if (context.mounted) {
        Helpers.showSnackBar(context, 'Export failed: $e', isError: true);
      }
    }
  }

  Future<void> _exportEmployees(BuildContext context, WidgetRef ref) async {
    try {
      final employeesAsync = ref.read(employeesStreamProvider);
      final employees = employeesAsync.when(
        data: (list) => list,
        loading: () => <dynamic>[],
        error: (_, _) => <dynamic>[],
      );
      if (employees.isEmpty) {
        if (context.mounted) {
          Helpers.showSnackBar(context, 'No employees to export', isError: true);
        }
        return;
      }

      final csvService = CsvService();
      final csv = csvService.exportEmployeesCsv(employees.cast());
      final dir = await getApplicationDocumentsDirectory();
      final file = File(
          '${dir.path}/employees_export_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(csv);

      if (context.mounted) {
        Helpers.showSnackBar(context,
            'Exported ${employees.length} employees');
      }
    } catch (e) {
      if (context.mounted) {
        Helpers.showSnackBar(context, 'Export failed: $e', isError: true);
      }
    }
  }
}
