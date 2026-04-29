import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../data/models/asset_model.dart';
import '../../../domain/enums/asset_status.dart';
import '../providers/asset_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/asset_card.dart';
import 'asset_form_screen.dart';
import 'asset_detail_screen.dart';

class AssetListScreen extends ConsumerWidget {
  const AssetListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final assetsAsync = ref.watch(filteredAssetsProvider);
    final searchQuery = ref.watch(assetSearchNotifierProvider);
    final categoryFilter = ref.watch(assetCategoryFilterNotifierProvider);
    final statusFilter = ref.watch(assetStatusFilterNotifierProvider);
    final user = ref.watch(authNotifierProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.assets),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => _showFilterSheet(context, ref, categoryFilter, statusFilter),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (v) => ref.read(assetSearchNotifierProvider.notifier).update(v),
              decoration: InputDecoration(
                hintText: 'Search assets by name, serial...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () =>
                            ref.read(assetSearchNotifierProvider.notifier).clear(),
                      )
                    : null,
              ),
            ),
          ),

          // Active filters
          if (categoryFilter != null || statusFilter != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (categoryFilter != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(categoryFilter),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () => ref
                            .read(assetCategoryFilterNotifierProvider.notifier)
                            .clear(),
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        side: BorderSide.none,
                      ),
                    ),
                  if (statusFilter != null)
                    Chip(
                      label: Text(AssetStatus.fromString(statusFilter).label),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => ref
                          .read(assetStatusFilterNotifierProvider.notifier)
                          .clear(),
                      backgroundColor: AssetStatus.fromString(statusFilter)
                          .color
                          .withValues(alpha: 0.1),
                      side: BorderSide.none,
                    ),
                ],
              ),
            ),

          const SizedBox(height: 4),

          // List
          Expanded(
            child: assetsAsync.when(
              loading: () => const ShimmerLoading(),
              error: (e, _) => ErrorDisplay(message: e.toString()),
              data: (assets) {
                if (assets.isEmpty) {
                  return EmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: AppStrings.noAssets,
                    subtitle: 'Start by adding your first asset',
                    buttonText: AppStrings.addAsset,
                    onButtonPressed: () => _navigateToForm(context),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: assets.length,
                  itemBuilder: (context, index) {
                    return AssetCard(
                      asset: assets[index],
                      isDark: isDark,
                      onTap: () => _navigateToDetail(context, assets[index]),
                      onDelete: () =>
                          _handleDelete(context, ref, assets[index]),
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
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Asset'),
      ) : null,
    );
  }

  void _navigateToForm(BuildContext context, [AssetModel? asset]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AssetFormScreen(asset: asset)),
    );
  }

  void _navigateToDetail(BuildContext context, AssetModel asset) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AssetDetailScreen(asset: asset)),
    );
  }

  Future<void> _handleDelete(
    BuildContext context, WidgetRef ref, AssetModel asset,
  ) async {
    final confirmed = await Helpers.showConfirmDialog(
      context,
      title: AppStrings.deleteAsset,
      message: 'Are you sure you want to delete "${asset.name}"?',
    );
    if (confirmed && context.mounted) {
      final success = await ref
          .read(assetNotifierProvider.notifier)
          .deleteAsset(asset.id, asset.name);
      if (context.mounted) {
        Helpers.showSnackBar(
          context,
          success ? AppStrings.deleted : 'Failed to delete',
          isError: !success,
        );
      }
    }
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref,
      String? categoryFilter, String? statusFilter) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scrollController,
            children: [
              Text('Filters',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 20),

              // Status filter
              Text('Status',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: statusFilter == null,
                    onSelected: (_) {
                      ref.read(assetStatusFilterNotifierProvider.notifier).clear();
                    },
                  ),
                  ...AssetStatus.values.map((s) => ChoiceChip(
                        label: Text(s.label),
                        selected: statusFilter == s.name,
                        selectedColor: s.color.withValues(alpha: 0.2),
                        onSelected: (_) {
                          ref.read(assetStatusFilterNotifierProvider.notifier).update(s.name);
                        },
                      )),
                ],
              ),
              const SizedBox(height: 20),

              // Category filter
              Text('Category',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: categoryFilter == null,
                    onSelected: (_) {
                      ref.read(assetCategoryFilterNotifierProvider.notifier).clear();
                    },
                  ),
                  ...AppStrings.assetCategories.map((c) => ChoiceChip(
                        label: Text(c),
                        selected: categoryFilter == c,
                        selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        onSelected: (_) {
                          ref.read(assetCategoryFilterNotifierProvider.notifier).update(c);
                        },
                      )),
                ],
              ),
              const SizedBox(height: 24),

              // Clear all
              OutlinedButton(
                onPressed: () {
                  ref.read(assetCategoryFilterNotifierProvider.notifier).clear();
                  ref.read(assetStatusFilterNotifierProvider.notifier).clear();
                  Navigator.pop(context);
                },
                child: const Text('Clear All Filters'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
