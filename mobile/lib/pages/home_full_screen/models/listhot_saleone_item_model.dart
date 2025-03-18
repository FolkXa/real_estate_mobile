import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';

/// This class is used in the [listhot_saleone_item widgetl screen.
// ignore_for_file: must_be_immutable
class ListhotSaleoneItemModel extends Equatable {
  ListhotSaleoneItemModel({
    this.hotSaleone,
    this.hotSaletwo,
    this.offer,
    this.arrowleftOne,
    this.id,
  }) {
    hotSaleone = hotSaleone ?? ImageConstant.imgImage25;
    hotSaletwo = hotSaletwo ?? "lbl_hot_sale".tr;
    offer = offer ?? "msg_all_discount_up".tr;
    arrowleftOne = arrowleftOne ?? ImageConstant.imgArrowLeft;
    id = id ?? "";
  }

  String? hotSaleone;
  String? hotSaletwo;
  String? offer;
  String? arrowleftOne;
  String? id;

  ListhotSaleoneItemModel copyWith({
    String? hotSaleone,
    String? hotSaletwo,
    String? offer,
    String? arrowleftOne,
    String? id,
  }) {
    return ListhotSaleoneItemModel(
      hotSaleone: hotSaleone ?? this.hotSaleone,
      hotSaletwo: hotSaletwo ?? this.hotSaletwo,
      offer: offer ?? this.offer,
      arrowleftOne: arrowleftOne ?? this.arrowleftOne,
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [hotSaleone, hotSaletwo, offer, arrowleftOne, id];
}