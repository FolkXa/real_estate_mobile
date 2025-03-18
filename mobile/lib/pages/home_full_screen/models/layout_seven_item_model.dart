import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';

/// This class is used in the [layout_seven_item_widget] screen.
// ignore_for_file: must_be_immutable
class LayoutSevenItemModel extends Equatable {
  LayoutSevenItemModel({
    this.baliOne,
    this.baliTwo,
    this.id,
  }) {
    baliOne = baliOne ?? ImageConstant.imgShape40x40;
    baliTwo = baliTwo ?? "lbl_bali".tr;
    id = id ?? "";
  }

  String? baliOne;
  String? baliTwo;
  String? id;

  LayoutSevenItemModel copyWith({
    String? baliOne,
    String? baliTwo,
    String? id,
  }) {
    return LayoutSevenItemModel(
      baliOne: baliOne ?? this.baliOne,
      baliTwo: baliTwo ?? this.baliTwo,
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [baliOne, baliTwo, id];
}
