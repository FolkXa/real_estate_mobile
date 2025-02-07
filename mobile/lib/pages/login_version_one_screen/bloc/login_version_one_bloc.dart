import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';
import '../models/login_version_one_model.dart';
part 'login_version_one_event.dart';
part 'login_version_one_state.dart';

/// A bloc that manages the state of a LoginVersionOne according to the event that is dispatched to it.
class LoginVersionOneBloc extends Bloc<LoginVersionOneEvent, LoginVersionOneState> {
  LoginVersionOneBloc(LoginVersionOneState initialState) : super(initialState) {
    on<LoginVersionOneInitialEvent>(_onInitialize);
    on<ChangePasswordVisibilityEvent>(_changePasswordVisibility);
  }

  void _onInitialize(
    LoginVersionOneInitialEvent event,
    Emitter<LoginVersionOneState> emit,
  ) async {
    emit(
      state.copyWith(
        emailthreeController: TextEditingController(),
        passwordController: TextEditingController(),
        isShowPassword: true,
      ),
    );
    // await Future.delayed(
    //   const Duration(milliseconds: 3000),
    //   () {
    //     NavigatorService.popAndPushNamed(
    //       AppRoutes.homePromotionScreen,
    //     );
    //   },
    // );
  }

  void _changePasswordVisibility(
    ChangePasswordVisibilityEvent event,
    Emitter<LoginVersionOneState> emit,
  ) {
    emit(
      state.copyWith(
        isShowPassword: event.value,
      ),
    );
  }
}