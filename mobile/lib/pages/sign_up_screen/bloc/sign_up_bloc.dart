import 'package:country_pickers/country.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';
import '../models/sign_up_model.dart';
part 'sign_up_event.dart';
part 'sign_up_state.dart';

/// A bloc that manages the state of a SignUp according to the event that is dispatched to it.
class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  SignUpBloc(SignUpState initialState) : super(initialState) {
    on<EmailChanged>(_onEmailChanged);
    on<BirthChanged>(_onBirthChanged);
    on<PhoneChanged>(_onPhoneChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<SignUpSubmitted>(_onSignUpSubmitted);
    on<ChangePasswordVisibilityEvent>(_changePasswordVisibility);
    on<CountryChanged>(_onCountryChanged);
  }

  void _onEmailChanged(
    EmailChanged event,
    Emitter<SignUpState> emit,
  ) {
    emit(
      state.copyWith(
        emailController: event.emailController,
      ),
    );
  }

  void _onBirthChanged(
    BirthChanged event,
    Emitter<SignUpState> emit,
  ) {
    emit(
      state.copyWith(
        birthController: event.birthController,
      ),
    );
  }

  void _onPhoneChanged(
    PhoneChanged event,
    Emitter<SignUpState> emit,
  ) {
    emit(
      state.copyWith(
        phoneController: event.phoneController,
      ),
    );
  }

  void _onPasswordChanged(
    PasswordChanged event,
    Emitter<SignUpState> emit,
  ) {
    emit(
      state.copyWith(
        passwordController: event.passwordController,
      ),
    );
  }

  void _onSignUpSubmitted(
    SignUpSubmitted event,
    Emitter<SignUpState> emit,
  ) {
    // Handle sign up logic here
    emit(
      state.copyWith(
        isSubmitted: true,
      ),
    );
  }

  void _changePasswordVisibility(
    ChangePasswordVisibilityEvent event,
    Emitter<SignUpState> emit,
  ) {
    emit(
      state.copyWith(
        isShowPassword: event.value,
      ),
    );
  }

  void _onCountryChanged(
    CountryChanged event,
    Emitter<SignUpState> emit,
  ) {
    emit(
      state.copyWith(
        country: event.country,
      ),
    );
  }
}

