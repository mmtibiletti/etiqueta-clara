import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/ingredient_rule.dart';

class RuleLoaderService {

  /// Carga reglas de una intolerancia concreta
  Future<List<IngredientRule>> loadRules(String intolerance)
  async {
    final jsonString = await rootBundle.loadString(
        'assets/rules/${intolerance}_rules.json');

    final data = jsonDecode(jsonString);

    return (data['rules'] as List)
        .map((e) => IngredientRule.fromJson(e))
        .toList();
  }

  /// Carga ingredientes naturalmente sin gluten
  Future<List<String>> loadSafeGlutenIngredients()
  async {
    final jsonString = await rootBundle.loadString(
        'assets/rules/safe_gluten_ingredients.json');

    final data = jsonDecode(jsonString);

    return List<String>.from(data['safe']);
  }

  /// 🔥 Carga todas las reglas del sistema
  Future<Map<String, List<IngredientRule>>> loadAllRules()
  async {
    final intolerances = [ "gluten", "lactose", "egg", "nuts", "soy", ];
    Map<String, List<IngredientRule>> rules = {};
    for (final intolerance in intolerances) {
      rules[intolerance] = await loadRules(intolerance);
    }
    return rules;
  }
}
