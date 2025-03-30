import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:real_estate_project/widgets/RealEstateCard.dart';
import 'package:real_estate_project/screens/property_detail.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

class SubCategoryScreen extends StatefulWidget {
  final String category;

  const SubCategoryScreen({super.key, required this.category});

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  Set<int> favoriteIds = {}; // เก็บ real_estate_id ที่ถูกใจ
  final currentUser = FirebaseAuth.instance.currentUser;

  Future<bool> toggleFavoriteInFirestore(int realEstateId) async {
    final userEmail = currentUser?.email;
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: userEmail)
        .limit(1)
        .get();

    if (userSnapshot.docs.isEmpty) return false;
    final userId = userSnapshot.docs.first['user_id'];

    final favoriteRef =
        FirebaseFirestore.instance.collection('favorite_real_estate');

    final existing = await favoriteRef
        .where('user_id', isEqualTo: userId)
        .where('real_estate_id', isEqualTo: realEstateId)
        .get();

    if (existing.docs.isNotEmpty) {
      await favoriteRef.doc(existing.docs.first.id).delete();
      favoriteIds.remove(realEstateId); // อัปเดตใน memory เฉย ๆ
      return false; // ❌ ถูกลบ
    } else {
      await favoriteRef.add({
        "user_id": userId,
        "real_estate_id": realEstateId,
        "favorite_id": DateTime.now().millisecondsSinceEpoch,
      });
      favoriteIds.add(realEstateId); // ✅ เพิ่ม
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('real_estate')
        .where('active', isEqualTo: true); // default ทุกกรณี

    // ✅ ถ้าไม่ใช่ "ทั้งหมด" ค่อยเพิ่ม where 'type_realestate'
    if (widget.category != "ทั้งหมด") {
      query = query.where('type_realestate', isEqualTo: widget.category);
    }

    return Scaffold(
      appBar: AppBar(title: Text("ประเภท: ${widget.category}")),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return Center(child: Text("ไม่มีอสังหาริมทรัพย์ในหมวดนี้"));

          var estates = snapshot.data!.docs;

          return GridView.builder(
            padding: EdgeInsets.all(12),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: estates.length,
            itemBuilder: (context, index) {
              var data = estates[index].data() as Map<String, dynamic>;

              int realEstateId = data["real_estate_id"];
              String price = data["price"].toString();
              String name = data["name"] ?? "ไม่ระบุชื่อ";
              String location = data["province"] ?? "ไม่ระบุ";
              String sellType = data["type_sell"];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PropertyDetailScreen(realEstateId: realEstateId),
                    ),
                  );
                },
                child: FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('image_real_estate')
                      .where('real_estate_id', isEqualTo: realEstateId)
                      .where('title_img', isEqualTo: 1)
                      .limit(1)
                      .get(),
                  builder: (context, imgSnap) {
                    String imagePath = "assets/images/house1.jpg";
                    if (imgSnap.hasData && imgSnap.data!.docs.isNotEmpty) {
                      imagePath =
                          imgSnap.data!.docs.first['image_path'] ?? imagePath;
                    }

                    return RealEstateCard(
                        realEstateId: realEstateId,
                        imagePath: imagePath,
                        price: price,
                        name: name,
                        location: location,
                        sellType: sellType);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
