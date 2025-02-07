// import 'package:flutter/material.dart';

// import '../../core/app_export.dart';
// import '../theme/custom_button_style.dart';
// import '../../widgets/app_bar/appbar_leading_iconbutton.dart';
// import '../../widgets/app_bar/appbar_trailing_iconbutton.dart';
// import '../../widgets/app_bar/custom_app_bar.dart';
// import '../../widgets/custom_elevated_button.dart';
// import '../../widgets/custom_icon_button.dart';

// import 'bloc/home_promotion_bloc.dart';
// import 'models/home_promotion_model.dart';

// class HomePromotionScreen extends StatelessWidget {
//   const HomePromotionScreen({Key? key}) : super(key: key);

//   static Widget builder(BuildContext context) {
//     return BlocProvider<HomePromotionBloc>(
//       create: (context) => HomePromotionBloc(HomePromotionState(
//         homePromotionModelObj: HomePromotionModel(),
//       ))..add(HomePromotionInitialEvent),
//       child: HomePromotionScreen(),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<HomePromotionBloc, HomePromotionState>(
//       builder: (context, state) {
//         return Scaffold(
//           backgroundColor: appTheme.purple50,
//           appBar: _buildHeader(context),
//           body: SafeArea(
//             top: false,
//             child: SizedBox(
//               width: double.maxFinite,
//               child: SingleChildScrollView(
//                 child: Container(
//                   width: double.maxFinite,
//                   padding: EdgeInsets.symmetric(horizontal: 24.h),
//                   child: Column(
//                     children: [
//                       SizedBox(height: 28.h),
//                       Container(
//                         height: 196.h,
//                         width: double.maxFinite,
//                         margin: EdgeInsets.only(left: 14.h, right: 16.h),
//                         child: Stack(
//                           alignment: Alignment.center,
//                           children: [
//                             CustomImageView(
//                               imagePath: ImageConstant.imgImage25,
//                               height: 196.h,
//                               width: double.maxFinite,
//                               radius: BorderRadius.circular(24.h),
//                             ),
//                             Container(
//                               width: double.maxFinite,
//                               decoration: AppDecoration.fillOnError.copyWith(
//                                 borderRadius: BorderRadiusStyle.roundedBorder24,
//                               ),
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.max,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   SizedBox(height: 44.h),
//                                   Padding(
//                                     padding: EdgeInsets.only(left: 28.h),
//                                     child: Text(
//                                       "msg_halloween_sale".tr,
//                                       maxLines: 2,
//                                       overflow: TextOverflow.ellipsis,
//                                       style: CustomTextStyles.titleMediumRalewayOnPrimaryContainer_1,
//                                     ),
//                                   ),
//                                   SizedBox(height: 12.h),
//                                   Padding(
//                                     padding: EdgeInsets.only(left: 28.h),
//                                     child: Text(
//                                       "msg_all_discount_up".tr,
//                                       style: CustomTextStyles.bodySmallOnPrimaryContainer,
//                                     ),
//                                   ),
//                                   SizedBox(height: 22.h),
//                                   Container(
//                                     height: 60.h,
//                                     width: 102.h,
//                                     padding: EdgeInsets.only(
//                                       left: 38.h,
//                                       bottom: 24.h,
//                                     ),
//                                     decoration: AppDecoration
//                                         .fillPrimaryContainer
//                                         .copyWith(
//                                       borderRadius:
//                                           BorderRadiusStyle.customBorderLR24,
//                                     ),
//                                     child: Stack(
//                                       alignment: Alignment.bottomLeft,
//                                       children: [
//                                         CustomImageView(
//                                           imagePath: ImageConstant.imgArrowLeft,
//                                           height: 6.h,
//                                           width: 20.h,
//                                         ),
//                                         SizedBox(height: 30.h),
//                                         Align(
//                                           alignment: Alignment.centerLeft,
//                                           child: SizedBox(
//                                             width: 280.h,
//                                             child: RichText(
//                                               text: TextSpan(
//                                                 children: [
//                                                   TextSpan(
//                                                     text: "lbl_limited_time".tr,
//                                                     style:
//                                                         CustomTextStyles.headlineSmallRegular,
//                                                   ),
//                                                   TextSpan(
//                                                     text: "lbl_halloween_sale".tr,
//                                                     style: CustomTextStyles
//                                                         .headlineSmallPrimaryContainer,
//                                                   ),
//                                                   TextSpan(
//                                                     text: "lbl_is_coming_back".tr,
//                                                     style:
//                                                         CustomTextStyles.headlineSmallRegular,
//                                                   ),
//                                                 ],
//                                               ),
//                                               textAlign: TextAlign.left,
//                                               maxLines: 2,
//                                               overflow: TextOverflow.ellipsis,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   SizedBox(height: 4.h),
//                                   _buildDateSection(context),
//                                   SizedBox(height: 24.h),
//                                   _buildCouponCard(context),
//                                   SizedBox(height: 26.h),
//                                   Text(
//                                     "msg_lorem_ipsum_dolor".tr,
//                                     maxLines: 12,
//                                     overflow: TextOverflow.ellipsis,
//                                     style: CustomTextStyles.bodySmall12_2.copyWith(
//                                       height: 1.67,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           bottomNavigationBar: _buildExploreSection(context),
//         );
//       },
//     );
//   }

