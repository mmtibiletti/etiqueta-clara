import 'ingredient_rule.dart';

class IntoleranceRule {

  final String id;
  final String allergenTag;
  final List<IngredientRule> rules;

  const IntoleranceRule({
    required this.id,
    required this.allergenTag,
    required this.rules,
  });
}