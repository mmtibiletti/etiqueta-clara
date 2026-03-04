import '../models/product.dart';
import '../models/user_profile.dart';
import '../models/evaluation_result.dart';
import '../models/ingredient_rule.dart';
import '../services/log_service.dart';
import 'allergen_engine.dart';

class EvaluationEngine {

  final AllergenEngine _engine = AllergenEngine();
  final List<String> safeGlutenIngredients;

  final List<IngredientRule> glutenRules;
  final List<IngredientRule> lactoseRules;

  EvaluationEngine({
    required this.glutenRules,
    required this.lactoseRules,
    required this.safeGlutenIngredients,
  });

  EvaluationResult evaluate(Product product, UserProfile profile) {

    Map<String, EvaluationDetail> results = {};

    if (profile.trackGluten) {

      results["gluten"] = _evaluateAllergen(
        product: product,
        rules: glutenRules,
        allergenTag: 'en:gluten',
        intoleranceName: "gluten",
      );

    }

    if (profile.trackLactose) {

      results["lactosa"] = _evaluateAllergen(
        product: product,
        rules: lactoseRules,
        allergenTag: 'en:milk',
        intoleranceName: "lactosa",
      );

    }

    return EvaluationResult(
      results: results,
    );
  }

  EvaluationDetail _evaluateAllergen({
    required Product product,
    required List<IngredientRule> rules,
    required String allergenTag,
    required String intoleranceName,
  }) {

    int score = 0;
    int confidence = 0;

    List<String> directMatches = [];
    List<String> traceMatches = [];

    final ingredients =
    product.ingredients.map((e) => e.toLowerCase()).toList();

    if (product.ingredients.isNotEmpty) {
      confidence += 40;
    }
    if (product.ingredientsAnalysisTags != null) {
      confidence += 30;
    }
    if (product.allergens != null) {
      confidence += 20;
    }
    if (product.traces != null) {
      confidence += 10;
    }
    LogService.info("Analizando ingredientes");
    /// 🧪 INGREDIENTES DIRECTOS
    for (var ingredient in ingredients) {
      for (var rule in rules) {
        for (var keyword in rule.keywords) {
          if (ingredient.contains(keyword)) {
            score += 100;
            directMatches.add(
              "Contiene ${rule.display}",
            );
          }
        }
      }
    }

    /// 🟢 INGREDIENTES NATURALMENTE SIN GLUTEN
    for (var ingredient in ingredients) {
      if (intoleranceName == "gluten") {
        for (var ingredient in ingredients) {
          for (var safe in safeGlutenIngredients) {
            if (ingredient.contains(safe)) {
              score -= 30;
            }
          }
        }
      }
    }

    /// ⚠ ALERGENOS OFICIALES
    if (product.allergens != null &&
        product.allergens!.contains(allergenTag)) {
      score += 90;
      directMatches.add(
        "El fabricante declara presencia de $intoleranceName",
      );
    }

    /// ⚠ TRAZAS
    if (product.traces != null &&
        product.traces!.contains(allergenTag)) {
      score += 40;
      traceMatches.add(
        "Puede contener trazas de $intoleranceName",
      );
    }

    /// ✅ CERTIFICACIÓN SIN GLUTEN
    if (_isCertifiedGlutenFree(product) &&
        intoleranceName == "gluten") {
      score -= 80;
      directMatches.add(
        "Producto certificado sin gluten",
      );
    }

    /// 🧠 ANALISIS SEMÁNTICO OPENFOODFACTS
    if (product.ingredientsAnalysisTags != null &&
        intoleranceName == "gluten") {
      if (product.ingredientsAnalysisTags!
          .contains("en:gluten-free")) {
        score -= 120;
        directMatches.add(
          "OpenFoodFacts identifica el producto como sin gluten",
        );
      }
    }

    /// 🔎 DEBUG
    LogService.info("🧠 SCORE $intoleranceName: $score");
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

    final labels = product.labels!.join(" ");

    return labels.contains("gluten-free") ||
        labels.contains("no-gluten");
  }
}