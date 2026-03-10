class Product {
  final String id;
  final String? barcode;
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
    required this.id,
    this.barcode,
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

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "barcode": barcode,
      "name": name,
      "brand": brand,
      "imageUrl": imageUrl,
      "ingredients": ingredients,
      "allergens": allergens,
      "traces": traces,
      "labels": labels,
      "source": source,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json["id"],
      barcode: json["barcode"],
      name: json["name"],
      brand: json["brand"],
      imageUrl: json["imageUrl"],
      ingredients: List<String>.from(json["ingredients"] ?? []),
      allergens: json["allergens"] != null
          ? List<String>.from(json["allergens"])
          : null,
      traces: json["traces"] != null
          ? List<String>.from(json["traces"])
          : null,
      labels: json["labels"] != null
          ? List<String>.from(json["labels"])
          : null,
      source: json["source"],
    );
  }
}