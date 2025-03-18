import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';

/// This class is used in the [layout_eight_item_widget] screen.
// ignore_for_file: must_be_immutable
class LayoutEightItemModel extends Equatable {
  LayoutEightItemModel({
    this.amandaOne,
    this.amandaTwo,
    this.id,
  }) {
    amandaOne = amandaOne ?? ImageConstant.imgShape70x70;
    amandaTwo = amandaTwo ?? "lbl_amanda".tr;
    id = id ?? "";
  }

  String? amandaOne;
  String? amandaTwo;
  String? id;

  LayoutEightItemModel copyWith({
    String? amandaOne,
    String? amandaTwo,
    String? id,
  }) {
    return LayoutEightItemModel(
      amandaOne: amandaOne ?? this.amandaOne,
      amandaTwo: amandaTwo ?? this.amandaTwo,
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [amandaOne, amandaTwo, id];
}

