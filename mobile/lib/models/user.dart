class User {
  final bool active;
  final String email;
  final String firstName;
  final String imagePath;
  final String lastName;
  final String nickName;
  final String password; // Note: In a real app, you wouldn't store the password in the client
  final String phoneNumber;
  final String role;
  final int userId;
  final String username;

  User({
    required this.active,
    required this.email,
    required this.firstName,
    required this.imagePath,
    required this.lastName,
    required this.nickName,
    required this.password,
    required this.phoneNumber,
    required this.role,
    required this.userId,
    required this.username,
  });

  String get fullName => '$firstName $lastName';

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      active: map['active'] ?? false,
      email: map['email'] ?? '',
      firstName: map['first_name'] ?? '',
      imagePath: map['image_path'] ?? '',
      lastName: map['last_name'] ?? '',
      nickName: map['nick_name'] ?? '',
      password: map['password'] ?? '', // Be careful with this in a real app
      phoneNumber: map['phone_number'] ?? '',
      role: map['role'] ?? '',
      userId: map['user_id'] ?? 0,
      username: map['username'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'active': active,
      'email': email,
      'first_name': firstName,
      'image_path': imagePath,
      'last_name': lastName,
      'nick_name': nickName,
      'password': password,
      'phone_number': phoneNumber,
      'role': role,
      'user_id': userId,
      'username': username,
    };
  }
}