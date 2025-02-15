import 'package:flutter/material.dart';
import 'package:real_estate_project/pages/home_promotion_screen/home_promotion_screen.dart';
import 'package:real_estate_project/pages/login_version_one_screen/login_version_one_screen.dart';
import 'package:real_estate_project/pages/sign_up_screen/sign_up_screen.dart';
class AppRoutes {
  static const String loginVersionOneScreen = '/login_version_one_screen';
  static const String signUpScreen = '/sign_up_screen';
  static const String loginVersionTwoScreen = '/login_version_two_screen';
  static const String homeFullScreen = '/home_full_screen';
  static const String homeTabPage = '/home_tab_page';
  static const String homeFullInitialPage = '/home_full_initial_page';
  static const String homePromotionScreen = '/home_promotion_screen';
  static const String detailFullScreen = '/detail_full_screen';
  static const String detailShortScreen = '/detail_short_screen';
  static const String appNavigationScreen = '/app_navigation_screen';
  static const String initialRoute = '/initialRoute';

  static Map<String, WidgetBuilder> get routes => {
    // loginVersionOneScreen: LoginVersionOneScreen.builder,
    signUpScreen: SignUpScreen.builder,
    // loginVersionTwoScreen: LoginVersionTwoScreen.builder,
    // homeFullScreen: HomeFullScreen.builder,
    homePromotionScreen: HomePromotionScreen.builder,
    // detailFullScreen: DetailFullScreen.builder,
    // detailShortScreen: DetailShortScreen.builder,
    // appNavigationScreen: AppNavigationScreen.builder,
    initialRoute: LoginVersionOneScreen.builder,
  };
}
