class AppStrings {
  AppStrings._();

  static const String appName = 'Asset Castle';
  static const String appTagline = 'Enterprise Asset Management';

  // Auth
  static const String login = 'Login';
  static const String logout = 'Logout';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String loginButton = 'Sign In';
  static const String loginSubtitle = 'Sign in to manage your assets';

  // Dashboard
  static const String dashboard = 'Dashboard';
  static const String totalAssets = 'Total Assets';
  static const String assignedAssets = 'Assigned';
  static const String unassignedAssets = 'Unassigned';
  static const String activeAssets = 'Active';
  static const String inRepair = 'In Repair';
  static const String retired = 'Retired';
  static const String recentActivity = 'Recent Activity';
  static const String categoryDistribution = 'Category Distribution';
  static const String departmentUsage = 'Department Usage';

  // Employees
  static const String employees = 'Employees';
  static const String addEmployee = 'Add Employee';
  static const String editEmployee = 'Edit Employee';
  static const String deleteEmployee = 'Delete Employee';
  static const String employeeName = 'Employee Name';
  static const String department = 'Department';
  static const String designation = 'Designation';

  // Assets
  static const String assets = 'Assets';
  static const String addAsset = 'Add Asset';
  static const String editAsset = 'Edit Asset';
  static const String deleteAsset = 'Delete Asset';
  static const String assetName = 'Asset Name';
  static const String category = 'Category';
  static const String serialNumber = 'Serial Number';
  static const String purchaseDate = 'Purchase Date';
  static const String status = 'Status';
  static const String assignedTo = 'Assigned To';
  static const String assetImage = 'Asset Image';

  // QR
  static const String qrCode = 'QR Code';
  static const String scanQR = 'Scan QR';
  static const String generateQR = 'Generate QR';
  static const String downloadQR = 'Download QR';
  static const String shareQR = 'Share QR';

  // Scanner
  static const String scanner = 'Scanner';
  static const String scanAsset = 'Scan Asset QR';
  static const String pointCamera = 'Point camera at asset QR code';

  // Audit
  static const String auditLog = 'Audit Log';
  static const String assetHistory = 'Asset History';

  // Settings
  static const String settings = 'Settings';
  static const String darkMode = 'Dark Mode';
  static const String notifications = 'Notifications';
  static const String about = 'About';
  static const String version = 'Version 1.0.0';
  static const String bulkImport = 'Bulk Import';

  // Messages
  static const String noAssets = 'No assets found';
  static const String noEmployees = 'No employees found';
  static const String noLogs = 'No activity logs';
  static const String confirmDelete = 'Are you sure you want to delete?';
  static const String saved = 'Saved successfully';
  static const String deleted = 'Deleted successfully';
  static const String error = 'An error occurred';
  static const String loading = 'Loading...';
  static const String searchHint = 'Search...';

  // Categories
  static const List<String> assetCategories = [
    'Laptop',
    'Desktop',
    'Monitor',
    'Keyboard',
    'Mouse',
    'Phone',
    'Tablet',
    'Printer',
    'Server',
    'Networking',
    'Furniture',
    'Vehicle',
    'Software License',
    'Other',
  ];

  // Departments
  static const List<String> departments = [
    'Engineering',
    'Design',
    'Marketing',
    'Sales',
    'HR',
    'Finance',
    'Operations',
    'IT',
    'Legal',
    'Management',
    'Other',
  ];
}
