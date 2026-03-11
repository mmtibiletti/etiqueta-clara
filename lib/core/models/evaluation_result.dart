enum RiskStatus {
  green,
  yellow,
  red
}

class EvaluationResult {
  final Map<String, EvaluationDetail> results;
  EvaluationResult({ required this.results,});
  RiskStatus get globalStatus {
    if (results.values.any((e) => e.status == RiskStatus.red))
    {
      return RiskStatus.red;
    }
    if (results.values.any((e) => e.status == RiskStatus.yellow))
    {
      return RiskStatus.yellow;
    }
    return RiskStatus.green;
  }
}

class EvaluationDetail {
  final RiskStatus status;
  final List<String> directMatches;
  final List<String> traceMatches;
  final int confidence;
  bool get hasAlerts => directMatches.isNotEmpty ||
      traceMatches.isNotEmpty;
  EvaluationDetail({
    required this.status,
    required this.directMatches,
    required this.traceMatches,
    required this.confidence,
  });
}