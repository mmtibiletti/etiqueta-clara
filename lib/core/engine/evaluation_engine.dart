import '../models/product.dart';
import '../models/user_profile.dart';
import '../models/evaluation_result.dart';
import '../models/ingredient_rule.dart';

class EvaluationEngine {
  final Map<String, List<IngredientRule>> rules;
  final List<String> safeGlutenIngredients;

  EvaluationEngine({
    required this.rules,
    required this.safeGlutenIngredients,
  });

  EvaluationResult evaluate(Product product, UserProfile profile) {
    Map<String, EvaluationDetail> results = {};
    if (profile.trackGluten && rules.containsKey("gluten")) {
      results["gluten"] = _evaluate(product, rules["gluten"]!, "gluten");
    }

    if (profile.trackLactose && rules.containsKey("lactose")) {
      results["lactose"] = _evaluate(product, rules["lactose"]!, "lactose");
    }

    return EvaluationResult(results: results);
  }
}

EvaluationDetail _evaluate(
    Product product,
    List<IngredientRule> rules,
    String intolerance,
    ) {
  int score = 0;
  int confidence = 0;
  List<String> directMatches = [];
  List<String> traceMatches = [];
  final ingredients = product.ingredients.map((e) => e.toLowerCase()).toList();

  if (product.ingredients.isNotEmpty)
    confidence += 40;

  if (product.ingredientsAnalysisTags != null)
    confidence += 30;

  if (product.allergens != null)
    confidence += 20;

  if (product.traces != null)
    confidence += 10;

  /// Ingredientes directos
  for (var ingredient in ingredients) {
    for (var rule in rules) {
      for (var keyword in rule.keywords) {
        if (ingredient.contains(keyword)) {
          score += 100;
          directMatches.add( "Contiene ${rule.display}");
        }
      }
    }
  }

  /// Ingredientes naturalmente sin gluten
  if (intolerance == "gluten") {
    for (var ingredient in ingredients) {
      for (var safe in safeGlutenIngredients) {
        if (ingredient.contains(safe)) {
          score -= 30;
          directMatches.add( "Ingrediente naturalmente sin gluten: $safe");
        }
      }
    }
  }

  /// Alergenos declarados
  if (product.allergens != null) {
    if (product.allergens!.contains("en:$intolerance")) {
      score += 90;
      directMatches.add( "El fabricante declara presencia de $intolerance");
    }
  }

  /// Trazas
  if (product.traces != null) {
    if (product.traces!.contains("en:$intolerance")) {
      score += 40;
      traceMatches.add( "Puede contener trazas de $intolerance");
    }
  }

  /// Certificación sin gluten
  if (intolerance == "gluten" && _isCertifiedGlutenFree(product)) {
    score -= 80;
    directMatches.add("Producto certificado sin gluten");
  }

  RiskStatus status;
  if (score >= 80) {
    status = RiskStatus.red;
  }
  else if (score >= 30) {
    status = RiskStatus.yellow;
  }
  else {
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
  if (product.labels == null)
    return false;

  final labels = product.labels!.join(" ").toLowerCase();
  return labels.contains("gluten-free") || labels.contains("no-gluten");
}