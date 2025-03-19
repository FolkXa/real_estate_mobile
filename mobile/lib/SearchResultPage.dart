import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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

                  return ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      var item = results[index].data() as Map<String, dynamic>;

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 3,
                        child: ListTile(
                          leading: Icon(Icons.home, color: Colors.purple),
                          title: Text(
                            item["name"] ?? "ไม่ระบุชื่อ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "${item['province'] ?? ''} | ${item['type'] ?? ''} | ${item['bedroom'] ?? 0} ห้องนอน | ${item['bathroom'] ?? 0} ห้องน้ำ\nราคา: ${NumberFormat("#,###").format(item['price'] ?? 0)} บาท",
                          ),
                        ),
                      );
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
      query = query.where('type', isEqualTo: propertyType);
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
}
