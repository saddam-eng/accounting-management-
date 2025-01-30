class StorageProduct {
  final String id;
  final String name;
  final String category;

  final double avgPrice;
  final double price;
  final int quantity;
  Map<String,dynamic> report;

  StorageProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.avgPrice,
    required this.report,
    required this.price,
    required this.quantity,
  });

  factory StorageProduct.fromMap(Map<String, dynamic> map) {
    return StorageProduct(
      id: map['id'],
      name: map['name'],
      price:double.parse( map['price'].toString()),
      quantity: map['quantity'],
      report: map['report'],
      avgPrice: double.parse(map['avgPrice'].toString()),
      category: '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'avgPrice': avgPrice,
      'report': report,
      'category': category,
    };
  }
}
