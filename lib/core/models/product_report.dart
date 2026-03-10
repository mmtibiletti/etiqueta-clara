class ProductReport {

  final String uid;
  final String intolerance;
  final String vote;
  final DateTime timestamp;

  ProductReport({
    required this.uid,
    required this.intolerance,
    required this.vote,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "intolerance": intolerance,
      "vote": vote,
      "timestamp": timestamp.toIso8601String(),
    };
  }

}