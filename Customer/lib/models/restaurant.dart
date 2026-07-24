class Restaurant {
  final String id;
  final String name;
  final String cuisine;
  final bool isOpen;
  final double? rating;
  final int? etaMinutes;
  final String? imageUrl;

  Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.isOpen,
    this.rating,
    this.etaMinutes,
    this.imageUrl,
  });

  factory Restaurant.fromMap(String id, Map<String, dynamic> map) {
    return Restaurant(
      id: id,
      name: map['name'] ?? '',
      cuisine: map['cuisine'] ?? '',
      isOpen: map['isOpen'] ?? false,
      rating: (map['rating'] as num?)?.toDouble(),
      etaMinutes: map['etaMinutes'] as int?,
      imageUrl: map['imageUrl'] as String?,
    );
  }
}
