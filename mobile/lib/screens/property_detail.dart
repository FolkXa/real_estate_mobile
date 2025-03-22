import 'package:flutter/material.dart';
import '../models/real_estate.dart';
import '../models/user.dart';
import '../services/firebase_service.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/property_feature.dart';
import '../widgets/property_image.dart';
import '../widgets/nearby_property_card.dart';
import '../widgets/location_map.dart';
import '../widgets/agent_info_card.dart';

class PropertyDetailScreen extends StatefulWidget {
  final int realEstateId;

  const PropertyDetailScreen({Key? key, required this.realEstateId}) : super(key: key);

  @override
  _PropertyDetailScreenState createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  late Future<RealEstate?> _realEstateFuture;
  late Future<User?> _agentFuture;
  late Future<List<RealEstate>> _nearbyPropertiesFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _realEstateFuture = _firebaseService.getRealEstateById(widget.realEstateId);
    
    _realEstateFuture.then((realEstate) {
      if (realEstate != null) {
        _agentFuture = _firebaseService.getUserById(realEstate.userId);
        _nearbyPropertiesFuture = _firebaseService.getNearbyRealEstate(
          realEstate.province, 
          realEstate.realEstateId
        );
      }
    });
  }

  void _contactAgent() {
    // Implement contact functionality
    print('Contact agent button pressed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<RealEstate?>(
        future: _realEstateFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Property not found'));
          }
          
          final property = snapshot.data!;
          
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Property Image with Action Buttons
                Stack(
                  children: [
                    PropertyImage(
                      realEstateId: property.realEstateId,
                      height: 300,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Back Button
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                            Row(
                              children: [
                                // Share Button
                                Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.share, size: 18),
                                    onPressed: () {},
                                  ),
                                ),
                                // Favorite Button
                                Container(
                                  decoration: const BoxDecoration(
                                    color: AppColors.accent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.favorite, color: Colors.white, size: 18),
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Property Type Badge
                    Positioned(
                      bottom: 8,
                      left: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          property.typeRealestate,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    // 360 View Button
                    Positioned(
                      bottom: 8,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.view_in_ar,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Property Title and Price
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'home${property.realEstateId}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$ ${Formatters.formatCurrency(property.price)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Address
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.address,
                          style: const TextStyle(color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // View Count
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.visibility, color: Colors.grey, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${property.view} คนดูแล้ว',
                          style: const TextStyle(color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Contract Sale Button and 360 View
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            property.typeSell,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.view_in_ar, size: 16),
                            SizedBox(width: 4),
                            Text('360°'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Agent Info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: FutureBuilder<User?>(
                    future: _agentFuture,
                    builder: (context, snapshot) {
                      return AgentInfoCard(
                        agent: snapshot.data,
                        onContactPressed: _contactAgent,
                      );
                    },
                  ),
                ),
                
                // Rooms Section
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Rooms',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                // Room Features
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PropertyFeature(
                        icon: Icons.home,
                        text: property.typeRealestate,
                        color: AppColors.primary,
                      ),
                      PropertyFeature(
                        icon: Icons.bed,
                        text: '2 Bedroom',  // This would come from property data
                        color: Colors.blue,
                      ),
                      PropertyFeature(
                        icon: Icons.bathtub,
                        text: '1 Bathroom',  // This would come from property data
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
                
                // Location & Public Facilities
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Location & Public Facilities',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                // Location Details
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        // Full Address
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${property.address}\n${property.tambon}, ${property.amphur}, ${property.province}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Distance from target
                        Row(
                          children: [
                            const Icon(Icons.navigation, color: Colors.blue),
                            const SizedBox(width: 8),
                            const Text(
                              '2.5 km from target location',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const Spacer(),
                            Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade400),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Map
                        LocationMap(
                          latitude: 13.7, // These would come from property data
                          longitude: 100.5,
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Nearby Properties
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Nearby From this Location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                // Nearby Properties Grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: FutureBuilder<List<RealEstate>>(
                    future: _nearbyPropertiesFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No nearby properties found'),
                          ),
                        );
                      }
                      
                      final nearbyProperties = snapshot.data!;
                      
                      return GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: nearbyProperties.length,
                        itemBuilder: (context, index) {
                          final property = nearbyProperties[index];
                          return NearbyPropertyCard(
                            property: property,
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PropertyDetailScreen(
                                    realEstateId: property.realEstateId,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}