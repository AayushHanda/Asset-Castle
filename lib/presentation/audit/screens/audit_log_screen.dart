import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/widgets/loading_widget.dart';
import '../providers/audit_provider.dart';

class AuditLogScreen extends ConsumerWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logsAsync = ref.watch(filteredAuditLogsProvider);
    final filter = ref.watch(auditFilterNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Log'),
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: filter == null,
                    onSelected: () =>
                        ref.read(auditFilterNotifierProvider.notifier).clear(),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Assets',
                    selected: filter == 'asset',
                    onSelected: () =>
                        ref.read(auditFilterNotifierProvider.notifier).update('asset'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Employees',
                    selected: filter == 'employee',
                    onSelected: () =>
                        ref.read(auditFilterNotifierProvider.notifier).update('employee'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Users',
                    selected: filter == 'user',
                    onSelected: () =>
                        ref.read(auditFilterNotifierProvider.notifier).update('user'),
                  ),
                ],
              ),
            ),
          ),

          // Logs
          Expanded(
            child: logsAsync.when(
              loading: () => const ShimmerLoading(),
              error: (e, _) => ErrorDisplay(message: e.toString()),
              data: (logs) {
                if (logs.isEmpty) {
                  return const EmptyState(
                    icon: Icons.history_rounded,
                    title: 'No Audit Logs',
                    subtitle: 'Activity logs will appear here',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _getActionColor(log.action)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _getActionIcon(log.action),
                              size: 18,
                              color: _getActionColor(log.action),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontSize: 13),
                                    children: [
                                      TextSpan(
                                        text: log.userName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700),
                                      ),
                                      TextSpan(
                                          text: ' ${log.action} '),
                                      TextSpan(
                                        text: log.entityName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                                if (log.details != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      log.details!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: _getEntityColor(log.entityType)
                                            .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        log.entityType.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: _getEntityColor(
                                              log.entityType),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      Helpers.formatRelativeTime(
                                          log.timestamp),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'created':
        return Icons.add_circle_outline;
      case 'updated':
        return Icons.edit_outlined;
      case 'deleted':
        return Icons.delete_outline;
      case 'assigned':
        return Icons.person_add_outlined;
      case 'unassigned':
        return Icons.person_remove_outlined;
      case 'login':
        return Icons.login;
      case 'logout':
        return Icons.logout;
      default:
        return Icons.info_outline;
    }
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'created':
        return AppColors.success;
      case 'updated':
        return AppColors.primary;
      case 'deleted':
        return AppColors.error;
      case 'assigned':
        return AppColors.secondary;
      case 'unassigned':
        return AppColors.warning;
      case 'login':
        return AppColors.success;
      case 'logout':
        return AppColors.textMedium;
      default:
        return AppColors.primary;
    }
  }

  Color _getEntityColor(String type) {
    switch (type) {
      case 'asset':
        return AppColors.primary;
      case 'employee':
        return AppColors.secondary;
      case 'user':
        return AppColors.accent;
      default:
        return AppColors.textMedium;
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : isDark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : null,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
