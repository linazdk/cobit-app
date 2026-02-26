// lib/workflow/audit_workflow.dart

import 'package:flutter/material.dart';

/// Audit status lifecycle
enum AuditStatus {
  draft, // Draft
  inProgress, // In progress
  inReview, // Under review
  validated, // Validated / Approved
}

/// Converts a string (from DB or previous versions)
/// into an [AuditStatus] enum value.
AuditStatus auditStatusFromString(String value) {
  switch (value.toLowerCase()) {
    case 'in progress':
    case 'inprogress':
      return AuditStatus.inProgress;
    case 'in review':
    case 'inreview':
      return AuditStatus.inReview;
    case 'validated':
    case 'approved':
      return AuditStatus.validated;
    case 'draft':
    default:
      return AuditStatus.draft;
  }
}

/// Returns the English label of the status.
String auditStatusToString(AuditStatus status) {
  switch (status) {
    case AuditStatus.draft:
      return 'Draft';
    case AuditStatus.inProgress:
      return 'In progress';
    case AuditStatus.inReview:
      return 'In review';
    case AuditStatus.validated:
      return 'Validated';
  }
}

/// Alias for consistency with your UI needs.
String auditStatusLabel(AuditStatus status) {
  return auditStatusToString(status);
}

/// Color associated with each audit status.
Color auditStatusColor(AuditStatus status) {
  switch (status) {
    case AuditStatus.draft:
      return Colors.grey;
    case AuditStatus.inProgress:
      return Colors.blue;
    case AuditStatus.inReview:
      return Colors.orange;
    case AuditStatus.validated:
      return Colors.green;
  }
}

/// Allowed transitions between audit statuses.
List<AuditStatus> allowedNextStatuses(AuditStatus current) {
  switch (current) {
    case AuditStatus.draft:
      // Draft → In progress
      return [AuditStatus.inProgress];

    case AuditStatus.inProgress:
      // In progress → In review (normal flow)
      // In progress → Draft (rollback to edit)
      return [AuditStatus.inReview, AuditStatus.draft];

    case AuditStatus.inReview:
      // In review → In progress (unlock for modification)
      // In review → Validated
      return [AuditStatus.inProgress, AuditStatus.validated];

    case AuditStatus.validated:
      // Validated = locked, no further transitions
      return [];
  }
}

/// Useful extensions for UI rendering.
extension AuditStatusX on AuditStatus {
  Color get color {
    switch (this) {
      case AuditStatus.draft:
        return Colors.grey;
      case AuditStatus.inProgress:
        return Colors.blue;
      case AuditStatus.inReview:
        return Colors.orange;
      case AuditStatus.validated:
        return Colors.green;
    }
  }

  String get label {
    switch (this) {
      case AuditStatus.draft:
        return "Draft";
      case AuditStatus.inProgress:
        return "In progress";
      case AuditStatus.inReview:
        return "In review";
      case AuditStatus.validated:
        return "Validated";
    }
  }
}
