part of 'home_promotion_bloc.dart';

/// Represents the state of HomePromotion in the application.
// ignore_for_file: must_be_immutable
class HomePromotionState extends Equatable {
  HomePromotionState({this.homePromotionModelObj});

  HomePromotionModel? homePromotionModelObj;

  @override
  List<Object?> get props => [homePromotionModelObj];

  HomePromotionState copyWith({HomePromotionModel? homePromotionModelObj}) {
    return HomePromotionState(
      homePromotionModelObj: homePromotionModelObj ?? this.homePromotionModelObj,
    );
  }
}