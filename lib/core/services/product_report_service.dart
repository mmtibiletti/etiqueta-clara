import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_report.dart';

class ProductReportService {

  final _firestore = FirebaseFirestore.instance;

  Future<void> reportProduct({
    required String productId,
    required ProductReport report,
  }) async {
    await _firestore
        .collection("productReports")
        .doc(productId)
        .collection("reports")
        .add(report.toJson());
  }

  Future<Map<String,int>> getUnsafeVotes(String productId) async {

    final snapshot = await _firestore
        .collection("productReports")
        .doc(productId)
        .collection("reports")
        .get();

    Map<String,int> votes = {};

    for (var doc in snapshot.docs) {
      final intolerance = doc["intolerance"];
      final vote = doc["vote"];
      if (vote != "unsafe") continue;
      votes[intolerance] = (votes[intolerance] ?? 0) + 1;
    }
    return votes;
  }
}