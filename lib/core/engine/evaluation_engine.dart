import '../models/product.dart';
import '../models/user_profile.dart';
import '../models/evaluation_result.dart';
import '../models/ingredient_rule.dart';

class EvaluationEngine {

  final Map<String, List<IngredientRule>> intoleranceRules;
  final List<String> safeGlutenIngredients;

  EvaluationEngine({
    required this.intoleranceRules,
    required this.safeGlutenIngredients,
  });

  EvaluationResult evaluate(Product product, UserProfile profile) {

    Map<String, EvaluationDetail> results = {};

    intoleranceRules.forEach((intolerance, rules) {

      final detail = _evaluateAllergen(
        product: product,
        rules: rules,
        intoleranceName: intolerance,
      );

      results[intolerance] = detail;
    });

    return EvaluationResult(results: results);
  }

  EvaluationDetail _evaluateAllergen({
    required Product product,
    required List<IngredientRule> rules,
    required String intoleranceName,
  }) {

    int score = 0;
    int confidence = 0;

    List<String> directMatches = [];
    List<String> traceMatches = [];

    final ingredients =
    product.ingredients.map((e) => e.toLowerCase()).toList();

    if (product.ingredients.isNotEmpty) confidence += 40;
    if (product.ingredientsAnalysisTags != null) confidence += 30;
    if (product.allergens != null) confidence += 20;
    if (product.traces != null) confidence += 10;

    /// INGREDIENTES
    for (var ingredient in ingredients) {
      for (var rule in rules) {
        for (var keyword in rule.keywords) {
          if (ingredient.contains(keyword)) {
            score += 100;
            directMatches.add("Contiene ${rule.display}");
          }
        }
      }
    }

    /// CERTIFICACIÓN SIN GLUTEN
    if (intoleranceName == "gluten" &&
        _isCertifiedGlutenFree(product)) {
      score -= 80;
      directMatches.add(
        "Producto certificado sin gluten",
      );
    }

    /// TRAZAS
    if (product.traces != null &&
        product.traces!.contains("en:$intoleranceName")) {
      score += 40;
      traceMatches.add("Puede contener trazas de $intoleranceName");
    }

    RiskStatus status;

    if (score >= 80) {
      status = RiskStatus.red;
    } else if (score >= 30) {
      status = RiskStatus.yellow;
    } else {
      status = RiskStatus.green;
    }

    return EvaluationDetail(
      status: status,
      directMatches: directMatches,
      traceMatches: traceMatches,
      confidence: confidence,
    );
  }

  bool _isCertifiedGlutenFree(Product product) {
    if (product.labels == null) return false;
    final labels = product.labels?.join(" ").toLowerCase() ?? "";

    if (labels.contains("gluten-free") ||
        labels.contains("sin gluten") ||
        labels.contains("no-gluten")) {
      return true;
    }

    return false;
  }
}