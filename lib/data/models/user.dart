class User {
  final String id;
  final String? name;
  final String email;
  final String password;
  final String createdAt;
  final String updatedAt;

  User({
    required this.id,
    this.name,
    required this.email,
    required this.password,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    password: json['password'],
    createdAt: json['createdAt'],
    updatedAt: json['updatedAt'],
  );
}
