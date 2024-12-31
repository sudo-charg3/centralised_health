class User {
  final String abhaId;
  final String token;

  User({required this.abhaId, required this.token});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      abhaId: json['abha_id'],
      token: json['token'],
    );
  }
}