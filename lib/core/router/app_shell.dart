import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../../presentation/dashboard/screens/dashboard_screen.dart';
import '../../presentation/assets/screens/asset_list_screen.dart';
import '../../presentation/employees/screens/employee_list_screen.dart';
import '../../presentation/scanner/screens/scanner_screen.dart';
import '../../presentation/audit/screens/audit_log_screen.dart';
import '../../presentation/settings/screens/settings_screen.dart';

final currentTabProvider = NotifierProvider<CurrentTabNotifier, int>(() => CurrentTabNotifier());

class CurrentTabNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void update(int tab) => state = tab;
}

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentTabProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screens = [
      const DashboardScreen(),
      const AssetListScreen(),
      const EmployeeListScreen(),
      const AuditLogScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentTab,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  isSelected: currentTab == 0,
                  onTap: () =>
                      ref.read(currentTabProvider.notifier).update(0),
                  isDark: isDark,
                ),
                _NavItem(
                  icon: Icons.inventory_2_rounded,
                  label: 'Assets',
                  isSelected: currentTab == 1,
                  onTap: () =>
                      ref.read(currentTabProvider.notifier).update(1),
                  isDark: isDark,
                ),
                _ScanButton(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ScannerScreen()),
                  ),
                ),
                _NavItem(
                  icon: Icons.people_rounded,
                  label: 'Employees',
                  isSelected: currentTab == 2,
                  onTap: () =>
                      ref.read(currentTabProvider.notifier).update(2),
                  isDark: isDark,
                ),
                _NavItem(
                  icon: Icons.more_horiz_rounded,
                  label: 'More',
                  isSelected: currentTab == 3 || currentTab == 4,
                  onTap: () => _showMoreMenu(context, ref),
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMoreMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.history_rounded,
                    color: AppColors.primary),
                title: const Text('Audit Log'),
                subtitle: const Text('View all activity'),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(currentTabProvider.notifier).update(3);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.settings_rounded, color: AppColors.secondary),
                title: const Text('Settings'),
                subtitle: const Text('App preferences & data'),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(currentTabProvider.notifier).update(4);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isSelected
                    ? AppColors.primary
                    : isDark
                        ? AppColors.textOnDarkMuted
                        : AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : isDark
                        ? AppColors.textOnDarkMuted
                        : AppColors.textMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ScanButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.qr_code_scanner_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
