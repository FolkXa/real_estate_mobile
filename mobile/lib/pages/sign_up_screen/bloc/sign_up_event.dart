part of 'sign_up_bloc.dart';

/// Abstract class for all events that can be dispatched from the
/// SignUp widget.
///
/// Events must be immutable and implement the [Equatable] interface.
abstract class SignUpEvent extends Equatable {
  const SignUpEvent();

  @override
  List<Object?> get props => [];
}

/// Event for when the email is changed.
class EmailChanged extends SignUpEvent {
  final TextEditingController emailController;

  EmailChanged(this.emailController);

  @override
  List<Object?> get props => [emailController];
}

/// Event for when the birth date is changed.
class BirthChanged extends SignUpEvent {
  final TextEditingController birthController;

  BirthChanged(this.birthController);

  @override
  List<Object?> get props => [birthController];
}

/// Event for when the phone number is changed.
class PhoneChanged extends SignUpEvent {
  final TextEditingController phoneController;

  PhoneChanged(this.phoneController);

  @override
  List<Object?> get props => [phoneController];
}

/// Event for when the password is changed.
class PasswordChanged extends SignUpEvent {
  final TextEditingController passwordController;

  PasswordChanged(this.passwordController);

  @override
  List<Object?> get props => [passwordController];
}

/// Event for when the country is changed.
class CountryChanged extends SignUpEvent {
  final Country country;

  CountryChanged(this.country);

  @override
  List<Object?> get props => [country];
}

/// Event for when the sign up is submitted.
class SignUpSubmitted extends SignUpEvent {}

class ChangePasswordVisibilityEvent extends SignUpEvent {
  ChangePasswordVisibilityEvent({required this.value});

  final bool value;

  @override
  List<Object?> get props => [value];
}

