import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:real_estate_project/screens/property_detail.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  Future<String> _getTitleImagePath(int realEstateId) async {
    final imageSnapshot = await FirebaseFirestore.instance
        .collection('image_real_estate')
        .where('real_estate_id', isEqualTo: realEstateId)
        .where('title_img', isEqualTo: 1)
        .limit(1)
        .get();

    if (imageSnapshot.docs.isNotEmpty) {
      return "https://your-cdn-url.com/${imageSnapshot.docs.first['image_path']}";
    } else {
      return "https://via.placeholder.com/150"; // fallback image
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text("รายการโปรด")),
        body: Center(child: Text("กรุณาเข้าสู่ระบบ")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("รายการโปรด")),
      body: FutureBuilder<int?>(
        future: getCurrentUserId(),
        builder: (context, userIdSnapshot) {
          if (!userIdSnapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final userId = userIdSnapshot.data!;
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('favorite_real_estate')
                .where('user_id', isEqualTo: userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return Center(child: CircularProgressIndicator());

              final favorites = snapshot.data?.docs ?? [];

              if (favorites.isEmpty) {
                return Center(child: Text("ยังไม่มีรายการโปรด"));
              }

              return ListView.builder(
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final favorite = favorites[index];
                  final realEstateId = favorite['real_estate_id'];

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('real_estate')
                        .doc(realEstateId.toString())
                        .get(),
                    builder: (context, realEstateSnapshot) {
                      if (!realEstateSnapshot.hasData)
                        return ListTile(title: Text("กำลังโหลด..."));

                      final data = realEstateSnapshot.data!.data()
                          as Map<String, dynamic>;

                      return FutureBuilder<String>(
                        future: _getTitleImagePath(realEstateId),
                        builder: (context, imageSnapshot) {
                          final imageUrl = imageSnapshot.data ??
                              "https://via.placeholder.com/150";

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PropertyDetailScreen(
                                      realEstateId: realEstateId),
                                ),
                              );
                            },
                            child: Card(
                              margin: EdgeInsets.all(10),
                              elevation: 4,
                              child: Row(
                                children: [
                                  Container(
                                    width: 120,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.horizontal(
                                          left: Radius.circular(10)),
                                      image: DecorationImage(
                                        image: NetworkImage(imageUrl),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data['name'],
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            "${data['province']} • ${data['price']} บาท",
                                            style: TextStyle(
                                                color: Colors.grey.shade600),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.favorite, color: Colors.red),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<int?> getCurrentUserId() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return null;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: currentUser.email)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first['user_id'] as int;
    } else {
      return null;
    }
  }
}
