class CartItem {
  final String id;
  final String name;
  final double price;
  final int qty;

  CartItem({required this.id, required this.name, required this.price, required this.qty});

  CartItem copyWith({int? qty}) =>
      CartItem(id: id, name: name, price: price, qty: qty ?? this.qty);

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'price': price, 'qty': qty};
}
