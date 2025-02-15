import 'package:country_pickers/country.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_project/core/app_export.dart';
import 'package:real_estate_project/theme/custom_button_style.dart';
import 'package:real_estate_project/widgets/custom_outlined_button.dart';
import 'package:real_estate_project/widgets/page_header.dart';

import '../../core/utils/date_time_utils.dart';
import '../../widgets/custom_phone_number.dart';
import '../../widgets/custom_text_form_field.dart';
import 'bloc/sign_up_bloc.dart';

class SignUpScreen extends StatelessWidget {
  static Widget builder(BuildContext context) {
    return BlocProvider<SignUpBloc>(
      create: (context) => SignUpBloc(SignUpState()),
      child: SignUpScreen(),
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        NavigatorService.goBack();
                      },
                    ),
                  ),
                  SizedBox(height: 10.h),
                  PageHeader(title: "lbl_sign_up".tr),
                  SizedBox(height: 32.h),
                  _buildEmailInputSection(context),
                  SizedBox(height: 24.h),
                  _buildBirthDateInputField(context),
                  SizedBox(height: 24.h),
                  _buildPhoneField(context),
                  SizedBox(height: 24.h),
                  _buildPasswordInputSection(context),
                  SizedBox(height: 32.h),
                  CustomOutlinedButton(
                    text: 'lbl_sign_up'.tr,
                    buttonStyle: CustomButtonStyles.none,
                    decoration: CustomButtonStyles.outlineDecoration,
                    buttonTextStyle: CustomTextStyles.titleSmallOnPrimaryContainer,
                    onPressed: () {
                      NavigatorService.goBack();
                    },
                  ),
                  SizedBox(height: 32.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "msg_already_have_an".tr,
                        style: CustomTextStyles.labelLargeInterGray600,
                      ),
                      GestureDetector(
                        onTap: () {
                          NavigatorService.goBack();
                        },
                        child: Text(
                          "lbl_login2".tr,
                          style: CustomTextStyles.labelLargeInterRedA200,
                        ),
                      ),
                    ],
                  ),
                ]
              )
            )
          ),
        )
      )
    );
  }
}


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
        BlocSelector<SignUpBloc, SignUpState,
            TextEditingController?>(
          selector: (state) => state.emailController,
          builder: (context, emailController) {
            return CustomTextFormField(
              controller: emailController,
              hintText: "lbl_email".tr,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.h,
                vertical: 12.h,
              ),
              prefixIcon: Icon(Icons.person)
            );
          },
        ),
      ],
    ),
  );
}

Widget _buildPasswordInputSection(BuildContext context) {
  return SizedBox(
    width: double.maxFinite,
    child: Column(
      spacing: 2,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "lbl_set_password".tr,
          style: CustomTextStyles.labelLargePlusJakartaSansGray600,
        ),
        BlocBuilder<SignUpBloc, SignUpState>(
          builder: (context, state) {
            return CustomTextFormField(
              controller: state.passwordController,
              hintText: "lbl_password".tr,
              textInputAction: TextInputAction.done,
              suffixIcon: InkWell(
                onTap: () {
                  context.read<SignUpBloc>().add(
                    ChangePasswordVisibilityEvent(
                      value: !state.isShowPassword,
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.fromLTRB(16.h, 12.h, 14.h, 12.h),
                  child: Icon(
                    state.isShowPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
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

Widget _buildBirthDateInputField(BuildContext context) {
  return SizedBox(
    width: double.maxFinite,
    child: Column(
      spacing: 2,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "lbl_birth_of_date".tr,
          style: CustomTextStyles.labelLargePlusJakartaSansGray600,
        ),
        BlocSelector<SignUpBloc, SignUpState, TextEditingController?>(
          selector: (state) => state.birthController,
          builder: (context, birthController) {
            return CustomTextFormField(
              readOnly: true,
              controller: birthController,
              hintText: "lbl_birth_of_date".tr,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(Duration(days: -(365 * 18))),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  String date = pickedDate.format(pickedDate, {
                    'pattern': dateTimeFormatPattern,
                  });
                  context.read<SignUpBloc>().add(
                    BirthChanged(
                      TextEditingController(text: date),
                    ),
                  );
                }
              },
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.h,
                vertical: 12.h,
              ),
              suffixIcon: Icon(Icons.calendar_month),
            );
          },
        ),
      ],
    ),
  );
}

Widget _buildPhoneField(BuildContext context) {
  return SizedBox(
    width: double.maxFinite,
    child: Column(
      spacing: 2,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "lbl_phone_number".tr,
          style: CustomTextStyles.labelLargePlusJakartaSansGray600,
        ),
        SizedBox(
          width: double.maxFinite,
          child: BlocBuilder<SignUpBloc, SignUpState>(
            builder: (context, state) {
              return CustomPhoneNumber(
                country: state.country ?? CountryPickerUtils.getCountryByPhoneCode('66'),
                controller: state.phoneController,
                onTap: (Country value) {
                  context
                      .read<SignUpBloc>()
                      .add(CountryChanged(value));
                  print(value.name);
                },
              );
            },
          ),
        ),
      ],
    ),
  );
}

