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

  Future<List<IngredientRule>> loadGlutenRules() async {
    final jsonString =
    await rootBundle.loadString('assets/rules/gluten_rules.json');

    final data = jsonDecode(jsonString);

    return (data['rules'] as List)
        .map((e) => IngredientRule.fromJson(e))
        .toList();
  }

  Future<List<IngredientRule>> loadLactoseRules() async {
    final jsonString =
    await rootBundle.loadString('assets/rules/lactose_rules.json');

    final data = jsonDecode(jsonString);

    return (data['rules'] as List)
        .map((e) => IngredientRule.fromJson(e))
        .toList();
  }
}