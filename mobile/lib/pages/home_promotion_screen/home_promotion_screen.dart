import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import 'bloc/home_promotion_bloc.dart';
import 'models/home_promotion_model.dart';

class HomePromotionScreen extends StatelessWidget {

  const HomePromotionScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return BlocProvider<HomePromotionBloc>(
      create: (context) => HomePromotionBloc(HomePromotionState(
        homePromotionModelObj: HomePromotionModel(),
      ))..add(HomePromotionInitialEvent()),
      child: HomePromotionScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Promotion'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Home Promotion Screen',
              style: CustomTextStyles.headlineSmallBold,
            ),
            const SizedBox(height: 16),
            CustomImageView(
              imagePath: ImageConstant.imgPromotion,
              height: 200,
              width: double.infinity,
            ),
            const SizedBox(height: 16),
            Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
              'Sed sit amet nulla auctor, vestibulum magna sed, convallis ex. '
              'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.',
              style: CustomTextStyles.bodySmallMontserrat_1,
            ),
          ],
        ),
      ),
    );
  }
}
