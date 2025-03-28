import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:real_estate_project/RealEstateCard.dart';
import 'package:real_estate_project/screens/property_detail.dart';
import 'package:real_estate_project/services/firebase_service.dart';
import 'package:shimmer/shimmer.dart';

class SearchResultPage extends StatefulWidget {
  final String? province;
  final String? amphure;
  final String? tambon;
  final String? propertyType;
  final int? bedroom;
  final int? bathroom;
  final double? minPrice;
  final double? maxPrice;
  final double? minRent;
  final double? maxRent;
  final List<String>? saleTypes;

  const SearchResultPage({
    Key? key,
    required this.province,
    required this.amphure,
    required this.tambon,
    required this.propertyType,
    required this.bedroom,
    required this.bathroom,
    required this.minPrice,
    required this.maxPrice,
    required this.minRent,
    required this.maxRent,
    required this.saleTypes,
  }) : super(key: key);

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  Set<int> favoriteIds = {};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favs = await FirebaseService().getFavoriteIds();
    setState(() {
      favoriteIds = favs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("ผลลัพธ์การค้นหา"),
          backgroundColor: Colors.purple,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<QueryDocumentSnapshot>>(
            future: _getSearchResults(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text("ไม่พบอสังหาริมทรัพย์ที่ตรงกับเงื่อนไข",
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                );
              }

              var results = snapshot.data!;

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.75,
                ),
                itemCount: results.length,
                itemBuilder: (context, index) {
                  var item = results[index].data() as Map<String, dynamic>;
                  final realEstateId = item['real_estate_id'];

                  return FutureBuilder<String>(
                    future: _getThumbnailImage(realEstateId),
                    builder: (context, imageSnapshot) {
                      if (!imageSnapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PropertyDetailScreen(
                                  realEstateId: realEstateId),
                            ),
                          );
                        },
                        child: RealEstateCard(
                          realEstateId: realEstateId,
                          imagePath: imageSnapshot.data!,
                          price: item['price'].toString(),
                          name: item['name'] ?? "ไม่ระบุชื่อ",
                          location:
                              "${item['province'] ?? ''} | ${item['type_realestate'] ?? ''}",
                          sellType: item['type_sell'] ?? "",
                          isInitiallyFavorite:
                              favoriteIds.contains(realEstateId),
                          onToggleFavorite: (id) async {
                            final result =
                                await FirebaseService.toggleFavoriteInFirestore(
                                    id);
                            setState(() {
                              if (result) {
                                favoriteIds.add(id);
                              } else {
                                favoriteIds.remove(id);
                              }
                            });
                            return result;
                          },
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ));
  }

  Future<List<QueryDocumentSnapshot>> _getSearchResults() async {
    final CollectionReference realEstateRef =
        FirebaseFirestore.instance.collection('real_estate');

    List<Query> queries = [];

    Query buildQuery(Query queryBase, {bool forRent = false}) {
      Query query = queryBase;

      if (widget.province != null && widget.province!.isNotEmpty) {
        query = query.where('province', isEqualTo: widget.province);
      }
      if (widget.propertyType != null && widget.propertyType!.isNotEmpty) {
        query = query.where('type_realestate', isEqualTo: widget.propertyType);
      }
      if (widget.bedroom != null) {
        query = query.where('bedroom', isGreaterThanOrEqualTo: widget.bedroom);
      }
      if (widget.bathroom != null) {
        query =
            query.where('bathroom', isGreaterThanOrEqualTo: widget.bathroom);
      }

      if (!forRent) {
        if (widget.minPrice != null) {
          query = query.where('price', isGreaterThanOrEqualTo: widget.minPrice);
        }
        if (widget.maxPrice != null) {
          query = query.where('price', isLessThanOrEqualTo: widget.maxPrice);
        }
      }

      if (forRent) {
        if (widget.minRent != null) {
          query = query.where('price', isGreaterThanOrEqualTo: widget.minRent);
        }
        if (widget.maxRent != null) {
          query = query.where('price', isLessThanOrEqualTo: widget.maxRent);
        }
      }

      return query;
    }

    if (widget.saleTypes != null && widget.saleTypes!.isNotEmpty) {
      for (var type in widget.saleTypes!) {
        if (type == "ขายขาด") {
          queries.add(buildQuery(
              realEstateRef.where('type_sell', isEqualTo: 'ขายขาด')));
        } else if (type == "เช่า") {
          queries.add(buildQuery(
              realEstateRef.where('type_sell', isEqualTo: 'เช่า'),
              forRent: true));
        }
      }
    } else {
      queries.add(buildQuery(realEstateRef));
    }

    List<QuerySnapshot> snapshots =
        await Future.wait(queries.map((q) => q.get()));

    final seenIds = <String>{};
    final allDocs = snapshots.expand((snapshot) => snapshot.docs).where((doc) {
      final id = doc['real_estate_id']?.toString();
      if (id == null || seenIds.contains(id)) return false;
      seenIds.add(id);
      return true;
    }).toList();

    return allDocs;
  }

  Future<String> _getThumbnailImage(int realEstateId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('image_real_estate')
        .where('real_estate_id', isEqualTo: realEstateId)
        .where('title_img', isEqualTo: 1)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data() as Map<String, dynamic>;
      if (data['image_path'] != null &&
          data['image_path'].toString().isNotEmpty) {
        return data['image_path'];
      }
    }

    return "https://pub-33d01538ba524615b21478ed0f03e519.r2.dev/placeholder.jpg";
  }
}
