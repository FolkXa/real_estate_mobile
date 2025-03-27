import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../models/real_estate.dart';
import '../models/user.dart';
import '../services/firebase_service.dart';
import '../utils/formatters.dart';
import 'edit_listing.dart';
import 'property_detail.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({Key? key}) : super(key: key);

  @override
  _MyListingsScreenState createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  late Future<List<RealEstate>> _myListingsFuture;
  late Future<User?> _userFuture;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  void _loadData() {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      _userFuture = _firebaseService.getUserByEmail(currentUser.email!);
      _userFuture.then((user) {
        if (user != null) {
          _myListingsFuture = _firebaseService.getRealEstateByUserId(user.userId);
        }
      });
    }
  }
  
  void _navigateToCreateListing() {
    Navigator.pushNamed(context, '/create-listing').then((_) {
      // Refresh the listings when returning from create screen
      setState(() {
        _loadData();
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "My List Real estate Sell",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<User?>(
        future: _userFuture,
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (userSnapshot.hasError || !userSnapshot.hasData || userSnapshot.data == null) {
            return const Center(child: Text('Unable to load user data'));
          }
          
          final user = userSnapshot.data!;
          
          // Only workers should see this screen
          if (user.role != 'worker') {
            return const Center(
              child: Text('You do not have permission to access this page'),
            );
          }
          
          return FutureBuilder<List<RealEstate>>(
            future: _myListingsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              
              final listings = snapshot.data ?? [];
              
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${listings.length} estates",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _navigateToCreateListing,
                          icon: const Icon(Icons.add),
                          label: const Text("Create new sell"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: listings.isEmpty
                          ? const Center(
                              child: Text(
                                'No listings yet. Create your first listing!',
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : ListView.builder(
                              itemCount: listings.length,
                              itemBuilder: (context, index) {
                                final property = listings[index];
                                return PropertyListingCard(
                                  property: property,
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => PropertyDetailScreen(realEstateId: property.realEstateId,))).then((_) {
                                      // Refresh when returning from detail screen
                                      setState(() {
                                        _loadData();
                                      });
                                    });
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PropertyListingCard extends StatelessWidget {
  final RealEstate property;
  final VoidCallback onTap;

  const PropertyListingCard({
    Key? key,
    required this.property,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Property content
          GestureDetector(
            onTap: onTap,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    child: SizedBox(
                      width: 150,
                      height: 150,
                      child: Stack(
                        children: [
                          Image.network(
                            property.images.isNotEmpty
                                ? property.images.first
                                : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS_JsEVYJcvZScI2sYdQq7FXB7ZIiSvucI0lA&s',
                            width: 150,
                            height: 150,
                            fit: BoxFit.scaleDown,
                          ),
                          Positioned(
                            bottom: 8,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.home, color: Colors.white, size: 10),
                                  const SizedBox(width: 4),
                                  Text(
                                    property.typeRealestate,
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (property.premiumPromote)
                            Positioned(
                              bottom: 8,
                              right: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text(
                                  "Premium",
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Property Details
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.details,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.remove_red_eye, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              (property.view).toString(),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.grey, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "${property.address} ${property.amphur} ${property.tambon} ${property.province}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "\฿ ${Formatters.formatCurrency(property.price)}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Action buttons
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditListingScreen(
                            realEstateId: property.realEstateId,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text("Edit"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Implement delete functionality
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Delete Listing"),
                          content: const Text("Are you sure you want to delete this listing?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                // Implement delete
                                Navigator.pop(context);
                              },
                              child: const Text("Delete", style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text("Delete"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}