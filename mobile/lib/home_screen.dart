import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:real_estate_project/RealEstateCard.dart';
import 'package:real_estate_project/SearchPage.dart';
import 'package:real_estate_project/profile_screen.dart';
import 'package:real_estate_project/screens/property_detail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:real_estate_project/sub_category_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:real_estate_project/services/firebase_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String selectedCategory = "All";
  Set<int> favoriteIds = {};
  final ScrollController _scrollController = ScrollController();

  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    fetchFavorites();
  }

  void fetchFavorites() async {
    final userEmail = FirebaseAuth.instance.currentUser?.email;

    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: userEmail)
        .limit(1)
        .get();

    if (userSnapshot.docs.isEmpty) return;
    final userId = userSnapshot.docs.first['user_id'];

    final favSnapshot = await FirebaseFirestore.instance
        .collection('favorite_real_estate')
        .where('user_id', isEqualTo: userId)
        .get();

    setState(() {
      favoriteIds =
          favSnapshot.docs.map((doc) => doc['real_estate_id'] as int).toSet();
    });
  }

  // Future<bool> toggleFavoriteInFirestore(int realEstateId) async {
  //   final userEmail = currentUser?.email;
  //   final userSnapshot = await FirebaseFirestore.instance
  //       .collection('users')
  //       .where('email', isEqualTo: userEmail)
  //       .limit(1)
  //       .get();

  //   if (userSnapshot.docs.isEmpty) return false;
  //   final userId = userSnapshot.docs.first['user_id'];

  //   final favoriteRef =
  //       FirebaseFirestore.instance.collection('favorite_real_estate');

  //   final existing = await favoriteRef
  //       .where('user_id', isEqualTo: userId)
  //       .where('real_estate_id', isEqualTo: realEstateId)
  //       .get();

  //   if (existing.docs.isNotEmpty) {
  //     await favoriteRef.doc(existing.docs.first.id).delete();
  //     favoriteIds.remove(realEstateId); // อัปเดตใน memory เฉย ๆ
  //     return false; // ❌ ถูกลบ
  //   } else {
  //     await favoriteRef.add({
  //       "user_id": userId,
  //       "real_estate_id": realEstateId,
  //       "favorite_id": DateTime.now().millisecondsSinceEpoch,
  //     });
  //     favoriteIds.add(realEstateId); // ✅ เพิ่ม
  //     return true;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer(onLogout: () {
        FirebaseAuth.instance.signOut();
        Navigator.pushReplacementNamed(context, '/login');
      }),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
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
    );
  }

  /// Header ส่วนบนของแอป
  Widget _buildHeader(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: currentUser?.email ?? '')
          .limit(1)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 50.0, 16.0, 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Hey!",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    Text("Let's start exploring",
                        style: TextStyle(fontSize: 18, color: Colors.grey)),
                  ],
                )
              ],
            ),
          );
        }

        var data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        String name = data['nick_name'] ?? "User";
        String imageUrl =
            data['image_path'] ?? "https://i.ibb.co/7C5jfjq/placeholder.jpg";

        return Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 50.0, 16.0, 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Hey, $name!",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text("Let's start exploring",
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
              // GestureDetector(
              //   onTap: () {
              //     Navigator.push(context,
              //         MaterialPageRoute(builder: (context) => ProfileScreen()));
              //   },
              //   child: CircleAvatar(
              //     radius: 25,
              //     backgroundImage: NetworkImage(imageUrl),
              //   ),
              // ),
            ],
          ),
        );
      },
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
          _buildCategoryItem("All"),
          _buildCategoryItem("บ้านเดี่ยว"),
          _buildCategoryItem("ทาวน์เฮ้าส์"),
          _buildCategoryItem("คอนโด"),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String title) {
    bool isSelected = selectedCategory == title;

    return GestureDetector(
      onTap: () {
        if (title == "All") {
          setState(() {
            selectedCategory = title;
          });
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SubCategoryScreen(category: title),
            ),
          );
        }
      },
      child: Chip(
        label: Text(title),
        backgroundColor: isSelected ? Colors.purple : Colors.grey[300],
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
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
          16.0, 16.0, 16.0, 16.0), // ลดระยะห่างด้านบน/ล่างเป็น 0
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
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'worker')
          .where('active', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("ไม่มีข้อมูลเอเจนต์"));
        }

        var agents = snapshot.data!.docs.take(3).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: agents.map((doc) {
              var data = doc.data() as Map<String, dynamic>;
              String name = data['nick_name'] ?? 'Agent';
              String imagePath = data['image_path'] ??
                  'https://i.ibb.co/7C5jfjq/placeholder.jpg';

              return Expanded(
                child: _buildAgentAvatar(name, imagePath),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildAgentAvatar(String name, String imageUrl) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(imageUrl),
          onBackgroundImageError: (_, __) {},
        ),
        const SizedBox(height: 5),
        Text(
          name,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// Nearby Estates

  Widget _buildNearbyEstates() {
    var query = FirebaseFirestore.instance
        .collection('real_estate')
        .where('active', isEqualTo: true);

    if (selectedCategory != "All") {
      query = query.where('type_realestate', isEqualTo: selectedCategory);
    }
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
              String name = data["name"] ?? "ไม่ระบุชื่อ";
              String location = data["province"] ?? "ไม่ระบุที่ตั้ง";
              String sellType = data["type_sell"] ?? "ขายขาด";

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PropertyDetailScreen(realEstateId: realEstateId),
                    ),
                  );
                },
                child: FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('image_real_estate')
                      .where('real_estate_id', isEqualTo: realEstateId)
                      .where('title_img', isEqualTo: 1)
                      .limit(1)
                      .get(),
                  builder: (context, imageSnapshot) {
                    String imagePath = "assets/images/house1.jpg";

                    if (imageSnapshot.hasData &&
                        imageSnapshot.data!.docs.isNotEmpty) {
                      var imageData = imageSnapshot.data!.docs.first.data()
                          as Map<String, dynamic>;
                      imagePath = imageData["image_path"] ?? imagePath;
                    }

                    return RealEstateCard(
                      realEstateId: realEstateId,
                      imagePath: imagePath,
                      price: price,
                      name: name,
                      location: location,
                      sellType: sellType,
                      isInitiallyFavorite: favoriteIds.contains(realEstateId),
                      onToggleFavorite:
                          FirebaseService.toggleFavoriteInFirestore,
                    );
                  },
                ),
              );
            });
      },
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

class CustomDrawer extends StatelessWidget {
  final VoidCallback onLogout;

  const CustomDrawer({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: currentUser?.email ?? '')
            .limit(1)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          var data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
          String name = data['nick_name'] ?? 'User';
          String imagePath =
              data['image_path'] ?? 'https://i.ibb.co/7C5jfjq/placeholder.jpg';
          String role = data['role'] ?? 'user';

          return Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(name),
                accountEmail: Text(currentUser?.email ?? ''),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage(imagePath),
                ),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Profile'),
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text(role == 'worker' ? 'My List' : 'My Real Estate'),
                onTap: () {
                  Navigator.pushNamed(context, '/my_properties');
                },
              ),
              ListTile(
                leading: Icon(Icons.favorite),
                title: Text('My Favorite'),
                onTap: () {
                  Navigator.pushNamed(context, '/favorite');
                },
              ),
              Spacer(),
              Divider(),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: onLogout,
              ),
            ],
          );
        },
      ),
    );
  }
}
