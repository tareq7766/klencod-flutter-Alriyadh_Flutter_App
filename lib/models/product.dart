class Product {
  final String id;
  final String name;
  final String size;
  final String description;
  final String? price;
  final String? imageUrl;

  const Product({
    required this.id,
    required this.name,
    required this.size,
    required this.description,
    this.price,
    this.imageUrl,
  });

  Product copyWith({
    String? name,
    String? size,
    String? description,
    String? price,
    String? imageUrl,
    bool clearPrice = false,
    bool clearImage = false,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      size: size ?? this.size,
      description: description ?? this.description,
      price: clearPrice ? null : (price ?? this.price),
      imageUrl: clearImage ? null : (imageUrl ?? this.imageUrl),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'size': size,
        'description': description,
        'price': price,
        'imageUrl': imageUrl,
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        size: json['size'] as String? ?? '',
        description: json['description'] as String? ?? '',
        price: json['price'] as String?,
        imageUrl: json['imageUrl'] as String?,
      );
}
