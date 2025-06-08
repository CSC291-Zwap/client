class Item {
  final String id; // Changed from int to String to match your API
  final String title;
  final int price;
  final List<String> images;
  final String description;
  final String? pickUp;
  final String? city;
  final String? category;
  final String? userId;
  final String? userName;
  final String? email;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Item({
    required this.id,
    required this.title,
    required this.price,
    required this.images,
    required this.description,
    this.pickUp,
    this.city,
    this.category,
    this.userId,
    this.userName,
    this.email,
    this.createdAt,
    this.updatedAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    // Extract the list of image URLs from the images array
    List<String> imagesList = [];
    if (json['images'] != null && json['images'] is List) {
      imagesList = List<String>.from(
        (json['images'] as List)
            .map((img) => img['url'] ?? '')
            .where((url) => url != null && url != ''),
      );
    }

    return Item(
      id: json['id'] ?? '',
      title: json['prod_name'] ?? '', // Map prod_name to title
      price: json['price'] ?? 0,
      images: imagesList,
      description: json['description'] ?? '',
      pickUp: json['pick_up'],
      city: json['city'],
      userName: json['user']?['name'] ?? 'Unknown User',
      email: json['user']?['email'] ?? 'Unknown Email',
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
      'images': images,
      'pick_up': pickUp,
      'city': city,
      'category': category,
      'userId': userId,
      'userName': userName,
      'email': email,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
