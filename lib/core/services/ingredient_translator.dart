import '../config/ingredient_translations.dart';

class IngredientTranslator {

  static String translate(String ingredient) {
    for (var entry in ingredientTranslations.entries) {
      if (ingredient.contains(entry.key)) {
        return ingredient.replaceAll(entry.key, entry.value);
      }
    }
    return ingredient;
  }

  static List<String> translateList(List<String> ingredients) {
    return ingredients
        .map((e) => translate(e))
        .toList();
  }

}