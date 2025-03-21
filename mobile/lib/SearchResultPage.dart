import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class SearchResultPage extends StatelessWidget {
  final String? province;
  final String? amphure;
  final String? tambon;
  final String? propertyType;
  final int? bedroom;
  final int? bathroom;
  final double? minPrice;
  final double? maxPrice;

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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ผลลัพธ์การค้นหา"),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ผลลัพธ์ที่ตรงกับการค้นหา",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getSearchResults(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        "ไม่พบอสังหาริมทรัพย์ที่ตรงกับเงื่อนไข",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  var results = snapshot.data!.docs;

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
                      return _buildRealEstateCard(item);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 ดึงข้อมูลจาก Firestore และกรองตามเงื่อนไขการค้นหา
  Stream<QuerySnapshot> _getSearchResults() {
    Query query = FirebaseFirestore.instance.collection('real_estate');

    if (province != null && province!.isNotEmpty) {
      query = query.where('province', isEqualTo: province);
    }
    if (propertyType != null && propertyType!.isNotEmpty) {
      query = query.where('type_realestate', isEqualTo: propertyType);
    }
    if (bedroom != null) {
      query = query.where('bedroom', isGreaterThanOrEqualTo: bedroom);
    }
    if (bathroom != null) {
      query = query.where('bathroom', isGreaterThanOrEqualTo: bathroom);
    }
    if (minPrice != null) {
      query = query.where('price', isGreaterThanOrEqualTo: minPrice);
    }
    if (maxPrice != null) {
      query = query.where('price', isLessThanOrEqualTo: maxPrice);
    }

    return query.snapshots();
  }

  /// 🔹 Widget สำหรับแสดง Card ของอสังหาริมทรัพย์แต่ละรายการ
  /// 🔹 Widget สำหรับแสดง Card ของอสังหาริมทรัพย์แต่ละรายการ
  Widget _buildRealEstateCard(Map<String, dynamic> item) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('image_real_estate')
          .where('real_estate_id', isEqualTo: item["real_estate_id"])
          .limit(1)
          .get(),
      builder: (context, snapshot) {
        String imagePath =
            "https://pub-33d01538ba524615b21478ed0f03e519.r2.dev/placeholder.jpg"; // ✅ ใช้รูป Placeholder จาก Cloudflare R2

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          var imageData =
              snapshot.data!.docs.first.data() as Map<String, dynamic>;

          // ✅ ตรวจสอบค่า image_path ที่ดึงจาก Firestore ว่าถูกต้อง
          if (imageData["image_path"] != null &&
              imageData["image_path"].toString().isNotEmpty) {
            imagePath = imageData["image_path"];
          }

          print("🔥 โหลดรูปจาก: $imagePath"); // ✅ Debug ดูว่าดึง URL อะไรมา
        }

        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ โหลดรูปภาพจาก Cloudflare R2
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: imagePath,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      color: Colors.grey[300],
                    ),
                  ),
                  errorWidget: (context, url, error) {
                    print(
                        "❌ โหลดรูปไม่สำเร็จ: $url"); // ✅ Debug ดูว่า URL ไหนโหลดไม่ได้
                    return Image.network(
                      "https://pub-33d01538ba524615b21478ed0f03e519.r2.dev/placeholder.jpg", // 🔥 ใช้ Placeholder จาก R2
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item["name"] ?? "ไม่ระบุชื่อ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        "${item['province'] ?? ''} | ${item['type_realestate'] ?? ''}",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6),
                      Text(
                        "฿${NumberFormat("#,###").format(item['price'] ?? 0)}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
