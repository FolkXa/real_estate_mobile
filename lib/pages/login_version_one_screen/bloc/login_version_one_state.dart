part of 'login_version_one_bloc.dart';

/// Represents the state of LoginVersionOne in the application.
// ignore_for_file: must_be_immutable
class LoginVersionOneState extends Equatable {
  LoginVersionOneState({
    this.emailthreeController,
    this.passwordController,
    this.isShowPassword = true,
    this.loginVersionOneModelObj,
  });

  TextEditingController? emailthreeController;
  TextEditingController? passwordController;
  LoginVersionOneModel? loginVersionOneModelObj;
  bool isShowPassword;

  @override
  List<Object?> get props => [
        emailthreeController,
        passwordController,
        isShowPassword,
        loginVersionOneModelObj
      ];

  LoginVersionOneState copyWith({
    TextEditingController? emailthreeController,
    TextEditingController? passwordController,
    bool? isShowPassword,
    LoginVersionOneModel? loginVersionOneModelObj,
  }) {
    return LoginVersionOneState(
      emailthreeController: emailthreeController ?? this.emailthreeController,
      passwordController: passwordController ?? this.passwordController,
      isShowPassword: isShowPassword ?? this.isShowPassword,
      loginVersionOneModelObj: loginVersionOneModelObj ?? this.loginVersionOneModelObj,
    );
  }
}