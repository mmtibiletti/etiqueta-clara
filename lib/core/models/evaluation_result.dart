class EvaluationResult {

  final Map<String, EvaluationDetail> results;

  const EvaluationResult({
    required this.results,
  });

  RiskStatus get globalStatus {

    final statuses = results.values.map((e) => e.status);

    if (statuses.contains(RiskStatus.red)) return RiskStatus.red;
    if (statuses.contains(RiskStatus.yellow)) return RiskStatus.yellow;

    return RiskStatus.green;
  }
}