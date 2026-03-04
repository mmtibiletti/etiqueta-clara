enum RiskStatus { green, yellow, red }

class EvaluationDetail {
  final RiskStatus status;
  final List<String> directMatches;
  final List<String> traceMatches;
  final int confidence;

  const EvaluationDetail({
    required this.status,
    required this.directMatches,
    required this.traceMatches,
    required this.confidence,
  });

  bool get hasDirect => directMatches.isNotEmpty;
  bool get hasTraces => traceMatches.isNotEmpty;
  bool get hasAlerts => hasDirect || hasTraces;
}

class EvaluationResult {

  final Map<String, EvaluationDetail> results;

  const EvaluationResult({
    required this.results,
  });

  RiskStatus get globalStatus {

    final statuses = results.values
        .map((e) => e.status)
        .toList();

    if (statuses.contains(RiskStatus.red)) {
      return RiskStatus.red;
    }

    if (statuses.contains(RiskStatus.yellow)) {
      return RiskStatus.yellow;
    }

    return RiskStatus.green;
  }
}