import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';
import 'gridwings_tower_item_model.dart';
import 'layout_eight_item_model.dart';
import 'layout_seven_item_model.dart';
import 'listhot_saleone_item_model.dart';

/// This class is used in the [home_tab_pagel screen.
// ignore_for_file: must_be_immutable
class HomeTabModel extends Equatable {
  HomeTabModel({
    this.listhotSaleoneItemList = const [],
    this.layoutSevenItemList = const [],
    this.layoutEightItemList = const [],
    this.gridwingsTowerItemList = const [],
  });

  List<ListhotSaleoneItemModel> listhotSaleoneItemList;
  List<LayoutSevenItemModel> layoutSevenItemList;
  List<LayoutEightItemModel> layoutEightItemList;
  List<GridwingsTowerItemModel> gridwingsTowerItemList;

  HomeTabModel copyWith({
    List<ListhotSaleoneItemModel>? listhotSaleoneItemList,
    List<LayoutSevenItemModel>? layoutSevenItemList,
    List<LayoutEightItemModel>? layoutEightItemList,
    List<GridwingsTowerItemModel>? gridwingsTowerItemList,
  }) {
    return HomeTabModel(
      listhotSaleoneItemList: listhotSaleoneItemList ?? this.listhotSaleoneItemList,
      layoutSevenItemList: layoutSevenItemList ?? this.layoutSevenItemList,
      layoutEightItemList: layoutEightItemList ?? this.layoutEightItemList,
      gridwingsTowerItemList: gridwingsTowerItemList ?? this.gridwingsTowerItemList,
    );
  }

  @override
  List<Object?> get props => [
        listhotSaleoneItemList,
        layoutSevenItemList,
        layoutEightItemList,
        gridwingsTowerItemList,
      ];
}
