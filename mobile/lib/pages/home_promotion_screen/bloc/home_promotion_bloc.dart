import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';
import '../models/home_promotion_model.dart';
part 'home_promotion_event.dart';
part 'home_promotion_state.dart';

/// A bloc that manages the state of a HomePromotion according to the event that is dispatched to it.
class HomePromotionBloc extends Bloc<HomePromotionEvent, HomePromotionState> {
  HomePromotionBloc(HomePromotionState initialState) : super(initialState) {
    on<HomePromotionInitialEvent>(_onInitialize);
  }

  void _onInitialize(
    HomePromotionInitialEvent event,
    Emitter<HomePromotionState> emit,
  ) async {}
}
