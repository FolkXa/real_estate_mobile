import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';

// This class is used in the [gridwings_tower_item_widget] screen.
// ignore_for_file: must_be_immutable
class GridwingsTowerItemModel extends Equatable {
  GridwingsTowerItemModel({
    this.wingsTowerOne,
    this.favoriteOne,
    this.price,
    this.month,
    this.wingsTowerTwo,
    this.text,
    this.imageOne,
    this.jakartaindonesi,
    this.id,
  }) {
    wingsTowerOne = wingsTowerOne ?? ImageConstant.imgShape160x144;
    favoriteOne = favoriteOne ?? ImageConstant.imgFavorite;
    price = price ?? "lbl_220".tr;
    month = month ?? "lbl_month".tr;
    wingsTowerTwo = wingsTowerTwo ?? "lbl_wings_tower".tr;
    text = text ?? "lbl_4_9".tr;
    imageOne = imageOne ?? ImageConstant.imgLinkedin;
    jakartaindonesi = jakartaindonesi ?? "msg_jakarta_indonesia".tr;
    id = id ?? "";
  }

  String? wingsTowerOne;
  String? favoriteOne;
  String? price;
  String? month;
  String? wingsTowerTwo;
  String? text;
  String? imageOne;
  String? jakartaindonesi;
  String? id;

  GridwingsTowerItemModel copyWith({
    String? wingsTowerOne,
    String? favoriteOne,
    String? price,
    String? month,
    String? wingsTowerTwo,
    String? text,
    String? imageOne,
    String? jakartaindonesi,
    String? id,
  }) {
    return GridwingsTowerItemModel(
      wingsTowerOne: wingsTowerOne ?? this.wingsTowerOne,
      favoriteOne: favoriteOne ?? this.favoriteOne,
      price: price ?? this.price,
      month: month ?? this.month,
      wingsTowerTwo: wingsTowerTwo ?? this.wingsTowerTwo,
      text: text ?? this.text,
      imageOne: imageOne ?? this.imageOne,
      jakartaindonesi: jakartaindonesi ?? this.jakartaindonesi,
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [
        wingsTowerOne,
        favoriteOne,
        price,
        month,
        wingsTowerTwo,
        text,
        imageOne,
        jakartaindonesi,
        id,
      ];
}
