import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_project/core/user_manager.dart';
import '../../../core/app_export.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              return Text('Hello, !');
              // Container(
              //   width: double.maxFinite,
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     borderRadius: BorderRadius.circular(16.h),
              //   ),
              //   padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 24.h),
              //   child: Column(
              //     children: [
              //       SizedBox(height: 16.h),
              //       Text(
              //         'Hey, ${state.username}! \nLet\'s start exploring ',
              //         style: CustomTextStyles.headlineSmallBold,
              //       ),
              //       SizedBox(height: 24.h),
              //       Text(
              //         'This is a sample home page',
              //         style: CustomTextStyles.bodySmall,
              //       ),
              //       SizedBox(height: 16.h),
              //     ],
              //   ),
              // );
            },
          ),
        ),
      ),
    );
  }
}

