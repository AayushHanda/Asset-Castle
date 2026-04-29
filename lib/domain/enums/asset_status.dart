import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum AssetStatus {
  active,
  repair,
  retired;

  String get label {
    switch (this) {
      case AssetStatus.active:
        return 'Active';
      case AssetStatus.repair:
        return 'In Repair';
      case AssetStatus.retired:
        return 'Retired';
    }
  }

  Color get color {
    switch (this) {
      case AssetStatus.active:
        return AppColors.active;
      case AssetStatus.repair:
        return AppColors.repair;
      case AssetStatus.retired:
        return AppColors.retired;
    }
  }

  IconData get icon {
    switch (this) {
      case AssetStatus.active:
        return Icons.check_circle_rounded;
      case AssetStatus.repair:
        return Icons.build_circle_rounded;
      case AssetStatus.retired:
        return Icons.cancel_rounded;
    }
  }

  static AssetStatus fromString(String value) {
    return AssetStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AssetStatus.active,
    );
  }
}
