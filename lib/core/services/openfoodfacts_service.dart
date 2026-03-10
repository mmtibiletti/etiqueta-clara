import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/log_service.dart';
import 'product_cache_service.dart';

import '../models/product.dart';

class OpenFoodFactsService {
  Future<Product?> fetchProduct(String barcode) async {
    final cache = ProductCacheService();
    final cached = await cache.getProduct(barcode);

    // 🔹 Primero buscamos en base propia
    final manualDoc = await FirebaseFirestore.instance
        .collection('manual_products')
        .doc(barcode)
        .get();

    if (manualDoc.exists) {
      LogService.info("📦 Producto encontrado en base local");
      final data = manualDoc.data()!;

      final product = Product(
        id: barcode,
        barcode: barcode,
        name: data['name'],
        brand: data['brand'],
        ingredients: List<String>.from(data['ingredients']),
        source: 'manual',
        status: data['status'],
        createdByUid: data['createdBy'],
        createdByNickname: data['createdByNickname'],
        createdByAvatar: data['createdByAvatar'],
      );

      return product;
    }
    try {
      LogService.info("🔎 Consultando OpenFoodFacts V2 para: $barcode");

      if (cached != null) {
        LogService.info("⚡ Producto encontrado en CACHE");
        return cached;
      }

      final url = Uri.parse(
        'https://world.openfoodfacts.org/api/v2/product/$barcode',
      );

      final response = await http
          .get(url)
          .timeout(const Duration(seconds: 10));

      LogService.info("📡 Status code: ${response.statusCode}");

      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body);

      if (data['status'] != 1) {
        LogService.info("❌ Producto no encontrado en OFF");
        return null;
      }

      final productData = data['product'];

      /// 🔹 Nombre con fallback inteligente
      final String name =
          productData['product_name'] ??
              productData['product_name_es'] ??
              productData['product_name_fr'] ??
              productData['generic_name'] ??
              productData['brands'] ??
              'Producto sin nombre';

      /// 🔹 Marca
      final String? brand =
      productData['brands']?.toString();

      /// 🔹 Imagen (V2 estructura diferente)
      final String? imageUrl =
          productData['image_front_url'] ??
              productData['image_url'] ??
              productData['image_small_url'] ??
              productData['images']?['front']?['display'];

      /// 🔹 Ingredientes estructurados (mejor que ingredients_text)
      List<String> ingredientsList = [];

      if (productData['ingredients'] is List) {
        ingredientsList = (productData['ingredients'] as List)
            .map((e) => e['text']?.toString() ?? '')
            .where((e) => e.isNotEmpty)
            .toList();
      } else {
        final rawIngredients = productData['ingredients_text'];

        if (rawIngredients is String) {
          ingredientsList =
              rawIngredients.split(',').map((e) => e.trim()).toList();
        }
      }

      /// 🔹 Alergenos estructurados
      List<String>? allergens;

      if (productData['allergens_tags'] is List) {
        allergens = (productData['allergens_tags'] as List)
            .map((e) => e.toString())
            .toList();
      }

      List<String>? traces;

      if (productData['traces_tags'] is List) {
        traces = (productData['traces_tags'] as List)
            .map((e) => e.toString())
            .toList();
      }

      final labels = productData['labels_tags'];
      final ingredientsAnalysisTags =
        productData['ingredients_analysis_tags'];

      LogService.info("✅ Nombre: $name");

      final product= Product(
        id: barcode,
        barcode: barcode,
        name: name,
        brand: brand,
        imageUrl: imageUrl,
        ingredients: ingredientsList,
        ingredientsAnalysisTags: ingredientsAnalysisTags != null
            ? List<String>.from(ingredientsAnalysisTags)
            : null,
        allergens: allergens,
        traces: traces,
        labels: labels != null
            ? List<String>.from(labels)
            : null,
      );
      await cache.saveProduct(product);
      return product;
    } catch (e) {
      LogService.error("❌ Error OpenFoodFacts V2: $e");
      return null;
    }
  }
}