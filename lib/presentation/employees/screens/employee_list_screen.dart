import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../data/models/employee_model.dart';
import '../providers/employee_provider.dart';
import 'employee_form_screen.dart';
import '../../auth/providers/auth_provider.dart';

class EmployeeListScreen extends ConsumerWidget {
  const EmployeeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final employeesAsync = ref.watch(filteredEmployeesProvider);
    final searchQuery = ref.watch(employeeSearchQueryProvider);
    final deptFilter = ref.watch(employeeDeptFilterNotifierProvider);
    final user = ref.watch(authNotifierProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.employees),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filter',
            onPressed: () => _showFilterSheet(context, ref, deptFilter),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              onChanged: (v) => ref.read(employeeSearchQueryProvider.notifier).update(v),
              decoration: InputDecoration(
                hintText: 'Search employees...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () =>
                            ref.read(employeeSearchQueryProvider.notifier).clear(),
                      )
                    : null,
              ),
            ),
          ),

          if (deptFilter != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Chip(
                    label: Text(deptFilter),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => ref
                        .read(employeeDeptFilterNotifierProvider.notifier)
                        .clear(),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    side: BorderSide.none,
                  ),
                ],
              ),
            ),

          // List
          Expanded(
            child: employeesAsync.when(
              loading: () => const ShimmerLoading(),
              error: (e, _) => ErrorDisplay(message: e.toString()),
              data: (employees) {
                if (employees.isEmpty) {
                  return EmptyState(
                    icon: Icons.people_outline,
                    title: AppStrings.noEmployees,
                    subtitle: 'Add your first employee to get started',
                    buttonText: AppStrings.addEmployee,
                    onButtonPressed: () => _navigateToForm(context),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    return _EmployeeCard(
                      employee: employees[index],
                      isDark: isDark,
                      onTap: () => _navigateToForm(context, employees[index]),
                      onDelete: () =>
                          _handleDelete(context, ref, employees[index]),
                      canDelete: user?.role.canDelete,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: (user?.role.canWrite ?? false) ? FloatingActionButton.extended(
        onPressed: () => _navigateToForm(context),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add'),
      ) : null,
    );
  }

  void _navigateToForm(BuildContext context, [EmployeeModel? employee]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmployeeFormScreen(employee: employee),
      ),
    );
  }

  Future<void> _handleDelete(
    BuildContext context, WidgetRef ref, EmployeeModel emp,
  ) async {
    final confirmed = await Helpers.showConfirmDialog(
      context,
      title: AppStrings.deleteEmployee,
      message: 'Are you sure you want to delete ${emp.name}?',
    );
    if (confirmed && context.mounted) {
      final success = await ref
          .read(employeeNotifierProvider.notifier)
          .deleteEmployee(emp.id, emp.name);
      if (context.mounted) {
        Helpers.showSnackBar(
          context,
          success ? AppStrings.deleted : 'Failed to delete',
          isError: !success,
        );
      }
    }
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref, String? current) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter by Department',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: current == null,
                  onSelected: (_) {
                    ref.read(employeeDeptFilterNotifierProvider.notifier).clear();
                    Navigator.pop(context);
                  },
                ),
                ...AppStrings.departments.map((dept) => ChoiceChip(
                      label: Text(dept),
                      selected: current == dept,
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      onSelected: (_) {
                        ref.read(employeeDeptFilterNotifierProvider.notifier).update(dept);
                        Navigator.pop(context);
                      },
                    )),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  final EmployeeModel employee;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool? canDelete;

  const _EmployeeCard({
    required this.employee,
    required this.isDark,
    required this.onTap,
    required this.onDelete,
    this.canDelete = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
          backgroundImage: employee.photoUrl != null && employee.photoUrl!.isNotEmpty
              ? NetworkImage(employee.photoUrl!)
              : null,
          child: employee.photoUrl == null || employee.photoUrl!.isEmpty
              ? Text(
                  employee.initials,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                )
              : null,
        ),
        title: Text(
          employee.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          '${employee.designation} • ${employee.department}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (employee.assignedAssetCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${employee.assignedAssetCount}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                if (canDelete == true) const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
              onSelected: (v) {
                if (v == 'edit') onTap();
                if (v == 'delete') onDelete();
              },
              icon: Icon(
                Icons.more_vert,
                color: isDark ? AppColors.textOnDarkMuted : AppColors.textMedium,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
