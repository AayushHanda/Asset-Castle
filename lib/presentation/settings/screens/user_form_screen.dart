import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../domain/enums/user_role.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/user_provider.dart';

class UserFormScreen extends ConsumerStatefulWidget {
  const UserFormScreen({super.key});

  @override
  ConsumerState<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends ConsumerState<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController(text: 'Password123!'); // Default password
  final _companyController = TextEditingController();
  final _deptController = TextEditingController();
  final _designationController = TextEditingController();
  
  UserRole? _selectedRole;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _companyController.dispose();
    _deptController.dispose();
    _designationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(userNotifierProvider);
    final currentUser = ref.watch(authNotifierProvider).user;
    
    // Determine which roles the current user can create
    List<UserRole> availableRoles = [];
    if (currentUser?.role == UserRole.admin) {
      availableRoles = [UserRole.itDepartment, UserRole.engineer, UserRole.employee];
    } else if (currentUser?.role == UserRole.itDepartment) {
      availableRoles = [UserRole.engineer, UserRole.employee];
    } else if (currentUser?.role == UserRole.engineer) {
      availableRoles = [UserRole.employee];
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Create User Account')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            CustomTextField(
              controller: _nameController,
              label: 'Full Name',
              hint: 'John Doe',
              prefixIcon: Icons.person_outline,
              validator: Validators.name,
            ),
            const SizedBox(height: 20),
            
            CustomTextField(
              controller: _emailController,
              label: 'Email Address',
              hint: 'john@example.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
            ),
            const SizedBox(height: 20),

            CustomTextField(
              controller: _passwordController,
              label: 'Initial Password',
              hint: 'Min 6 characters',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              validator: (v) => (v?.length ?? 0) < 6 ? 'Password too short' : null,
            ),
            const SizedBox(height: 20),

            CustomDropdownField<UserRole>(
              label: 'User Role',
              value: _selectedRole,
              items: availableRoles.map((r) => DropdownMenuItem(value: r, child: Text(r.label))).toList(),
              onChanged: (v) => setState(() => _selectedRole = v),
              prefixIcon: Icons.admin_panel_settings_outlined,
              validator: (v) => v == null ? 'Please select a role' : null,
            ),
            const SizedBox(height: 20),

            if (currentUser?.role == UserRole.admin) 
              CustomTextField(
                controller: _companyController,
                label: 'Company Identifier',
                hint: 'e.g. google, tcs, apple',
                prefixIcon: Icons.business_outlined,
                validator: (v) => (v?.isEmpty ?? true) ? 'Required for new IT Dept' : null,
              ),
            
            const SizedBox(height: 20),
            CustomTextField(
              controller: _deptController,
              label: 'Department (Optional)',
              hint: 'IT, HR, Sales',
              prefixIcon: Icons.account_tree_outlined,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _designationController,
              label: 'Designation (Optional)',
              hint: 'Software Engineer',
              prefixIcon: Icons.badge_outlined,
            ),
            
            const SizedBox(height: 40),
            GradientButton(
              text: 'Create Account',
              isLoading: formState.isLoading,
              onPressed: _handleCreate,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;
    
    final currentUser = ref.read(authNotifierProvider).user;
    // If admin, use entered company. Otherwise, use current user's company.
    final companyId = currentUser?.role == UserRole.admin 
      ? _companyController.text.trim().toLowerCase()
      : currentUser?.companyId ?? 'default';

    final success = await ref.read(userNotifierProvider.notifier).createUser(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
      role: _selectedRole!,
      companyId: companyId,
      department: _deptController.text.trim().isEmpty ? null : _deptController.text.trim(),
      designation: _designationController.text.trim().isEmpty ? null : _designationController.text.trim(),
    );

    if (success && context.mounted) {
      Navigator.pop(context);
      Helpers.showSnackBar(
        context,
        'Account created successfully',
      );
    } else if (context.mounted) {
      Helpers.showSnackBar(
        context,
        ref.read(userNotifierProvider).error ?? 'Failed to create user',
        isError: true,
      );
    }
  }
}
