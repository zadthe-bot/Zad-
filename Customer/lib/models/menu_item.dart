class MenuItem {
  final String id;
  final String name;
  final String? description;
  final double price;

  MenuItem({required this.id, required this.name, this.description, required this.price});

  factory MenuItem.fromMap(String id, Map<String, dynamic> map) {
    return MenuItem(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] as String?,
      price: (map['price'] as num?)?.toDouble() ?? 0,
    );
  }
}
