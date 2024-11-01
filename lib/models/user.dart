class User {
  final int id;
  final String token;
  final String active;
  final String role;
  final List<String> classList;

  User({
    required this.id,
    required this.token,
    required this.active,
    required this.role,
    required this.classList,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      token: json['token'],
      active: json['active'],
      role: json['role'],
      classList: List<String>.from(json['classList']),
    );
  }
}
