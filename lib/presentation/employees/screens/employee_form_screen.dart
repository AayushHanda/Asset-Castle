import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/employee_model.dart';
import '../providers/employee_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../data/services/storage_service.dart';

class EmployeeFormScreen extends ConsumerStatefulWidget {
  final EmployeeModel? employee;

  const EmployeeFormScreen({super.key, this.employee});

  @override
  ConsumerState<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends ConsumerState<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  String? _department;
  late TextEditingController _designationController;
  String? _photoUrl;
  bool _isUploadingPhoto = false;

  bool get isEditing => widget.employee != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.employee?.name ?? '');
    _emailController = TextEditingController(text: widget.employee?.email ?? '');
    _department = widget.employee?.department;
    _designationController =
        TextEditingController(text: widget.employee?.designation ?? '');
    _photoUrl = widget.employee?.photoUrl;
  }

  Future<void> _pickImage() async {
    final service = StorageService();
    final file = await service.pickImage();
    if (file == null) return;

    setState(() => _isUploadingPhoto = true);
    try {
      final url = await service.uploadEmployeePhoto(
        file,
        widget.employee?.id ?? 'new_emp_${DateTime.now().millisecondsSinceEpoch}',
      );
      setState(() {
        _photoUrl = url;
        _isUploadingPhoto = false;
      });
    } catch (e) {
      setState(() => _isUploadingPhoto = false);
      if (mounted) {
        Helpers.showSnackBar(context, 'Failed to upload photo', isError: true);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _designationController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_department == null) {
      Helpers.showSnackBar(context, 'Please select a department', isError: true);
      return;
    }

    final currentUser = ref.read(authNotifierProvider).user;
    final now = DateTime.now();
    final employee = EmployeeModel(
      id: widget.employee?.id ?? '',
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      department: _department!,
      designation: _designationController.text.trim(),
      companyId: widget.employee?.companyId ?? currentUser?.companyId ?? 'default',
      assignedAssetCount: widget.employee?.assignedAssetCount ?? 0,
      photoUrl: _photoUrl,
      createdAt: widget.employee?.createdAt ?? now,
      updatedAt: now,
    );

    final notifier = ref.read(employeeNotifierProvider.notifier);
    final success = isEditing
        ? await notifier.updateEmployee(employee)
        : await notifier.addEmployee(employee);

    if (success && mounted) {
      Helpers.showSnackBar(context, AppStrings.saved);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(employeeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? AppStrings.editEmployee : AppStrings.addEmployee),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Photo Upload
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue.withValues(alpha: 0.2), width: 2),
                      ),
                      child: _isUploadingPhoto
                          ? const Center(child: CircularProgressIndicator())
                          : _photoUrl != null
                              ? ClipOval(
                                  child: Image.network(
                                    _photoUrl!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(Icons.person_add_alt_1_rounded,
                                  size: 40, color: Colors.blue),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            CustomTextField(
              controller: _nameController,
              label: AppStrings.employeeName,
              hint: 'John Doe',
              prefixIcon: Icons.person_outline,
              validator: Validators.name,
            ),
            const SizedBox(height: 20),

            CustomTextField(
              controller: _emailController,
              label: AppStrings.email,
              hint: 'john@company.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
            ),
            const SizedBox(height: 20),

            CustomDropdownField<String>(
              label: AppStrings.department,
              value: _department,
              prefixIcon: Icons.business_outlined,
              items: AppStrings.departments
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) => setState(() => _department = v),
              validator: (v) => v == null ? 'Select department' : null,
            ),
            const SizedBox(height: 20),

            CustomTextField(
              controller: _designationController,
              label: AppStrings.designation,
              hint: 'Senior Software Engineer',
              prefixIcon: Icons.badge_outlined,
              validator: (v) => Validators.required(v, 'Designation'),
            ),
            const SizedBox(height: 40),

            GradientButton(
              text: isEditing ? 'Update Employee' : 'Add Employee',
              isLoading: formState.isLoading,
              icon: isEditing ? Icons.save_rounded : Icons.person_add_rounded,
              onPressed: _handleSave,
            ),
          ],
        ),
      ),
    );
  }
}
