class User {
  final int userID;
  final String username;
  final String firstName;
  final String? middleName;
  final String? lastName;
  final String? phoneNumber;
  final String? email;
  final String status;
  final String createdAt;
  final String? updatedAt;

  const User({
    required this.userID,
    required this.username,
    required this.firstName,
    this.middleName,
    this.lastName,
    this.phoneNumber,
    this.email,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userID: json['userID'] as int,
      username: json['username'] as String,
      firstName: json['firstName'] as String,
      middleName: json['middleName'] as String?,
      lastName: json['lastName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}
