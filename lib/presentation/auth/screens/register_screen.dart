import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/helpers.dart';
import '../../../domain/enums/user_role.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _companyController = TextEditingController();
  final _deptController = TextEditingController();
  final _designationController = TextEditingController();
  
  UserRole _selectedRole = UserRole.employee;
  bool _obscurePassword = true;

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

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final companyId = _selectedRole == UserRole.admin 
        ? 'system' 
        : _companyController.text.trim().toLowerCase();

    final success = await ref.read(authNotifierProvider.notifier).signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
      role: _selectedRole,
      companyId: companyId,
      department: _deptController.text.trim().isEmpty ? null : _deptController.text.trim(),
      designation: _designationController.text.trim().isEmpty ? null : _designationController.text.trim(),
    );

    if (success && mounted) {
      Helpers.showSnackBar(context, 'Registration successful!');
      // Navigator will be handled by auth state changes automatically usually, 
      // but let's pop to be safe if manually navigating.
      Navigator.pop(context);
    } else if (mounted) {
      final error = ref.read(authNotifierProvider).error;
      if (error != null) {
        Helpers.showSnackBar(context, error, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.darkGradient : const LinearGradient(
            colors: [Color(0xFFE8EAFF), Color(0xFFF5F7FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  // Header
                  Text(
                    'Join Asset Castle',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select your role and enter details',
                    style: TextStyle(
                      color: isDark ? AppColors.textOnDarkMuted : AppColors.textMedium,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Form Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard.withValues(alpha: 0.8) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Role Selection
                          CustomDropdownField<UserRole>(
                            label: 'Register as',
                            value: _selectedRole,
                            items: UserRole.values.map((role) {
                              return DropdownMenuItem(
                                value: role,
                                child: Text(role.label),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedRole = val);
                            },
                            prefixIcon: Icons.admin_panel_settings_outlined,
                          ),
                          const SizedBox(height: 20),

                          CustomTextField(
                            controller: _nameController,
                            label: 'Full Name',
                            hint: 'John Doe',
                            prefixIcon: Icons.person_outline,
                            validator: Validators.name,
                          ),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'john@example.com',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.email,
                          ),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: '••••••••',
                            prefixIcon: Icons.lock_outlined,
                            obscureText: _obscurePassword,
                            validator: Validators.password,
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          const SizedBox(height: 16),

                          if (_selectedRole != UserRole.admin) ...[
                            CustomTextField(
                              controller: _companyController,
                              label: 'Company Key',
                              hint: 'e.g. google, acme',
                              prefixIcon: Icons.business_outlined,
                              validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),
                          ],

                          CustomTextField(
                            controller: _deptController,
                            label: 'Department (Optional)',
                            hint: 'IT, HR, Sales',
                            prefixIcon: Icons.account_tree_outlined,
                          ),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: _designationController,
                            label: 'Designation (Optional)',
                            hint: 'Engineer, Manager',
                            prefixIcon: Icons.badge_outlined,
                          ),
                          const SizedBox(height: 32),

                          GradientButton(
                            text: 'Register',
                            isLoading: authState.isLoading,
                            onPressed: _handleRegister,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(color: isDark ? AppColors.textOnDarkMuted : AppColors.textMedium),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Login', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
