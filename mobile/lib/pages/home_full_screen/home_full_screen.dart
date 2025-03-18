import 'package:flutter/material.dart';
import 'package:real_estate_project/pages/home_screen/home_screen.dart';
import '../../../core/app_export.dart';
import 'bloc/home_full_bloc.dart';
import 'models/home_full_model.dart';

class HomeFullScreen extends StatelessWidget {
  const HomeFullScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return BlocProvider<HomeFullBloc>(
      create: (context) => HomeFullBloc(HomeFullState(
        homeFullModelObj: HomeFullModel(),
      ))
        ..add(HomeFullInitialEvent()),
      child: HomeFullScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<HomeFullBloc, HomeFullState>(
        builder: (context, state) {
          return IndexedStack(
            index: state.currentIndex,
            children: [
              HomeScreen(),
              Center(child: Text("Search Screen")),
              Center(child: Text("Favorite Screen")),
              Center(child: Text("Dashboard Screen")),
              Center(child: Text("Profile Screen")),
            ],
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<HomeFullBloc, HomeFullState>(
        builder: (context, state) {
          return BottomNavigationBar(
            iconSize: 32.0,
            selectedFontSize: 0.0,
            unselectedFontSize: 0.0,
            type: BottomNavigationBarType.fixed,
            currentIndex: state.currentIndex ?? 0,
            onTap: (index) {
              context.read<HomeFullBloc>().add(HomeFullUpdateIndexEvent(index));
            },
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.search),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.favorite),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.dashboard),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person),
                label: '',
              ),
            ],
          );
        },
      ),
    );
  }
}

