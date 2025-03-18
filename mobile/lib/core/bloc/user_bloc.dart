import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(const UserState()) {
    on<SetUserData>((event, emit) async {
      emit(state.copyWith(
        userId: event.userId,
        username: event.username,
        email: event.email,
      ));

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('user', jsonEncode(state.toJson()));
    });

    on<ClearUserData>((event, emit) async {
      emit(const UserState());

      final prefs = await SharedPreferences.getInstance();
      prefs.remove('user');
    });

    on<UserEvent>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        emit(UserState.fromJson(userMap));
      } else {
        emit(const UserState(userId: 'test', username: 'test test', email: 'test@test.com'));
      }
    });
  }
}
