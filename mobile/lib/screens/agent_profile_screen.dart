import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:real_estate_project/screens/property_detail.dart';
import 'package:real_estate_project/screens/RealEstateCard.dart';
import 'package:real_estate_project/services/firebase_service.dart';

class AgentProfileScreen extends StatelessWidget {
  final Map<String, dynamic> agent;

  const AgentProfileScreen({super.key, required this.agent});

  @override
  Widget build(BuildContext context) {
    int agentId = agent['user_id'];
    String fullName = "${agent['first_name']} ${agent['last_name']}";
    String nickname = agent['nick_name'];
    String phone = agent['phone_number'];
    String email = agent['email'];
    String imagePath = agent['image_path'];

    return Scaffold(
      appBar: AppBar(title: Text('Agent: $nickname')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Hero(
              tag: 'agent_$agentId',
              child: CircleAvatar(
                radius: 60,
                backgroundImage: imagePath.startsWith('http')
                    ? NetworkImage(imagePath)
                    : AssetImage('assets/images/$imagePath') as ImageProvider,
              ),
            ),
            SizedBox(height: 10),
            Text(nickname,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            Text(fullName,
                style: TextStyle(fontSize: 18, color: Colors.grey[700])),
            SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.phone, size: 16, color: Colors.grey),
                SizedBox(width: 6),
                Text(phone, style: TextStyle(fontSize: 14)),
              ],
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.email, size: 16, color: Colors.grey),
                SizedBox(width: 6),
                Text(email, style: TextStyle(fontSize: 14)),
              ],
            ),
            SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("อสังหาที่ดูแล",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 12),
            _buildAgentRealEstates(agentId),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentRealEstates(int agentId) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('real_estate')
          .where('worker_service', isEqualTo: agentId)
          .where('active', isEqualTo: true)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        var estates = snapshot.data!.docs;

        if (estates.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text("ยังไม่มีอสังหาที่ดูแล"),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: estates.length,
          itemBuilder: (context, index) {
            var estate = estates[index].data() as Map<String, dynamic>;
            int realEstateId = estate['real_estate_id'];
            String name = estate['name'];
            String location = estate['province'] ?? "";
            String price = estate['price'].toString();
            String sellType = estate['type_sell'] ?? "ขายขาด";

            return FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('image_real_estate')
                  .where('real_estate_id', isEqualTo: realEstateId)
                  .where('title_img', isEqualTo: 1)
                  .limit(1)
                  .get(),
              builder: (context, imageSnapshot) {
                String imageUrl =
                    'https://i.ibb.co/7C5jfjq/placeholder.jpg'; // fallback

                if (imageSnapshot.hasData &&
                    imageSnapshot.data!.docs.isNotEmpty) {
                  var imgData = imageSnapshot.data!.docs.first.data()
                      as Map<String, dynamic>;
                  imageUrl = imgData['image_path'];
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: RealEstateCard(
                    realEstateId: realEstateId,
                    imagePath: imageUrl,
                    price: price,
                    name: name,
                    location: location,
                    sellType: sellType,
                    isInitiallyFavorite:
                        false, // คุณอาจปรับตรงนี้ถ้ามีข้อมูล favorite
                    onToggleFavorite: FirebaseService
                        .toggleFavoriteInFirestore, // หรือเพิ่มฟังก์ชัน toggle ถ้ามี
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
