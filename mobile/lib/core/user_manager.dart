import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserState extends Equatable {
  final String? userId;
  final String? username;
  final String? email;

  const UserState({this.userId, this.username, this.email});

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

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(const UserState()) {
    on<SetUserData>((event, emit) {
      emit(state.copyWith(
        userId: event.userId,
        username: event.username,
        email: event.email,
      ));
    });

    on<ClearUserData>((event, emit) {
      emit(const UserState());
    });
  }
}