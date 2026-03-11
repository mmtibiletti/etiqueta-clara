class Product {
  final String id;
  final String? barcode;
  final String name;
  final String? brand;
  final List<String> ingredients;
  final String? imageUrl;
  final String source;
  final String? status;
  final String? createdByUid;
  final String? createdByNickname;
  final List<String>? allergens;
  final List<String>? traces;
  final List<String>? labels;
  final List<String>? labelsTags;
  final List<String>? ingredientsAnalysisTags;

  const Product({
    required this.id,
    this.barcode,
    required this.name,
    this.brand,
    required this.ingredients,
    this.imageUrl,
    required this.source,
    this.status,
    this.createdByUid,
    this.createdByNickname,
    this.allergens,
    this.traces,
    this.labels,
    this.labelsTags,
    this.ingredientsAnalysisTags,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "barcode": barcode,
      "name": name,
      "brand": brand,
      "ingredients": ingredients,
      "imageUrl": imageUrl,
      "source": source,
      "status": status,
      "createdByUid": createdByUid,
      "createdByNickname": createdByNickname,
      "allergens": allergens,
      "traces": traces,
      "labels": labels,
      "labelsTags": labelsTags,
      "ingredientsAnalysisTags": ingredientsAnalysisTags,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json["id"],
      barcode: json["barcode"],
      name: json["name"],
      brand: json["brand"],
      ingredients: List<String>.from(json["ingredients"] ?? []),
      imageUrl: json["imageUrl"],
      source: json["source"],
      status: json["status"],
      createdByUid: json["createdByUid"],
      createdByNickname: json["createdByNickname"],
      allergens: json["allergens"] != null
          ? List<String>.from(json["allergens"])
          : null,
      traces: json["traces"] != null
          ? List<String>.from(json["traces"])
          : null,
      labels: json["labels"] != null
          ? List<String>.from(json["labels"])
          : null,
      labelsTags: json["labelsTags"] != null
          ? List<String>.from(json["labelsTags"])
          : null,
      ingredientsAnalysisTags: json["ingredientsAnalysisTags"] != null
          ? List<String>.from(json["ingredientsAnalysisTags"])
          : null,
    );
  }
}