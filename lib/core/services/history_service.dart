import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/history_item.dart';
import '../models/product.dart';
import '../models/evaluation_result.dart';

class HistoryService {
  static const _key = "scan_history";
  final _firestore = FirebaseFirestore.instance;

  Future<void> saveScan({
    required String barcode,
    required Product product,
    required EvaluationResult result,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final existing = await getHistory();

    final item = HistoryItem(
      barcode: barcode,
      name: product.name,
      brand: product.brand,
      status: result.globalStatus.name,
      date: DateTime.now(),
    );

    existing.insert(0, item);

    // limitamos a 50 registros
    final limited = existing.take(50).toList();

    final jsonList =
    limited.map((e) => jsonEncode(e.toJson())).toList();

    await prefs.setStringList(_key, jsonList);

    // 🔥 NUEVO: Guardado en Firestore
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('scans')
          .add(item.toJson());
    }
  }

  Future<List<HistoryItem>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();

    final list = prefs.getStringList(_key);

    if (list == null) return [];

    return list
        .map((e) => HistoryItem.fromJson(jsonDecode(e)))
        .toList();
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<List<HistoryItem>> loadFromCloud() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('scans')
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => HistoryItem.fromJson(doc.data()))
        .toList();
  }

  Future<void> replaceLocalHistory(List<HistoryItem> items) async {
    final prefs = await SharedPreferences.getInstance();

    final jsonList =
    items.map((e) => jsonEncode(e.toJson())).toList();

    await prefs.setStringList(_key, jsonList);
  }
}