//   /// Section Widget
//   PreferredSizeWidget _buildHeader(BuildContext context) {
//     return CustomAppBar(
//       leadingWidth: 74.h,
//       leading: AppbarLeadingIconbutton(
//         imagePath: ImageConstant.imgArrowLeftOnprimary,
//         margin: EdgeInsets.only(
//           left: 24.h,
//           top: 3.h,
//           bottom: 3.h,
//         ),
//       ),
//       actions: [
//         AppbarTrailingIconbutton(
//           imagePath: ImageConstant.imgTwitter,
//           margin: EdgeInsets.only(
//             top: 3.h,
//             right: 23.h,
//             bottom: 3.h,
//           ),
//         ),
//       ],
//     );
//   }

//   /// Section Widget
//   Widget _buildDateSection(BuildContext context) {
//     return SizedBox(
//       width: double.maxFinite,
//       child: Row(
//         children: [
//           CustomImageView(
//             imagePath: ImageConstant.imgIconCalendar,
//             height: 8.h,
//             width: 8.h,
//           ),
//           RichText(
//             text: TextSpan(
//               children: [
//                 TextSpan(
//                   text: "lbl_october".tr,
//                   style: theme.textTheme.bodySmall,
//                 ),
//                 TextSpan(
//                   text: "1b_27_2022".tr,
//                   style: CustomTextStyles.bodySmallMontserrat_1,
//                 ),
//               ],
//             ),
//             textAlign: TextAlign.left,
//           ),
//         ],
//       ),
//     );
//   }

//   /// Section Widget
//   Widget _buildCouponCard(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(16.h),
//       decoration: AppDecoration.fillLightGreen.copyWith(
//         borderRadius: BorderRadiusStyle.roundedBorder24,
//       ),
//       width: double.maxFinite,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CustomIconButton(
//             height: 52.h,
//             width: 52.h,
//             padding: EdgeInsets.all(14.h),
//             decoration: IconButtonStyleHelper.fillLightGreen,
//             child: CustomImageView(
//               imagePath: ImageConstant.igTelevision,
//             ),
//           ),
//           Expanded(
//             child: Column(
//               spacing: 2,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Ibl_hlwn40".tr,
//                   style: theme.textTheme.titleMedium,
//                 ),
//                 RichText(
//                   text: TextSpan(
//                     children: [
//                       TextSpan(
//                         text: "msg_use_this_coupon".tr,
//                         style: CustomTextStyles.bodySmall9_1,
//                       ),
//                       TextSpan(
//                         text: "msg_40_off_on_your".tr,
//                         style: CustomTextStyles.bodySmallMontserrat,
//                       ),
//                     ],
//                   ),
//                   textAlign: TextAlign.left,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// Section Widget
//   Widget _buildExploreSection(BuildContext context) {
//     return SizedBox(
//       width: double.maxFinite,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           CustomElevatedButton(
//             height: 182.h,
//             text: "lbl_explore_more".tr,
//             buttonStyle: CustomButtonStyles.none,
//             decoration: CustomButtonStyles
//                 .gradientOnPrimaryContainerToOnPrimaryContainerDecoration,
//             buttonTextStyle: CustomTextStyles.titleLargeLato,
//           ),
//         ],
//       ),
//     );
//   }
// }