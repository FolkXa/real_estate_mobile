part of 'sign_up_bloc.dart';

/// Represents the state of SignUp in the application.
// ignore_for_file: must_be_immutable
class SignUpState extends Equatable {
  SignUpState({
    this.emailController,
    this.birthController,
    this.phoneController,
    this.country,
    this.passwordController,
    this.isShowPassword = false,
    this.isSubmitted = false,
  });

  TextEditingController? emailController;
  TextEditingController? birthController;
  TextEditingController? phoneController;
  Country? country;
  TextEditingController? passwordController;
  bool isShowPassword;
  bool isSubmitted;

  @override
  List<Object?> get props => [
        emailController,
        birthController,
        phoneController,
        country,
        passwordController,
        isShowPassword,
        isSubmitted
      ];

  SignUpState copyWith({
    TextEditingController? emailController,
    TextEditingController? birthController,
    TextEditingController? phoneController,
    Country? country,
    TextEditingController? passwordController,
    bool? isShowPassword,
    bool? isSubmitted,
  }) {
    return SignUpState(
      emailController: emailController ?? this.emailController,
      birthController: birthController ?? this.birthController,
      phoneController: phoneController ?? this.phoneController ?? TextEditingController(text: ''),
      country: country ?? this.country ?? CountryPickerUtils.getCountryByPhoneCode('66'),
      passwordController: passwordController ?? this.passwordController,
      isShowPassword: isShowPassword ?? this.isShowPassword,
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }
}

