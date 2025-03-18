import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';
import '../models/gridwings_tower_item_model.dart';
import '../models/home_full_initial_model.dart';
import '../models/home_full_model.dart';
import '../models/home_tab_model.dart';
import '../models/layout_eight_item_model.dart';
import '../models/layout_seven_item_model.dart';
import '../models/listhot_saleone_item_model.dart';
part 'home_full_event.dart';
part 'home_full_state.dart';

/// A bloc that manages the state of a HomeFull according to the event that is dispatched to it.
class HomeFullBloc extends Bloc<HomeFullEvent, HomeFullState> {
  HomeFullBloc(HomeFullState initialState) : super(initialState) {
    on<HomeFullInitialEvent>(_onInitializeFull);
    on<HomeFullUpdateIndexEvent>(_onUpdateIndex);
  }

  void _onUpdateIndex(
    HomeFullUpdateIndexEvent event,
    Emitter<HomeFullState> emit,
  ) {
    emit(state.copyWith(currentIndex: event.newIndex));
  }

  void _onInitializeFull(
    HomeFullInitialEvent event,
    Emitter<HomeFullState> emit,
  ) async {
    emit(
      HomeFullState(
        searchController: TextEditingController(),
        homeFullInitialModelObj: HomeFullInitialModel(),
        homeTabModelObj: HomeTabModel(),
        homeFullModelObj: HomeFullModel(),
        currentIndex: 0,
      ),
    );
  }

  @override
  Stream<HomeFullState> mapEventToState(HomeFullEvent event) async* {
    if (event is HomeFullInitialEvent) {
      yield _onInitialize(event);
    }
  }

  HomeFullState _onInitialize(HomeFullInitialEvent event) {
    return state.copyWith(
      searchController: TextEditingController(),
    );
  }

  List<GridwingsTowerItemModel> fillGridwingsTowerItemList() {
    return [
      GridwingsTowerItemModel(
        wingsTowerOne: ImageConstant.imgShape160x144,
        favoriteOne: ImageConstant.imgFavorite,
        price: "lbl_220".tr,
        month: "lbl_month".tr,
        wingsTowerTwo: "lbl_wings_tower".tr,
        text: "lbl_4_9".tr,
        imageOne: ImageConstant.imgLinkedin,
        jakartaindonesi: "msg_jakarta_indonesia".tr,
      ),
      GridwingsTowerItemModel(
        wingsTowerOne: ImageConstant.imgShape8,
        favoriteOne: ImageConstant.imgGroup321,
        price: "lbl_271".tr,
        month: "lbl_month".tr,
        wingsTowerTwo: "lbl_mill_sper_house".tr,
        text: "lbl_4_8".tr,
        imageOne: ImageConstant.imgLinkedin,
        jakartaindonesi: "msg_jakarta_indonesia".tr,
      ),
      GridwingsTowerItemModel(
        wingsTowerOne: ImageConstant.imgShape160x144,
        favoriteOne: ImageConstant.imgGroup321,
        price: "lbl_235".tr,
        month: "lbl_month".tr,
        wingsTowerTwo: "lbl_bungalow_house".tr,
        text: "lbl_4_7".tr,
        imageOne: ImageConstant.imgLinkedinDeepOrangeA200,
        jakartaindonesi: "msg_jakarta_indonesia".tr,
      ),
      GridwingsTowerItemModel(
        wingsTowerOne: ImageConstant.imgShape10,
        favoriteOne: ImageConstant.imgGroup321,
        price: "lbl_290".tr,
        month: "lbl_month".tr,
        wingsTowerTwo: "msg_sky_dandelions_apartment2".tr,
        text: "lbl_4_9".tr,
        imageOne: ImageConstant.imgLinkedinDeepOrangeA200,
        jakartaindonesi: "msg_jakarta_indonesia".tr,
      ),
    ];
  }

  List<LayoutEightItemModel> fillLayoutEightItemList() {
    return [
      LayoutEightItemModel(
        amandaOne: ImageConstant.imgShape70x70,
        amandaTwo: "lbl_amanda".tr,
      ),
      LayoutEightItemModel(
        amandaOne: ImageConstant.imgShape4,
        amandaTwo: "lbl_anderson".tr,
      ),
      LayoutEightItemModel(
        amandaOne: ImageConstant.imgShape5,
        amandaTwo: "lbl_samantha".tr,
      ),
      LayoutEightItemModel(
        amandaOne: ImageConstant.imgShape6,
        amandaTwo: "lbl_andrew".tr,
      ),
      LayoutEightItemModel(
        amandaOne: ImageConstant.imgShape7,
        amandaTwo: "lbl_jakarta".tr,
      ),
    ];
  }

  List<LayoutSevenItemModel> fillLayoutSevenItemList() {
    return [
      LayoutSevenItemModel(
        baliOne: ImageConstant.imgShape40x40,
        baliTwo: "lbl_bali".tr,
      ),
      LayoutSevenItemModel(
        baliOne: ImageConstant.imgShape4,
        baliTwo: "lbl_jakarta".tr,
      ),
      LayoutSevenItemModel(
        baliOne: ImageConstant.imgShape5,
        baliTwo: "lbl_yogyakarta".tr,
      ),
      LayoutSevenItemModel(
        baliOne: ImageConstant.imgShape3,
        baliTwo: "lbl_semarang".tr,
      ),
    ];
  }

  List<ListhotSaleoneItemModel> fillHotsaleoneItemList() {
    return [
      ListhotSaleoneItemModel(
        hotSaleone: ImageConstant.imgImage25,
        hotSaletwo: "lbl_hot_sale".tr,
        offer: "msg_all_discount_up".tr,
        arrowleftOne: ImageConstant.imgArrowLeft,
      ),
      ListhotSaleoneItemModel(
        hotSaleone: ImageConstant.imgRectangle16,
        hotSaletwo: "lbl_summer_vacation".tr,
        offer: "msg_all_discount_up".tr,
        arrowleftOne: ImageConstant.imgArrowLeft,
      ),
      ListhotSaleoneItemModel(
        hotSaleone: ImageConstant.imgGettyimages175767618,
      ),
    ];
  }
}
