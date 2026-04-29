enum LogAction {
  created,
  updated,
  deleted,
  assigned,
  unassigned,
  returned,
  repaired,
  retired,
  scanned,
  exported,
  imported,
  login,
  logout;

  String get label {
    switch (this) {
      case LogAction.created:
        return 'Created';
      case LogAction.updated:
        return 'Updated';
      case LogAction.deleted:
        return 'Deleted';
      case LogAction.assigned:
        return 'Assigned';
      case LogAction.unassigned:
        return 'Unassigned';
      case LogAction.returned:
        return 'Returned';
      case LogAction.repaired:
        return 'Sent for Repair';
      case LogAction.retired:
        return 'Retired';
      case LogAction.scanned:
        return 'Scanned';
      case LogAction.exported:
        return 'Exported';
      case LogAction.imported:
        return 'Imported';
      case LogAction.login:
        return 'Logged In';
      case LogAction.logout:
        return 'Logged Out';
    }
  }

  static LogAction fromString(String value) {
    return LogAction.values.firstWhere(
      (e) => e.name == value,
      orElse: () => LogAction.updated,
    );
  }
}
