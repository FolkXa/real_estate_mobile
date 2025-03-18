part of 'user_bloc.dart';
class UserState extends Equatable {
  final String? userId;
  final String? username;
  final String? email;

  const UserState({this.userId, this.username, this.email});

  factory UserState.fromJson(Map<String, dynamic> json) {
    return UserState(
      userId: json['userId'],
      username: json['username'],
      email: json['email'],
    );
  }

  Object? toJson() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
    };
  }

  UserState copyWith({String? userId, String? username, String? email}) {
    return UserState(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
    );
  }

  @override
  List<Object?> get props => [userId, username, email];
}
