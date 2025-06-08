class Item {
  final String id; // Changed from int to String to match your API
  final String title;
  final int price;
  final String image;
  final String description;
  final String? pickUp;
  final String? city;
  final String? category;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Item({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    required this.description,
    this.pickUp,
    this.city,
    this.category,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    // Extract the first image URL from the images array
    String imageUrl = '';
    if (json['images'] != null && json['images'].isNotEmpty) {
      imageUrl = json['images'][0]['url'] ?? '';
    }

    return Item(
      id: json['id'] ?? '',
      title: json['prod_name'] ?? '', // Map prod_name to title
      price: json['price'] ?? 0,
      image: imageUrl,
      description: json['description'] ?? '',
      pickUp: json['pick_up'],
      city: json['city'],
      category: json['category'],
      userId: json['userId'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // Optional: Add toJson method if needed
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prod_name': title,
      'price': price,
      'description': description,
      'pick_up': pickUp,
      'city': city,
      'category': category,
      'userId': userId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
