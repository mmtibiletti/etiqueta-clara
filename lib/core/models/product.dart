class Product {
  final String name;
  final String? brand;
  final String? imageUrl;
  final List<String> ingredients;
  final List<String>? ingredientsAnalysisTags;
  final List<String>? allergens;
  final List<String>? traces;
  final String? source;
  final String? status;
  final String? createdByNickname;
  final String? createdByUid;
  final String? createdByAvatar;
  final List<String>? labels;

  const Product({
    required this.name,
    required this.ingredients,
    this.ingredientsAnalysisTags,
    this.brand,
    this.imageUrl,
    this.allergens,
    this.traces,
    this.labels,
    this.source,
    this.status,
    this.createdByUid,
    this.createdByNickname,
    this.createdByAvatar,
  });
}