import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:real_estate_project/screens/property_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RealEstateCard extends StatefulWidget {
  final int realEstateId;
  final String imagePath;
  final String price;
  final String name;
  final String location;
  final String sellType;

  const RealEstateCard({
    required this.realEstateId,
    required this.imagePath,
    required this.price,
    required this.name,
    required this.location,
    required this.sellType,
    super.key,
  });

  @override
  State<RealEstateCard> createState() => _RealEstateCardState();
}

class _RealEstateCardState extends State<RealEstateCard> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: currentUser.email)
        .limit(1)
        .get();

    if (userSnapshot.docs.isEmpty) return;
    final userId = userSnapshot.docs.first['user_id'];

    final favSnapshot = await FirebaseFirestore.instance
        .collection('favorite_real_estate')
        .where('user_id', isEqualTo: userId)
        .where('real_estate_id', isEqualTo: widget.realEstateId)
        .get();

    if (!mounted) return; // ✅ ป้องกัน error
    setState(() {
      isFavorite = favSnapshot.docs.isNotEmpty;
    });
  }

  Future<void> _toggleFavorite() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: currentUser.email)
        .limit(1)
        .get();

    if (userSnapshot.docs.isEmpty) return;
    final userId = userSnapshot.docs.first['user_id'];

    final favRef =
        FirebaseFirestore.instance.collection('favorite_real_estate');
    final existing = await favRef
        .where('user_id', isEqualTo: userId)
        .where('real_estate_id', isEqualTo: widget.realEstateId)
        .get();

    if (existing.docs.isNotEmpty) {
      await favRef.doc(existing.docs.first.id).delete();
      if (!mounted) return;
      setState(() {
        isFavorite = false;
      });
      _showSnack("ลบออกจากรายการโปรดแล้ว", Colors.red); // 🔴
    } else {
      await favRef.add({
        "user_id": userId,
        "real_estate_id": widget.realEstateId,
        "favorite_id": DateTime.now().millisecondsSinceEpoch,
      });
      if (!mounted) return;
      setState(() {
        isFavorite = true;
      });
      _showSnack("เพิ่มเข้ารายการโปรดแล้ว", Colors.green); // ✅
    }
  }

  void _showSnack(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(message, style: TextStyle(fontSize: 18, color: Colors.white)),
        duration: Duration(seconds: 2),
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedPrice =
        NumberFormat("#,###", "en_US").format(int.tryParse(widget.price) ?? 0);
    final displayPrice =
        "฿$formattedPrice" + (widget.sellType == "เช่า" ? " /เดือน" : "");

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                PropertyDetailScreen(realEstateId: widget.realEstateId),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 5,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        color: theme.cardColor,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 130,
                    width: double.infinity,
                    child: widget.imagePath.startsWith('http')
                        ? Image.network(widget.imagePath, fit: BoxFit.cover)
                        : Image.asset("assets/images/house1.jpg",
                            fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () async {
                        await _toggleFavorite();
                      },
                      child: CircleAvatar(
                        backgroundColor:
                            theme.colorScheme.surface.withOpacity(0.9),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayPrice,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.red, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.location,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
