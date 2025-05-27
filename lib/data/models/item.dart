class Item {
  final int id;
  final String title;
  final int price;
  final String image;
  final String description;

  Item({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    required this.description,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json['id'],
    title: json['title'],
    price: json['price'],
    image: json['image'],
    description: json['description'],
  );
}
