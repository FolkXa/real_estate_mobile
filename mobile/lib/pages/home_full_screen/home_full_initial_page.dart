// import 'package:flutter/material.dart';
// import '../../core/app_export.dart';
// import '../../widgets/app_bar/appbar_trailing_circleimage.dart';
// import '../../widgets/app_bar/custom_app_bar.dart';
// import '../../widgets/custom_search_view.dart';
// import '../bloc/home_full_bloc.dart';
// import '../home_tab_page.dart';
// import '../models/home_full_initial_model.dart';

// class HomeFullInitialPage extends StatefulWidget {
//   const HomeFullInitialPage({Key? key}) : super(key: key);

//   @override
//   HomeFullInitialPageState createState() => HomeFullInitialPageState();

//   static Widget builder(BuildContext context) {
//     return BlocProvider<HomeFullBloc>(
//       create: (context) => HomeFullBloc(
//         HomeFullState(
//           homeFullInitialModelObj: HomeFullInitialModel(),
//         ),
//       )..add(HomeFullInitialEvent),
//       child: HomeFullInitialPage(),
//     );
//   }
// }

// // ignore_for_file: must_be_immutable
// class HomeFullInitialPageState extends State<HomeFullInitialPage> with TickerProviderStateMixin {
//   late TabController tabviewController;
//   int tabIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.maxFinite,
//       decoration: AppDecoration.fillPurple,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             height: 278.h,
//             width: double.maxFinite,
//             margin: EdgeInsets.only(right: 24.h),
//             child: Stack(
//               alignment: Alignment.bottomRight,
//               children: [
//                 CustomImageView(
//                   imagePath: ImageConstant.imgEllipsel,
//                   height: 240.h,
//                   width: 254.h,
//                   alignment: Alignment.topLeft,
//                 ),
//                 Container(
//                   width: double.maxFinite,
//                   margin: EdgeInsets.only(left: 24.h),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       CustomAppBar(
//                         height: 50.h,
//                         actions: [
//                           AppbarTrailingCircleimage(
//                             imagePath: ImageConstant.imgFloatingIcon,
//                           ),
//                         ],
//                       ),
//                       Card(
//                         clipBehavior: Clip.antiAlias,
//                         elevation: 0,
//                         margin: EdgeInsets.only(left: 10.h),
//                         color: theme.colorScheme.onPrimaryContainer,
//                         shape: RoundedRectangleBorder(
//                           side: BorderSide(
//                             color: appTheme.gray300,
//                             width: 1.2.h,
//                           ),
//                           borderRadius: BorderRadiusStyle.roundedBorder24,
//                         ),
//                         child: Container(
//                           height: 50.h,
//                           width: 50.h,
//                           decoration: AppDecoration.outlineGray.copyWith(
//                             borderRadius: BorderRadiusStyle.roundedBorder24,
//                           ),
//                           child: Stack(
//                             alignment: Alignment.center,
//                             children: [
//                               CustomImageView(
//                                 imagePath: ImageConstant.imgIonNotificationsOutline,
//                                 height: 20.h,
//                                 width: 22.h,
//                                 margin: EdgeInsets.all(15.h),
//                               ),
//                               CustomImageView(
//                                 imagePath: ImageConstant.imgUser,
//                                 height: 12.h,
//                                 width: 14.h,
//                                 alignment: Alignment.topRight,
//                                 margin: EdgeInsets.fromLTRB(
//                                   25.h,
//                                   10.h,
//                                   13.h,
//                                   28.h,
//                                 ),
//                               ),
//                               CustomImageView(
//                                 imagePath: ImageConstant.imgEllipse,
//                                 height: 44.h,
//                                 width: 44.h,
//                                 radius: BorderRadius.circular(
//                                   22.h,
//                                 ),
//                                 margin: EdgeInsets.all(3.h),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 40.h),
//                   Padding(
//                     padding: EdgeInsets.only(left: 2.h),
//                     child: RichText(
//                       text: TextSpan(
//                         children: [
//                           TextSpan(
//                             text: "lbl_hey".tr,
//                             style: CustomTextStyles.headlineSmallMedium,
//                           ),
//                           TextSpan(
//                             text: " ",
//                           ),
//                           TextSpan(
//                             text: "lbl_toto".tr,
//                             style: CustomTextStyles.headlineSmallPrimaryContainer,
//                           ),
//                           TextSpan(
//                             text: " \n",
//                             style: CustomTextStyles.headlineSmallExtraBold,
//                           ),
//                           TextSpan(
//                             text: "msg_let_s_start_exploring".tr,
//                             style: CustomTextStyles.headlineSmallMedium,
//                           ),
//                           TextSpan(
//                             text: " ",
//                           ),
//                         ],
//                         textAlign: TextAlign.left,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 14.h),
//                   BlocSelector<HomeFullBloc, HomeFullState, TextEditingController?>(
//                     selector: (state) => state.searchController,
//                     builder: (context, searchController) {
//                       return CustomSearchView(
//                         controller: searchController,
//                         hintText: "msg_search_house_apartment".tr,
//                         contentPadding: EdgeInsets.symmetric(
//                           horizontal: 16.h,
//                           vertical: 24.h,
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
