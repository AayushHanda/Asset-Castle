import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/enums/asset_status.dart';
import '../../domain/enums/log_action.dart';
import '../constants/app_colors.dart';

class Helpers {
  Helpers._();

  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return DateFormat('dd MMM').format(date);
  }

  static Color getStatusColor(AssetStatus status) {
    return status.color;
  }

  static IconData getLogActionIcon(LogAction action) {
    switch (action) {
      case LogAction.created:
        return Icons.add_circle_outline;
      case LogAction.updated:
        return Icons.edit_outlined;
      case LogAction.deleted:
        return Icons.delete_outline;
      case LogAction.assigned:
        return Icons.person_add_outlined;
      case LogAction.unassigned:
        return Icons.person_remove_outlined;
      case LogAction.returned:
        return Icons.assignment_return_outlined;
      case LogAction.repaired:
        return Icons.build_outlined;
      case LogAction.retired:
        return Icons.cancel_outlined;
      case LogAction.scanned:
        return Icons.qr_code_scanner;
      case LogAction.exported:
        return Icons.file_download_outlined;
      case LogAction.imported:
        return Icons.file_upload_outlined;
      case LogAction.login:
        return Icons.login;
      case LogAction.logout:
        return Icons.logout;
    }
  }

  static Color getLogActionColor(LogAction action) {
    switch (action) {
      case LogAction.created:
        return AppColors.success;
      case LogAction.updated:
        return AppColors.primary;
      case LogAction.deleted:
        return AppColors.error;
      case LogAction.assigned:
        return AppColors.secondary;
      case LogAction.unassigned:
        return AppColors.warning;
      case LogAction.returned:
        return AppColors.secondary;
      case LogAction.repaired:
        return AppColors.warning;
      case LogAction.retired:
        return AppColors.retired;
      case LogAction.scanned:
        return AppColors.primary;
      case LogAction.exported:
        return AppColors.success;
      case LogAction.imported:
        return AppColors.success;
      case LogAction.login:
        return AppColors.success;
      case LogAction.logout:
        return AppColors.textMedium;
    }
  }

  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : null,
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Delete',
    Color confirmColor = AppColors.error,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
