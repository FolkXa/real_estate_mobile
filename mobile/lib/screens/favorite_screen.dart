import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:real_estate_project/screens/property_detail.dart';
import 'package:real_estate_project/widgets/RealEstateCard.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  Set<int> favoriteIds = {};

  Future<int?> getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final data = snapshot.docs.first.data();
      print("👉 user document: $data");

      final rawId = data['user_id'];
      return int.tryParse(rawId.toString());
    } catch (e) {
      debugPrint("❌ Error fetching user: $e");
      return null;
    }
  }

  Future<bool> toggleFavorite(int realEstateId) async {
    final userId = await getCurrentUserId();
    if (userId == null) return false;

    final favRef =
        FirebaseFirestore.instance.collection('favorite_real_estate');
    final existing = await favRef
        .where('user_id', isEqualTo: userId)
        .where('real_estate_id', isEqualTo: realEstateId)
        .get();

    if (existing.docs.isNotEmpty) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("ลบรายการโปรด"),
          content:
              Text("คุณต้องการลบอสังหาริมทรัพย์นี้ออกจากรายการโปรดหรือไม่?"),
          actions: [
            TextButton(
              child: Text("ยกเลิก"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              child: Text("ยืนยัน"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await favRef.doc(existing.docs.first.id).delete();
        setState(() {
          favoriteIds.remove(realEstateId);
        });
        _showSnack("ลบออกจากรายการโปรดแล้ว", Colors.red);
        return false;
      } else {
        return true; // กดยกเลิกไม่ลบ
      }
    } else {
      await favRef.add({
        "user_id": userId,
        "real_estate_id": realEstateId,
        "favorite_id": DateTime.now().millisecondsSinceEpoch,
      });
      setState(() {
        favoriteIds.add(realEstateId);
      });
      _showSnack("เพิ่มเข้ารายการโปรดแล้ว", Colors.green);
      return true;
    }
  }

  Future<String> _getTitleImagePath(int realEstateId) async {
    final imageSnapshot = await FirebaseFirestore.instance
        .collection('image_real_estate')
        .where('real_estate_id', isEqualTo: realEstateId)
        .where('title_img', isEqualTo: 1)
        .limit(1)
        .get();

    if (imageSnapshot.docs.isNotEmpty) {
      final path = imageSnapshot.docs.first['image_path'];

      // ถ้ามี path ที่ใช้ได้ (เช่น https://... จาก Cloudflare R2)
      if (path.startsWith("http")) {
        return path;
      }

      // หรือประกอบเป็น URL จาก CDN จริงของคุณ
      return "https://your-real-cdn.com/$path";
    } else {
      return "https://via.placeholder.com/150";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("รายการโปรด"),
      ),
      body: FutureBuilder<int?>(
        future: getCurrentUserId(),
        builder: (context, userIdSnapshot) {
          if (userIdSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!userIdSnapshot.hasData || userIdSnapshot.data == null) {
            return Center(child: Text("ไม่พบข้อมูลผู้ใช้"));
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

              final favoriteDocs = snapshot.data?.docs ?? [];
              final realEstateIds = favoriteDocs
                  .map((doc) => doc['real_estate_id'] as int)
                  .toList();

              favoriteIds.addAll(realEstateIds); // sync ครั้งแรก

              if (realEstateIds.isEmpty) {
                return Center(child: Text("ยังไม่มีรายการโปรด"));
              }

              return ListView.builder(
                itemCount: realEstateIds.length,
                itemBuilder: (context, index) {
                  final id = realEstateIds[index];
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('real_estate')
                        .doc(id.toString())
                        .get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return SizedBox();
                      final data =
                          snapshot.data!.data() as Map<String, dynamic>;

                      return FutureBuilder<String>(
                        future: _getTitleImagePath(id),
                        builder: (context, imgSnap) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PropertyDetailScreen(realEstateId: id),
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
                                        image: NetworkImage(imgSnap.data ?? ""),
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
                                            data['name'] ?? '',
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
                                  IconButton(
                                    icon: Icon(
                                      favoriteIds.contains(id)
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      final newStatus =
                                          await toggleFavorite(id);
                                      setState(() {
                                        if (newStatus) {
                                          favoriteIds.add(id);
                                        } else {
                                          favoriteIds.remove(id);
                                        }
                                      });
                                    },
                                  ),
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

  void _showSnack(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontSize: 14)),
        duration: Duration(seconds: 2),
        backgroundColor: backgroundColor,
      ),
    );
  }
}
