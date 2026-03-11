import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/ingredient_rule.dart';

class RuleLoaderService {
  Future<List<IngredientRule>> loadRules(String intolerance)
  async {
    final jsonString =
    await rootBundle.loadString('assets/rules/${intolerance}_rules.json');
    final data = jsonDecode(jsonString);
    return (data['rules'] as List)
        .map((e) => IngredientRule.fromJson(e))
        .toList();
  }

  Future<List<String>> loadSafeGlutenIngredients()
  async {
    final jsonString = await rootBundle.loadString(
        'assets/rules/safe_gluten_ingredients.json');
    final data = jsonDecode(jsonString);

    return List<String>.from(data['safe']);
  }
}
