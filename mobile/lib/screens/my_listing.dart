import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../models/real_estate.dart';
import '../models/user.dart';
import '../services/firebase_service.dart';
import '../utils/formatters.dart';
import 'create_listing.dart';
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
          _myListingsFuture =
              _firebaseService.getRealEstateByWorkerService(user.userId);
        }
      });
    }
  }

  void _navigateToCreateListing() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateListingScreen()),
    ).then((_) {
      // Refresh the listings when returning from create screen
      setState(() {
        _loadData();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "My Listing",
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.light 
                ? Colors.black87 
                : Colors.white,
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

          if (userSnapshot.hasError ||
              !userSnapshot.hasData ||
              userSnapshot.data == null) {
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
                          "${listings.length} Estates",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).brightness == Brightness.light 
                                ? Colors.black87 
                                : Colors.white,
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: listings.isEmpty
                          ? Center(
                              child: Text(
                                'No listings yet. Create your first listing!',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).brightness == Brightness.light 
                                      ? Colors.black87 
                                      : Colors.white70,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: listings.length,
                              itemBuilder: (context, index) {
                                final property = listings[index];
                                return PropertyListingCard(
                                  property: property,
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PropertyDetailScreen(
                                                  realEstateId:
                                                      property.realEstateId,
                                                ))).then((_) {
                                      // Refresh when returning from detail screen
                                      setState(() {
                                        _loadData();
                                      });
                                    });
                                  },
                                  onDelete: () {
                                    setState(() {
                                      _loadData();
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

class PropertyListingCard extends StatefulWidget {
  final RealEstate property;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const PropertyListingCard({
    Key? key,
    required this.property,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  _PropertyListingCardState createState() => _PropertyListingCardState();
}

class _PropertyListingCardState extends State<PropertyListingCard> {
  late BuildContext _context;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _context = context;
  }

  void _deleteListing(RealEstate property) async {
    final firebaseService = FirebaseService();

    try {
      // เรียกเมธอดลบรูป + ลบข้อมูลอสังหา
      await firebaseService.deleteRealEstate(property.realEstateId);

      // เรียก callback เพื่อ refresh
      widget.onDelete();

      ScaffoldMessenger.of(_context).showSnackBar(
        const SnackBar(content: Text("ลบรายการสำเร็จ")),
      );
    } catch (e) {
      print('Error deleting listing: $e');
      ScaffoldMessenger.of(_context).showSnackBar(
        const SnackBar(content: Text("เกิดข้อผิดพลาดในการลบ")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Property content
          GestureDetector(
            onTap: widget.onTap,
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
                            widget.property.images.isNotEmpty
                                ? widget.property.images.first
                                : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS_JsEVYJcvZScI2sYdQq7FXB7ZIiSvucI0lA&s',
                            width: 150,
                            height: 150,
                            fit: BoxFit.scaleDown,
                          ),
                          Positioned(
                            bottom: 8,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.home,
                                      color: Colors.white, size: 10),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.property.typeRealestate,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (widget.property.premiumPromote)
                            Positioned(
                              bottom: 8,
                              right: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
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
                          widget.property.details,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.remove_red_eye,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              (widget.property.view).toString(),
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "${widget.property.address} ${widget.property.amphur} ${widget.property.tambon} ${widget.property.province}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "\฿ ${Formatters.formatCurrency(widget.property.price)}",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.yellow : Colors.indigo,
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
                            realEstateId: widget.property.realEstateId,
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
                          content: const Text(
                              "Are you sure you want to delete this listing?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                // Implement delete
                                _deleteListing(widget.property);
                                Navigator.pop(context);
                              },
                              child: const Text("Delete",
                                  style: TextStyle(color: Colors.red)),
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

