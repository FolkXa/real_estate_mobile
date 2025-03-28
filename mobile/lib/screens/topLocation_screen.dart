import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:real_estate_project/screens/RealEstateCard.dart';
import 'package:real_estate_project/services/firebase_service.dart';

class TopLocationListingScreen extends StatefulWidget {
  final String tagName;
  final String image; // รับ path ของภาพมาด้วย

  const TopLocationListingScreen({
    Key? key,
    required this.tagName,
    required this.image,
  }) : super(key: key);

  @override
  State<TopLocationListingScreen> createState() =>
      _TopLocationListingScreenState();
}

class _TopLocationListingScreenState extends State<TopLocationListingScreen> {
  late Future<List<Map<String, dynamic>>> _taggedRealEstates;

  @override
  void initState() {
    super.initState();
    _taggedRealEstates = _getTaggedRealEstates(widget.tagName);
  }

  Future<List<Map<String, dynamic>>> _getTaggedRealEstates(
      String tagName) async {
    final tagSnapshot = await FirebaseFirestore.instance
        .collection('tags')
        .where('tag_name', isEqualTo: tagName)
        .limit(1)
        .get();

    if (tagSnapshot.docs.isEmpty) return [];

    final tagId = tagSnapshot.docs.first['tag_id'];

    final tagRealEstateSnapshot = await FirebaseFirestore.instance
        .collection('tag_real_estate')
        .where('tag_id', isEqualTo: tagId)
        .get();

    final realEstateIds =
        tagRealEstateSnapshot.docs.map((doc) => doc['real_estate_id']).toList();

    if (realEstateIds.isEmpty) return [];

    final realEstateSnapshot = await FirebaseFirestore.instance
        .collection('real_estate')
        .where('real_estate_id', whereIn: realEstateIds)
        .where('active', isEqualTo: true)
        .get();

    return realEstateSnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
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
      return data['image_path'] ?? "assets/images/placeholder.jpg";
    }

    return "assets/images/placeholder.jpg";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _taggedRealEstates,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    // คำนวณว่า SliverAppBar ยุบตัวแค่ไหน
                    var top = constraints.biggest.height;
                    bool isCollapsed = top <=
                        kToolbarHeight + MediaQuery.of(context).padding.top;

                    return FlexibleSpaceBar(
                      title: Text(
                        widget.tagName,
                        style: TextStyle(
                          color: isCollapsed ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            if (!isCollapsed)
                              Shadow(blurRadius: 2, color: Colors.black),
                          ],
                        ),
                      ),
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            "assets/images/${widget.image}",
                            fit: BoxFit.cover,
                          ),
                          Container(color: Colors.black.withOpacity(0.4)),
                        ],
                      ),
                    );
                  },
                ),
              ),
              if (data.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.location_off, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "ไม่มีอสังหาริมทรัพย์ในพื้นที่ดังกล่าว",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = data[index];
                        return FutureBuilder<String>(
                          future: _getThumbnailImage(item['real_estate_id']),
                          builder: (context, imageSnapshot) {
                            final imagePath = imageSnapshot.data ??
                                "assets/images/placeholder.jpg";
                            return RealEstateCard(
                              realEstateId: item['real_estate_id'],
                              imagePath: imagePath,
                              price: item['price'].toString(),
                              name: item['name'] ?? "ไม่ระบุชื่อ",
                              location: item['province'] ?? "",
                              sellType: item['type_sell'] ?? "ขายขาด",
                              isInitiallyFavorite: false,
                              onToggleFavorite:
                                  FirebaseService.toggleFavoriteInFirestore,
                            );
                          },
                        );
                      },
                      childCount: data.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.75,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
