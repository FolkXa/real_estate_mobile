import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('favorite_real_estate')
            .where('user_id', isEqualTo: currentUser.uid)
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

                  final data = realEstateSnapshot.data!.data() as Map;

                  return Card(
                    margin: EdgeInsets.all(10),
                    elevation: 4,
                    child: ListTile(
                      leading: Image.network(
                        data['image_url'] ??
                            'https://via.placeholder.com/100', // ใช้ image_path ถ้ามี
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                      title: Text(data['name']),
                      subtitle: Text("${data['price']} บาท"),
                      trailing: Icon(Icons.favorite, color: Colors.red),
                      onTap: () {
                        // ไปหน้า details ได้ที่นี่
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
