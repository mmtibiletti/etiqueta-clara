class IngredientRule {
  final String display;
  final List<String> keywords;

  IngredientRule({
    required this.display,
    required this.keywords,
  });

  factory IngredientRule.fromJson(Map<String, dynamic> json) {
    return IngredientRule(
      display: json['display'],
      keywords: List<String>.from(json['keywords']),
    );
  }
}