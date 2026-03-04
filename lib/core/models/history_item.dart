class HistoryItem {
  final String barcode;
  final String name;
  final String? brand;
  final String status; // green, yellow, red
  final DateTime date;

  HistoryItem({
    required this.barcode,
    required this.name,
    this.brand,
    required this.status,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'barcode': barcode,
      'name': name,
      'brand': brand,
      'status': status,
      'date': date.toIso8601String(),
    };
  }

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      barcode: json['barcode'],
      name: json['name'],
      brand: json['brand'],
      status: json['status'],
      date: DateTime.parse(json['date']),
    );
  }
}