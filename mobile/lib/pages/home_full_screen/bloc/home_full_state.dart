part of 'home_full_bloc.dart';

/// Represents the state of HomeFull in the application.
// ignore_for_file: must_be_immutable
class HomeFullState extends Equatable {
  HomeFullState({
    this.searchController,
    this.homeFullInitialModelObj,
    this.homeTabModelObj,
    this.homeFullModelObj,
    this.currentIndex,
  });

  TextEditingController? searchController;
  HomeFullModel? homeFullModelObj;
  HomeFullInitialModel? homeFullInitialModelObj;
  HomeTabModel? homeTabModelObj;
  int? currentIndex;

  @override
  List<Object?> get props => [
        searchController,
        homeFullInitialModelObj,
        homeTabModelObj,
        homeFullModelObj,
        currentIndex,
      ];

  HomeFullState copyWith({
    TextEditingController? searchController,
    HomeFullInitialModel? homeFullInitialModelObj,
    HomeTabModel? homeTabModelObj,
    HomeFullModel? homeFullModelObj,
    int? currentIndex,
  }) {
    return HomeFullState(
      searchController: searchController ?? this.searchController,
      homeFullInitialModelObj: homeFullInitialModelObj ?? this.homeFullInitialModelObj,
      homeTabModelObj: homeTabModelObj ?? this.homeTabModelObj,
      homeFullModelObj: homeFullModelObj ?? this.homeFullModelObj,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

