/// Maps to Firestore `users/{uid}/roadmaps/{id}` (see DESIGN_PLAN.md §5).
///
/// PLACEHOLDER model.
class Roadmap {
  const Roadmap({
    required this.id,
    required this.steps,
    this.createdAt,
  });

  final String id;
  final List<RoadmapStep> steps;
  final DateTime? createdAt;

  factory Roadmap.fromMap(String id, Map<String, dynamic> map) {
    // TODO: parse steps list.
    return Roadmap(id: id, steps: const []);
  }
}

/// A single actionable step, grouped by timeframe (e.g. "First Month").
class RoadmapStep {
  const RoadmapStep({
    required this.timeframe,
    required this.title,
    this.done = false,
  });

  final String timeframe;
  final String title;
  final bool done;
}
