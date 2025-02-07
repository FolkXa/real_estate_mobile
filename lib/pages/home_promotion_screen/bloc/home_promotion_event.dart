part of 'home_promotion_bloc.dart';

/// Abstract class for all events that can be dispatched from the
/// HomePromotion widget.
///
/// Events must be immutable and implement the [Equatable] interface.
abstract class HomePromotionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event that is dispatched when the HomePromotion widget is first created.
class HomePromotionInitialEvent extends HomePromotionEvent {
  @override
  List<Object?> get props => [];
}
