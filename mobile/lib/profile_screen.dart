import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<DocumentSnapshot?> _getUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user.email)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty ? snapshot.docs.first : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot?>(
        future: _getUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("ไม่พบข้อมูลผู้ใช้"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(data["image_path"] ??
                      "https://i.ibb.co/7C5jfjq/placeholder.jpg"),
                ),
                const SizedBox(height: 20),
                Text(
                  "${data['first_name']} ${data['last_name']}",
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text("@${data['username']}",
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 10),
                Chip(
                  label: Text(data["role"] ?? "user"),
                  backgroundColor: Colors.purple[100],
                ),
                const SizedBox(height: 30),
                _buildInfoRow("ชื่อเล่น", data["nick_name"]),
                _buildInfoRow("อีเมล", data["email"]),
                _buildInfoRow("เบอร์โทร", data["phone_number"]),
                _buildInfoRow("สถานะ",
                    data["active"] == true ? "ใช้งานอยู่" : "ไม่ใช้งาน"),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text("$label:", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Expanded(
              child: Text(value ?? "-", style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
