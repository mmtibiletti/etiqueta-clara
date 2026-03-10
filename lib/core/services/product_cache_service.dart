import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class ProductCacheService {

  static const _key = "product_cache";

  Future<Product?> getProduct(String barcode) async {
    final prefs = await SharedPreferences.getInstance();
    final cache = prefs.getString(_key);

    if (cache == null) return null;

    final Map<String,dynamic> data = jsonDecode(cache);

    if (!data.containsKey(barcode)) return null;

    return Product.fromJson(data[barcode]);
  }

  Future<void> saveProduct(Product product) async {
    final prefs = await SharedPreferences.getInstance();
    final cache = prefs.getString(_key);

    Map<String,dynamic> data = {};

    if (cache != null) {
      data = jsonDecode(cache);
    }

    data[product.barcode ?? product.id] = product.toJson();

    await prefs.setString(_key, jsonEncode(data));
  }

}