import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/asset_model.dart';
import '../../../data/services/storage_service.dart';
import '../../../domain/enums/asset_status.dart';
import '../providers/asset_provider.dart';
import '../../auth/providers/auth_provider.dart';

class AssetFormScreen extends ConsumerStatefulWidget {
  final AssetModel? asset;

  const AssetFormScreen({super.key, this.asset});

  @override
  ConsumerState<AssetFormScreen> createState() => _AssetFormScreenState();
}

class _AssetFormScreenState extends ConsumerState<AssetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _serialController;
  late TextEditingController _notesController;
  late TextEditingController _priceController;
  String? _category;
  AssetStatus _status = AssetStatus.active;
  DateTime _purchaseDate = DateTime.now();
  String? _imageUrl;
  bool _isUploadingImage = false;

  bool get isEditing => widget.asset != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.asset?.name ?? '');
    _serialController = TextEditingController(text: widget.asset?.serialNumber ?? '');
    _notesController = TextEditingController(text: widget.asset?.notes ?? '');
    _priceController = TextEditingController(
      text: widget.asset?.purchasePrice?.toString() ?? '',
    );
    _category = widget.asset?.category;
    _status = widget.asset?.status ?? AssetStatus.active;
    _purchaseDate = widget.asset?.purchaseDate ?? DateTime.now();
    _imageUrl = widget.asset?.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _serialController.dispose();
    _notesController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final service = StorageService();
    final file = await service.pickImage();
    if (file == null) return;

    setState(() => _isUploadingImage = true);
    try {
      final url = await service.uploadAssetImage(
        file,
        widget.asset?.id ?? 'new_${DateTime.now().millisecondsSinceEpoch}',
      );
      setState(() {
        _imageUrl = url;
        _isUploadingImage = false;
      });
    } catch (e) {
      setState(() => _isUploadingImage = false);
      if (mounted) {
        Helpers.showSnackBar(context, 'Failed to upload image', isError: true);
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _purchaseDate = picked);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_category == null) {
      Helpers.showSnackBar(context, 'Please select a category', isError: true);
      return;
    }

    final currentUser = ref.read(authNotifierProvider).user;
    final now = DateTime.now();
    final asset = AssetModel(
      id: widget.asset?.id ?? '',
      name: _nameController.text.trim(),
      category: _category!,
      serialNumber: _serialController.text.trim(),
      purchaseDate: _purchaseDate,
      status: _status,
      companyId: widget.asset?.companyId ?? currentUser?.companyId ?? 'default',
      assignedEmployeeId: widget.asset?.assignedEmployeeId,
      assignedEmployeeName: widget.asset?.assignedEmployeeName,
      imageUrl: _imageUrl,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      purchasePrice: double.tryParse(_priceController.text.trim()),
      createdAt: widget.asset?.createdAt ?? now,
      updatedAt: now,
    );

    final notifier = ref.read(assetNotifierProvider.notifier);
    final success = isEditing
        ? await notifier.updateAsset(asset)
        : await notifier.addAsset(asset);

    if (success && mounted) {
      Helpers.showSnackBar(context, AppStrings.saved);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(assetNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? AppStrings.editAsset : AppStrings.addAsset),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Image upload
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 2,
                    // style: BorderStyle.solid,
                  ),
                ),
                child: _isUploadingImage
                    ? const Center(child: CircularProgressIndicator())
                    : _imageUrl != null
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.network(
                                  _imageUrl!,
                                  width: double.infinity,
                                  height: 160,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.black54,
                                  child: IconButton(
                                    icon: const Icon(Icons.close,
                                        size: 16, color: Colors.white),
                                    onPressed: () =>
                                        setState(() => _imageUrl = null),
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 40,
                                color: isDark
                                    ? AppColors.textOnDarkMuted
                                    : AppColors.textMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to upload image',
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.textOnDarkMuted
                                      : AppColors.textMedium,
                                ),
                              ),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 24),

            CustomTextField(
              controller: _nameController,
              label: AppStrings.assetName,
              hint: 'MacBook Pro 16"',
              prefixIcon: Icons.inventory_2_outlined,
              validator: Validators.name,
            ),
            const SizedBox(height: 20),

            CustomDropdownField<String>(
              label: AppStrings.category,
              value: _category,
              prefixIcon: Icons.category_outlined,
              items: AppStrings.assetCategories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v),
              validator: (v) => v == null ? 'Select category' : null,
            ),
            const SizedBox(height: 20),

            CustomTextField(
              controller: _serialController,
              label: AppStrings.serialNumber,
              hint: 'SN-2024-001',
              prefixIcon: Icons.tag,
              validator: Validators.serialNumber,
            ),
            const SizedBox(height: 20),

            // Purchase Date
            CustomTextField(
              controller: TextEditingController(
                text: Helpers.formatDate(_purchaseDate),
              ),
              label: AppStrings.purchaseDate,
              prefixIcon: Icons.calendar_today_outlined,
              readOnly: true,
              onTap: _selectDate,
            ),
            const SizedBox(height: 20),

            // Status
            CustomDropdownField<AssetStatus>(
              label: AppStrings.status,
              value: _status,
              prefixIcon: Icons.info_outline,
              items: AssetStatus.values
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Row(
                          children: [
                            Icon(s.icon, size: 16, color: s.color),
                            const SizedBox(width: 8),
                            Text(s.label),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _status = v);
              },
            ),
            const SizedBox(height: 20),

            CustomTextField(
              controller: _priceController,
              label: 'Purchase Price (Optional)',
              hint: '49999.00',
              prefixIcon: Icons.attach_money_rounded,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            CustomTextField(
              controller: _notesController,
              label: 'Notes (Optional)',
              hint: 'Any additional notes...',
              prefixIcon: Icons.notes_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 40),

            GradientButton(
              text: isEditing ? 'Update Asset' : 'Add Asset',
              isLoading: formState.isLoading,
              icon: isEditing ? Icons.save_rounded : Icons.add_rounded,
              onPressed: _handleSave,
            ),
          ],
        ),
      ),
    );
  }
}
