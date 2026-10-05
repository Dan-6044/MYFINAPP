class LoginResponse {
  final String accessToken;
  final DateTime expiresAt;
  final int userID;
  final String username;
  final String firstName;
  final String? lastName;
  final String? email;

  const LoginResponse({
    required this.accessToken,
    required this.expiresAt,
    required this.userID,
    required this.username,
    required this.firstName,
    this.lastName,
    this.email,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      userID: json['userID'] as int,
      username: json['username'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String?,
      email: json['email'] as String?,
    );
  }
}
