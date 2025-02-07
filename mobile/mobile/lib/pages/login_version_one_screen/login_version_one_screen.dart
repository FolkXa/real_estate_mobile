import 'package:flutter/material.dart';
import '../../../core/app_export.dart';
import '../../../theme/custom_button_style.dart';
import '../../../widgets/custom_outlined_button.dart';
import '../../../widgets/custom_text_form_field.dart';
import 'bloc/login_version_one_bloc.dart';
import 'models/login_version_one_model.dart';

class LoginVersionOneScreen extends StatelessWidget {
  const LoginVersionOneScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return BlocProvider<LoginVersionOneBloc>(
      create: (context) => LoginVersionOneBloc(LoginVersionOneState(
        loginVersionOneModelObj: LoginVersionOneModel(),
      ))
        ..add(LoginVersionOneInitialEvent()),
      child: LoginVersionOneScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.purple50,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Container(
              width: double.maxFinite,
              padding: EdgeInsets.only(
                left: 24.h,
                top: 18.h,
                right: 24.h,
              ),
              child: Column(
                children: [
                  _buildLogoSection(context),
                  SizedBox(height: 32.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 216.h,
                      child: Text(
                        "msg_sign_in_to_your".tr,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.headlineLarge!.copyWith(
                          height: 1.30,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "msg_enter_your_email".tr,
                      style: CustomTextStyles.labelLargeInterGray600,
                    ),
                  ),
                  SizedBox(height: 32.h),
                  _buildEmailInputSection(context),
                  SizedBox(height: 16.h),
                  _buildPasswordInputSection(context),
                  SizedBox(height: 16.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "msg_forgot_password".tr,
                      style: CustomTextStyles.labelLargeInterOnError,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  CustomOutlinedButton(
                    text: "lbl_log_in".tr,
                    buttonStyle: CustomButtonStyles.outlineGray,
                    buttonTextStyle: theme.textTheme.titleLarge!,
                  ),
                  SizedBox(height: 24.h),
                  _buildSeparatorSection(context),
                  SizedBox(height: 16.h),
                  CustomOutlinedButton(
                    text: "msg_continue_with_google".tr,
                    leftIcon: Container(
                      margin: EdgeInsets.only(right: 10.h),
                      child: CustomImageView(
                        imagePath: ImageConstant.imgGoogle,
                        height: 18.h,
                        width: 18.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  CustomOutlinedButton(
                    text: "msg_continue_with_facebook".tr,
                    leftIcon: Container(
                      margin: EdgeInsets.only(right: 10.h),
                      child: CustomImageView(
                        imagePath: ImageConstant.img2021facebookicon1,
                        height: 18.h,
                        width: 18.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "msg_don_t_have_an_account".tr,
                        style: CustomTextStyles.labelLargeInterGray600,
                      ),
                      Text(
                        "lbl_sign_up".tr,
                        style: CustomTextStyles.labelLargeInterRedA200,
                      ),
                    ],
                  ),
                  SizedBox(height: 58.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  CustomImageView Icon() {
    return CustomImageView(
                      imagePath: ImageConstant.imgGoogle,
                      height: 18.h,
                      width: 18.h,
                      fit: BoxFit.contain,
                    );
  }
}
/// Section Widget
Widget _buildLogoSection(BuildContext context) {
  return SizedBox(
    width: double.maxFinite,
    child: Row(
      children: [
        CustomImageView(
          imagePath: ImageConstant.imgSettings,
          height: 18.h,
          width: 18.h,
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(left: 14.h),
            child: Text(
              "lbl_logo".tr,
              style: CustomTextStyles.bodySmallInterOnError,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Section Widget
Widget _buildEmailInputSection(BuildContext context) {
  return SizedBox(
    width: double.maxFinite,
    child: Column(
      spacing: 2,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "lbl_email".tr,
          style: CustomTextStyles.labelLargePlusJakartaSansGray600,
        ),
        BlocSelector<LoginVersionOneBloc, LoginVersionOneState,
            TextEditingController?>(
          selector: (state) => state.emailthreeController,
          builder: (context, emailthreeController) {
            return CustomTextFormField(
              controller: emailthreeController,
              hintText: "msg_loisbecket_gmail_com".tr,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.h,
                vertical: 12.h,
              ),
            );
          },
        ),
      ],
    ),
  );
}

/// Section Widget
Widget _buildPasswordInputSection(BuildContext context) {
  return SizedBox(
    width: double.maxFinite,
    child: Column(
      spacing: 2,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "lbl_password".tr,
          style: CustomTextStyles.labelLargePlusJakartaSansGray600,
        ),
        BlocBuilder<LoginVersionOneBloc, LoginVersionOneState>(
          builder: (context, state) {
            return CustomTextFormField(
              controller: state.passwordController,
              hintText: "lbl".tr,
              textInputAction: TextInputAction.done,
              suffix: InkWell(
                onTap: () {
                  context.read<LoginVersionOneBloc>().add(
                    ChangePasswordVisibilityEvent(
                      value: !state.isShowPassword,
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.fromLTRB(16.h, 12.h, 14.h, 12.h),
                  child: CustomImageView(
                    imagePath: ImageConstant.imgEyeoff,
                    height: 16.h,
                    width: 16.h,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              suffixConstraints: BoxConstraints(
                maxHeight: 46.h,
              ),
              obscureText: state.isShowPassword,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.h,
                vertical: 12.h,
              ),
            );
          },
        ),
      ],
    ),
  );
}

/// Section Widget
Widget _buildSeparatorSection(BuildContext context) {
  return SizedBox(
    width: double.maxFinite,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Divider(),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Text(
            "lbl_or".tr,
            style: CustomTextStyles.bodySmallInterGray600,
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Divider(),
          ),
        ),
      ],
    ),
  );
}
