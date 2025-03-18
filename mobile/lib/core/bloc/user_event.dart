part of 'user_bloc.dart';
abstract class UserEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SetUserData extends UserEvent {
  final String userId;
  final String username;
  final String email;

  SetUserData({required this.userId, required this.username, required this.email});

  @override
  List<Object?> get props => [userId, username, email];
}

class ClearUserData extends UserEvent {}