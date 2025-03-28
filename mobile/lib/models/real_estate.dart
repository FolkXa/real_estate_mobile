class RealEstate {
  final bool active;
  final int area;
  final String address;
  final String amphur;
  final int bathroom;
  final int bedroom;
  final String details;
  final String name;
  final bool premiumPromote;
  final int price;
  final String promoteAt;
  final String promoteEnd;
  final String province;
  final int realEstateId;
  final String tambon;
  final String typeRealestate;
  final String typeSell;
  final int userId;
  final int view;
  final int workerService;
  final List<String> images;

  RealEstate({
    required this.active,
    required this.area,
    required this.address,
    required this.amphur,
    required this.bathroom,
    required this.bedroom,
    required this.details,
    required this.name,
    required this.premiumPromote,
    required this.price,
    required this.promoteAt,
    required this.promoteEnd,
    required this.province,
    required this.realEstateId,
    required this.tambon,
    required this.typeRealestate,
    required this.typeSell,
    required this.userId,
    required this.view,
    required this.workerService,
    required this.images,
  });

  factory RealEstate.fromMap(Map<String, dynamic> map) {
    return RealEstate(
      active: map['active'] ?? false,
      area: map['area'] ?? 0,
      address: map['address'] ?? '',
      amphur: map['amphur'] ?? '',
      bathroom: map['bathroom'] ?? 0,
      bedroom: map['bedroom'] ?? 0,
      details: map['details'] ?? '',
      name: map['name'] ?? '',
      premiumPromote: map['premium_promote'] ?? false,
      price: map['price'] ?? 0,
      promoteAt: map['promote_at'] ?? '',
      promoteEnd: map['promote_end'] ?? '',
      province: map['province'] ?? '',
      realEstateId: map['real_estate_id'] ?? 0,
      tambon: map['tambon'] ?? '',
      typeRealestate: map['type_realestate'] ?? '',
      typeSell: map['type_sell'] ?? '',
      userId: map['user_id'] ?? 0,
      view: map['view'] ?? 0,
      workerService: map['worker_service'] ?? 0,
      images: List<String>.from(map['images'] ?? []),
    );
  }
}
