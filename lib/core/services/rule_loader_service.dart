import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/ingredient_rule.dart';

class RuleLoaderService {

  Future<List<String>> loadSafeGlutenIngredients() async {

    final jsonString =
    await rootBundle.loadString('assets/rules/safe_gluten_ingredients.json');

    final data = jsonDecode(jsonString);

    return List<String>.from(data['safe']);
  }

  Future<List<IngredientRule>> loadRules(String filename) async {

    final jsonString =
    await rootBundle.loadString('assets/rules/$filename');

    final data = jsonDecode(jsonString);

    return (data['rules'] as List)
        .map((e) => IngredientRule.fromJson(e))
        .toList();
  }

  /// 🔥 Carga todas las intolerancias
  Future<Map<String, List<IngredientRule>>> loadAllRules() async {

    final intolerances = {
      "gluten": "gluten_rules.json",
      "lactose": "lactose_rules.json",
      "egg": "egg_rules.json",
      "nuts": "nuts_rules.json",
      "soy": "soy_rules.json",
    };

    Map<String, List<IngredientRule>> result = {};

    for (final entry in intolerances.entries) {
      result[entry.key] = await loadRules(entry.value);
    }

    return result;
  }
}