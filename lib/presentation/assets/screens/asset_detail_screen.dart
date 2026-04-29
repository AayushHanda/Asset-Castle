import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/asset_model.dart';
import '../../../data/models/asset_log_model.dart';
import '../providers/asset_provider.dart';
import '../../employees/providers/employee_provider.dart';
import 'asset_form_screen.dart';
import 'package:share_plus/share_plus.dart';

class AssetDetailScreen extends ConsumerWidget {
  final AssetModel asset;

  const AssetDetailScreen({super.key, required this.asset});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logsAsync = ref.watch(assetLogsProvider(asset.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(asset.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AssetFormScreen(asset: asset),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Asset Image / QR
          _buildHeaderCard(context, isDark),
          const SizedBox(height: 16),

          // Details
          _buildDetailsCard(context, isDark),
          const SizedBox(height: 16),

          // Assignment
          _buildAssignmentCard(context, ref, isDark),
          const SizedBox(height: 16),

          // Images
          if (asset.imageUrl != null) ...[
            _buildImageSection(context, isDark),
            const SizedBox(height: 16),
          ],

          // QR Code
          _buildQRCard(context, isDark),
          const SizedBox(height: 16),

          // History
          _buildHistoryCard(context, logsAsync, isDark),
        ],
      ),
    );
  }

  Widget _buildImageSection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppStyles.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Asset Image', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: InteractiveViewer(
              child: Image.network(
                asset.imageUrl!,
                width: double.infinity,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  width: double.infinity,
                  color: isDark ? AppColors.darkBg : AppColors.lightBg,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: AppColors.error, size: 40),
                      SizedBox(height: 8),
                      Text('Failed to load image'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.gradientCardDecoration(
        colors: [AppColors.primary, AppColors.primaryLight],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: asset.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.network(
                      asset.imageUrl!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    _getCategoryIcon(asset.category),
                    color: Colors.white,
                    size: 36,
                  ),
          ),
          const SizedBox(height: 12),
          Text(
            asset.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${asset.category} • ${asset.serialNumber}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(asset.status.icon, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  asset.status.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Details',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _DetailRow(
            icon: Icons.category_rounded,
            label: 'Category',
            value: asset.category,
            isDark: isDark,
          ),
          _DetailRow(
            icon: Icons.tag,
            label: 'Serial Number',
            value: asset.serialNumber,
            isDark: isDark,
          ),
          _DetailRow(
            icon: Icons.calendar_today_rounded,
            label: 'Purchase Date',
            value: Helpers.formatDate(asset.purchaseDate),
            isDark: isDark,
          ),
          if (asset.purchasePrice != null)
            _DetailRow(
              icon: Icons.attach_money_rounded,
              label: 'Purchase Price',
              value: '₹${asset.purchasePrice!.toStringAsFixed(2)}',
              isDark: isDark,
            ),
          if (asset.notes != null && asset.notes!.isNotEmpty)
            _DetailRow(
              icon: Icons.notes_rounded,
              label: 'Notes',
              value: asset.notes!,
              isDark: isDark,
            ),
          _DetailRow(
            icon: Icons.access_time_rounded,
            label: 'Created',
            value: Helpers.formatDateTime(asset.createdAt),
            isDark: isDark,
          ),
          if (asset.lastScannedAt != null)
            _DetailRow(
              icon: Icons.qr_code_scanner_rounded,
              label: 'Last Scanned',
              value: Helpers.formatDateTime(asset.lastScannedAt!),
              isDark: isDark,
            ),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard(
      BuildContext context, WidgetRef ref, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Assignment',
                  style: Theme.of(context).textTheme.titleLarge),
              if (asset.isAssigned)
                TextButton.icon(
                  onPressed: () => _unassignAsset(context, ref),
                  icon: const Icon(Icons.person_remove, size: 16),
                  label: const Text('Unassign'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                )
              else
                TextButton.icon(
                  onPressed: () => _showAssignDialog(context, ref),
                  icon: const Icon(Icons.person_add, size: 16),
                  label: const Text('Assign'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (asset.isAssigned) ...[
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: const Icon(Icons.person, color: AppColors.primary,
                      size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.assignedEmployeeName ?? 'Unknown',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Assigned',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ] else
            Text(
              'Not assigned to anyone',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.textOnDarkMuted
                        : AppColors.textMedium,
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildQRCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.cardDecoration(context),
      child: Column(
        children: [
          Text('QR Code',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: QrImageView(
              data: asset.id,
              version: QrVersions.auto,
              size: 180,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AppColors.textDark,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: AppColors.textDark,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  SharePlus.instance.share(
                    ShareParams(text: 'Asset: ${asset.name}\nID: ${asset.id}'),
                  );
                },
                icon: const Icon(Icons.share, size: 18),
                label: const Text('Share'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context,
      AsyncValue<List<dynamic>> logsAsync, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('History',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          logsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
            data: (logs) {
              if (logs.isEmpty) {
                return const Text('No history recorded yet');
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index] as AssetLogModel;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Helpers.getLogActionColor(log.action)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Helpers.getLogActionIcon(log.action),
                            size: 16,
                            color: Helpers.getLogActionColor(log.action),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                log.action.label,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontSize: 13),
                              ),
                              if (log.notes != null)
                                Text(
                                  log.notes!,
                                  style:
                                      Theme.of(context).textTheme.bodySmall,
                                ),
                              Text(
                                '${Helpers.formatRelativeTime(log.timestamp)} by ${log.performedByName}',
                                style:
                                    Theme.of(context).textTheme.labelSmall,
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
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'laptop':
        return Icons.laptop_mac_rounded;
      case 'desktop':
        return Icons.desktop_mac_rounded;
      case 'monitor':
        return Icons.monitor_rounded;
      case 'keyboard':
        return Icons.keyboard_rounded;
      case 'mouse':
        return Icons.mouse_rounded;
      case 'phone':
        return Icons.phone_android_rounded;
      case 'tablet':
        return Icons.tablet_mac_rounded;
      case 'printer':
        return Icons.print_rounded;
      case 'server':
        return Icons.dns_rounded;
      case 'networking':
        return Icons.router_rounded;
      case 'furniture':
        return Icons.chair_rounded;
      case 'vehicle':
        return Icons.directions_car_rounded;
      case 'software license':
        return Icons.code_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  Future<void> _unassignAsset(BuildContext context, WidgetRef ref) async {
    if (!asset.isAssigned) return;
    final confirmed = await Helpers.showConfirmDialog(
      context,
      title: 'Unassign Asset',
      message:
          'Remove this asset from ${asset.assignedEmployeeName}?',
      confirmText: 'Unassign',
      confirmColor: AppColors.warning,
    );
    if (confirmed && context.mounted) {
      await ref.read(assetNotifierProvider.notifier).unassignAsset(
            asset.id,
            asset.name,
            asset.assignedEmployeeId!,
            asset.assignedEmployeeName!,
          );
      if (context.mounted) {
        Navigator.pop(context);
        Helpers.showSnackBar(context, 'Asset unassigned');
      }
    }
  }

  void _showAssignDialog(BuildContext context, WidgetRef ref) {
    final employees = ref.read(employeesStreamProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign to Employee'),
        content: SizedBox(
          width: double.maxFinite,
          child: employees.when(
            loading: () => const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text('Error: $e'),
            data: (empList) {
              if (empList.isEmpty) {
                return const Text('No employees found');
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: empList.length,
                itemBuilder: (context, index) {
                  final emp = empList[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.12),
                      child: Text(
                        emp.initials,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    title: Text(emp.name),
                    subtitle: Text(emp.department),
                    onTap: () async {
                      Navigator.pop(context);
                      await ref
                          .read(assetNotifierProvider.notifier)
                          .assignAsset(
                            asset.id,
                            asset.name,
                            emp.id,
                            emp.name,
                          );
                      if (context.mounted) {
                        Navigator.pop(context);
                        Helpers.showSnackBar(
                            context, 'Assigned to ${emp.name}');
                      }
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: isDark ? AppColors.textOnDarkMuted : AppColors.textMedium,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
