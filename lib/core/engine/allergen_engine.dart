import '../models/product.dart';
import '../models/evaluation_result.dart';
import '../models/ingredient_rule.dart';

const int defaultConfidence = 50;

class AllergenEngine {

  EvaluationDetail evaluate({
    required Product product,
    required List<IngredientRule> rules,
  }) {

    RiskStatus status = RiskStatus.green;

    List<String> directMatches = [];
    List<String> traceMatches = [];

    final normalizedIngredients =
    product.ingredients.map((e) => e.toLowerCase()).toList();
    for (var ingredient in normalizedIngredients) {
      for (var rule in rules) {
        for (var keyword in rule.keywords) {
          if (ingredient.contains(keyword)) {
            status = RiskStatus.red;
            directMatches.add(rule.display);
          }
        }
      }
    }

    return EvaluationDetail(
      status: status,
      directMatches: directMatches,
      traceMatches: traceMatches,
      confidence: defaultConfidence,
    );

  }
}