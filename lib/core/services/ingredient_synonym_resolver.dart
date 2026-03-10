import '../config/ingredient_synonyms.dart';

class IngredientSynonymResolver {

  static String resolve(String ingredient) {
    for (var entry in ingredientSynonyms.entries) {
      if (ingredient.contains(entry.key)) {
        return ingredient.replaceAll(entry.key, entry.value);
      }
    }
    return ingredient;
  }

  static List<String> resolveList(List<String> ingredients) {
    return ingredients
        .map((e) => resolve(e))
        .toList();
  }

}