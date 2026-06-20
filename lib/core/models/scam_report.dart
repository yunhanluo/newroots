/// Risk levels returned by the ScamShield AI (see DESIGN_PLAN.md §6).
enum RiskLevel { low, moderate, high }

/// Maps to Firestore `users/{uid}/scamReports/{id}`.
///
/// PLACEHOLDER model.
class ScamReport {
  const ScamReport({
    required this.id,
    required this.riskLevel,
    this.reasons = const [],
    this.recommendedActions = const [],
    this.isPublic = false,
    this.createdAt,
  });

  final String id;
  final RiskLevel riskLevel;
  final List<String> reasons;
  final List<String> recommendedActions;
  final bool isPublic;
  final DateTime? createdAt;

  factory ScamReport.fromMap(String id, Map<String, dynamic> map) {
    // TODO: parse risk level + lists.
    return ScamReport(id: id, riskLevel: RiskLevel.low);
  }
}
