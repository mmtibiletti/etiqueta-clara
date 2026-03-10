class IngredientNormalizer {

  static String normalize(String ingredient) {

    var text = ingredient.toLowerCase();

    /// quitar símbolos
    text = text.replaceAll(RegExp(r'[(),;:_-]'), ' ');

    /// quitar espacios dobles
    text = text.replaceAll(RegExp(r'\s+'), ' ');

    /// trim
    text = text.trim();

    return text;
  }

  static List<String> normalizeList(List<String> ingredients) {
    return ingredients
        .map((e) => normalize(e))
        .toList();
  }

}