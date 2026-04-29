enum UserRole {
  admin,
  itDepartment,
  engineer,
  employee;

  String get label {
    switch (this) {
      case UserRole.admin:
        return 'System Admin';
      case UserRole.itDepartment:
        return 'IT Department';
      case UserRole.engineer:
        return 'Engineer';
      case UserRole.employee:
        return 'Employee';
    }
  }

  // Permissions
  bool get canWrite => this == admin || this == itDepartment || this == engineer;
  bool get canDelete => this == admin || this == itDepartment;
  bool get canManageUsers => this == admin || this == itDepartment || this == engineer;
  bool get canManageIT => this == admin;
  bool get canDeleteUsers => this == admin || this == itDepartment;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UserRole.employee,
    );
  }
}
