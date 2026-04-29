import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

import '../../../data/models/asset_model.dart';

class AssetCard extends StatelessWidget {
  final AssetModel asset;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool? canDelete;

  const AssetCard({
    super.key,
    required this.asset,
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Asset Icon / Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBg : AppColors.lightBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1,
                  ),
                ),
                child: asset.imageUrl != null && asset.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Image.network(
                          asset.imageUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => Icon(
                            _getCategoryIcon(asset.category),
                            color: AppColors.primary,
                            size: 28,
                          ),
                        ),
                      )
                    : Icon(
                        _getCategoryIcon(asset.category),
                        color: AppColors.primary,
                        size: 28,
                      ),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${asset.category} • ${asset.serialNumber}',
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Status chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: asset.status.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(asset.status.icon, size: 12,
                                  color: asset.status.color),
                              const SizedBox(width: 4),
                              Text(
                                asset.status.label,
                                style: TextStyle(
                                  color: asset.status.color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Assignment
                        if (asset.isAssigned)
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.person, size: 12,
                                    color: isDark
                                        ? AppColors.textOnDarkMuted
                                        : AppColors.textMedium),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Text(
                                    asset.assignedEmployeeName ?? '',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark
                                          ? AppColors.textOnDarkMuted
                                          : AppColors.textMedium,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Text(
                            'Unassigned',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textOnDarkMuted
                                  : AppColors.textLight,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Menu
              PopupMenuButton<String>(
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'view', child: Text('View Details')),
                  if (canDelete == true) const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
                onSelected: (v) {
                  if (v == 'view') onTap();
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
}
