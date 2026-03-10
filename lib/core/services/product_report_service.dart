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
}