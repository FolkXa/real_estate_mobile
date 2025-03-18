import 'package:flutter/material.dart';

class SearchResultPage extends StatelessWidget {
  final String? province;
  final String? amphure;
  final String? tambon;
  final String? propertyType;
  final int? bedrooms;
  final int? bathrooms;
  final double? minPrice;
  final double? maxPrice;

  const SearchResultPage({
    Key? key,
    required this.province,
    required this.amphure,
    required this.tambon,
    required this.propertyType,
    required this.bedrooms,
    required this.bathrooms,
    required this.minPrice,
    required this.maxPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> dummyResults = [
      {
        "name": "บ้านเดี่ยว นครนายก",
        "location": "นครนายก",
        "type": "บ้านเดี่ยว",
        "price": 3_000_000,
        "bedrooms": 3,
        "bathrooms": 2
      },
      {
        "name": "คอนโด ปากเกร็ด",
        "location": "ปากเกร็ด",
        "type": "คอนโด",
        "price": 2_500_000,
        "bedrooms": 2,
        "bathrooms": 1
      },
      {
        "name": "ทาวน์เฮ้าส์ บางนา",
        "location": "บางนา",
        "type": "ทาวเฮ้า",
        "price": 3_500_000,
        "bedrooms": 3,
        "bathrooms": 3
      }
    ];

    // กรองผลลัพธ์ตามเงื่อนไขการค้นหา
    List<Map<String, dynamic>> filteredResults = dummyResults.where((item) {
      bool matches = true;

      if (province != null && item['location'] != province) matches = false;
      if (propertyType != null && item['type'] != propertyType) matches = false;
      if (bedrooms != null && item['bedrooms'] < bedrooms!) matches = false;
      if (bathrooms != null && item['bathrooms'] < bathrooms!) matches = false;
      if (minPrice != null && item['price'] < minPrice!) matches = false;
      if (maxPrice != null && item['price'] > maxPrice!) matches = false;

      return matches;
    }).toList();

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
              child: filteredResults.isNotEmpty
                  ? ListView.builder(
                      itemCount: filteredResults.length,
                      itemBuilder: (context, index) {
                        var item = filteredResults[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3,
                          child: ListTile(
                            leading: Icon(Icons.home, color: Colors.purple),
                            title: Text(
                              item["name"],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "${item['location']} | ${item['type']} | ${item['bedrooms']} ห้องนอน | ${item['bathrooms']} ห้องน้ำ\nราคา: ${item['price'].toString()} บาท",
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        "ไม่พบอสังหาริมทรัพย์ที่ตรงกับเงื่อนไข",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
