import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:real_estate_project/SearchPage.dart';
import 'package:real_estate_project/screens/property_detail.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchBar(context),
            _buildCategorySelector(),
            _buildPromotionBanner(),
            _buildSectionTitle("Featured Estates"),
            _buildFeaturedEstates(),
            _buildSectionTitle("Top Locations"),
            _buildTopLocations(),
            _buildSectionTitle("Estate Agent"),
            _buildEstateAgents(),
            _buildSectionTitle("Explore Nearby Estates"),
            _buildNearbyEstates(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  /// Header ส่วนบนของแอป
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 100.0, 16.0, 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hey, TOTO!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text("Let's start exploring",
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
            ],
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage("assets/images/profile.jpg"),
                fit: BoxFit.fill,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SearchPage()),
          );
        },
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 5,
                offset: Offset(0, 2),
              )
            ],
          ),
          child: Row(
            children: [
              SizedBox(width: 16),
              Icon(Icons.search, color: Colors.grey),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Search House, Apartment, etc",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
              Icon(Icons.mic, color: Colors.grey),
              SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Category Selector
  Widget _buildCategorySelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCategoryItem("All", isSelected: true),
          _buildCategoryItem("House"),
          _buildCategoryItem("Apartment"),
          _buildCategoryItem("Condo"),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String title, {bool isSelected = false}) {
    return Chip(
      label: Text(title),
      backgroundColor: isSelected ? Colors.purple : Colors.grey[300],
      labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold),
    );
  }

  /// Promotion Banner
  Widget _buildPromotionBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Stack(
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              image: DecorationImage(
                image: AssetImage("assets/images/banner.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Text(
              "Hot Sale!\nAll discount up to 60%",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }

  /// Section Title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          16.0, 0.0, 16.0, 0.0), // ลดระยะห่างด้านบน/ล่างเป็น 0
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// Featured Estates
  Widget _buildFeaturedEstates() {
    return Container(
      height: 150,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFeaturedCard("Sky Dandelions Apartment", "\$200,000"),
          _buildFeaturedCard("Luxury Condo", "\$350,000"),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(String title, String price) {
    return Container(
      width: 200,
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        image: DecorationImage(
          image: AssetImage("assets/images/house1.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "$title\n$price",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildTopLocations() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLocationItem("SaveOneMarket.jpg", "ตลาดเซฟวัน"),
        _buildLocationItem("department_store.jpg", "ห้างสรรพสินค้า"),
        _buildLocationItem("BTS_Skytrain.jpg", "รถไฟฟ้า BTS"),
      ],
    );
  }

  Widget _buildLocationItem(String image, String title) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage("assets/images/$image"),
        ),
        SizedBox(height: 5), // เพิ่มระยะห่างระหว่างรูปกับข้อความ
        Text(
          title,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildEstateAgents() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("ไม่มีข้อมูลเอเจนต์"));
        }

        var users = snapshot.data!.docs.take(3).toList(); // แสดง 3 คนแรก

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: users.map((doc) {
              var data = doc.data() as Map<String, dynamic>;
              String nickName = data["nick_name"] ?? "No Name";
              String imagePath =
                  data["image_path"] ?? "assets/images/default_avatar.png";

              return _buildAgentItem(imagePath, nickName);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildAgentItem(String imagePath, String nickName) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage(imagePath) as ImageProvider,
          onBackgroundImageError: (_, __) =>
              AssetImage("assets/images/default_avatar.png"),
        ),
        SizedBox(height: 5), // ระยะห่างระหว่างรูปกับชื่อ
        Text(
          nickName,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// Nearby Estates

  Widget _buildNearbyEstates() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('real_estate')
          .where('active', isEqualTo: true)
          .limit(6)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          print("❌ ไม่มีข้อมูลอสังหาริมทรัพย์ใน Firestore");
          return Center(child: Text("ไม่มีข้อมูลอสังหาริมทรัพย์"));
        }

        var estates = snapshot.data!.docs;

        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: estates.length,
          itemBuilder: (context, index) {
            var data = estates[index].data() as Map<String, dynamic>;

            int realEstateId = data["real_estate_id"];
            String price = data["price"].toString();
            int viewCount = data["view"] ?? 0;
            String location = data["province"] ?? "ไม่ระบุที่ตั้ง";

            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => PropertyDetailScreen(
                    realEstateId: realEstateId,
                  ),
                ));
              },
              child: FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('image_real_estate')
                    .where('real_estate_id', isEqualTo: realEstateId)
                    .limit(1)
                    .get(),
                builder: (context, imageSnapshot) {
                  if (imageSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  String imagePath = "assets/images/house1.jpg";

                  if (imageSnapshot.hasData &&
                      imageSnapshot.data!.docs.isNotEmpty) {
                    var imageData = imageSnapshot.data!.docs.first.data()
                        as Map<String, dynamic>;
                    imagePath =
                        imageData["image_path"] ?? "assets/images/house1.jpg";
                  }

                  return _buildNearbyCard(
                    imagePath,
                    price,
                    viewCount,
                    location,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNearbyCard(
      String imagePath, String price, int viewCount, String location) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 5, // เพิ่มเงาให้ดูมีมิติ
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // รูปภาพ
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              height: 120,
              width: double.infinity,
            ),
          ),
          // รายละเอียดอสังหาริมทรัพย์
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ราคา
                Text("฿$price",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green)),
                SizedBox(height: 4),
                // จังหวัด
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.red),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(location,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                // จำนวนวิว
                Row(
                  children: [
                    Icon(Icons.visibility, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text("$viewCount views",
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom Navigation Bar
  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: ""),
      ],
    );
  }
}
