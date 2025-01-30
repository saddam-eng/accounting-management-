

class Product {
  final String id;
  final String name;
  final String category;
  final int unit;
  final double price;
  final double quantity;
  final double profit;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.price,
    required this.quantity,
    required this.profit,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      unit: map['unit'],
      price: double.parse(map['price'].toString()),
      quantity:double.parse(map['quantity'].toString()),
      profit:double.parse( map['profit'].toString()),
      category: map['category'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'unit': unit,
      'price': price,
      'quantity': quantity,
      'profit':profit,
      'category':category
    };
  }
}
