import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:real_estate_project/widgets/RealEstateCard.dart';
import 'package:real_estate_project/widgets/mini_map.dart';
import 'package:url_launcher/url_launcher.dart';
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

  const PropertyDetailScreen({Key? key, required this.realEstateId})
      : super(key: key);

  @override
  _PropertyDetailScreenState createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  late Future<RealEstate?> _realEstateFuture;
  late Future<User?> _agentFuture;
  bool isFavorite = false;
  bool _isMapExpanded = false;
  late Future<List<RealEstate>> _recommendedPropertiesFuture;

  @override
  void initState() {
    super.initState();
    _firebaseService.incrementViewCount(widget.realEstateId);
    _loadData();
  }

  late Future<User?> _ownerFuture;

  void _loadData() {
    _realEstateFuture = _firebaseService.getRealEstateById(widget.realEstateId);

    _realEstateFuture.then((realEstate) async {
      if (realEstate != null) {
        _agentFuture = _firebaseService.getUserById(realEstate.workerService);
        _ownerFuture = _firebaseService.getUserById(realEstate.userId);
        _recommendedPropertiesFuture =
            _firebaseService.getRandomRealEstate(limit: 6);

        isFavorite = await _firebaseService.isFavorite(realEstate.realEstateId);

        setState(() {});
      }
    });
  }

  Future<void> _toggleFavorite(int realEstateId) async {
    final result =
        await FirebaseService.toggleFavoriteInFirestore(realEstateId);
    setState(() {
      isFavorite = result;
    });

    final snackBar = SnackBar(
      content: Text(
        isFavorite ? 'เพิ่มเข้ารายการโปรดแล้ว' : 'ลบออกจากรายการโปรดแล้ว',
        style: const TextStyle(fontSize: 16),
      ),
      backgroundColor: isFavorite ? Colors.green : Colors.red,
      duration: const Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// แปลงจาก ตรว. ไปเป็น ไร่/งาน/ตรว.
  String formatLandArea(num squareWa) {
    final rai = squareWa ~/ 400;
    final remainingAfterRai = squareWa % 400;
    final ngan = remainingAfterRai ~/ 100;
    final wa = remainingAfterRai % 100;

    List<String> parts = [];
    if (rai > 0) parts.add('$rai ไร่');
    if (ngan > 0) parts.add('$ngan งาน');
    if (wa > 0) parts.add('$wa ตรว.');

    return parts.join(' ');
  }

  void _contactAgent(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่สามารถโทรออกได้')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                            Container(
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.surface.withOpacity(0.9),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new,
                                    size: 18),
                                // onPressed: () => Navigator.pushReplacementNamed(
                                //     context, '/home'),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface
                                        .withOpacity(0.9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.share, size: 18),
                                    onPressed: () {},
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isFavorite
                                          ? Colors.red
                                          : theme.colorScheme.onPrimary,
                                      size: 18,
                                    ),
                                    onPressed: () =>
                                        _toggleFavorite(property.realEstateId),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.view_in_ar,
                            color: theme.colorScheme.onPrimary),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    property.name,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                  child: Text(
                    '฿ ${Formatters.formatCurrency(property.price)}',
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                // แสดงที่อยู่
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Icon(Icons.location_on,
                          color: theme.iconTheme.color, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.address,
                          style: theme.textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

// 👉 แสดงพื้นที่ (แทรกตรงนี้)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 4.0),
                  child: Row(
                    children: [
                      Icon(Icons.square_foot,
                          color: theme.iconTheme.color, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        formatLandArea(property.area),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),

// แสดงจำนวนผู้ชม
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Icon(Icons.visibility,
                          color: theme.iconTheme.color, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${property.view} คนดูแล้ว',
                          style: theme.textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(property.typeSell),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.dividerColor),
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
                const SizedBox(width: 16),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('พนักงานดูแล',
                      style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold, fontSize: 20)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: FutureBuilder<User?>(
                    future: _agentFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      if (!snapshot.hasData || snapshot.data == null) {
                        return const Text('ไม่พบข้อมูลเอเจนต์');
                      }

                      final agent = snapshot.data!;
                      return Card(
                        color: Theme.of(context).cardColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(agent.imagePath),
                                onBackgroundImageError: (_, __) {},
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(agent.nickName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    Text('${agent.firstName} ${agent.lastName}',
                                        style: const TextStyle(
                                            color: Colors.grey)),
                                    Text(agent.email,
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.call,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                onPressed: () =>
                                    _contactAgent(agent.phoneNumber),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('ประเภทและจำนวนห้อง',
                      style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold, fontSize: 20)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      PropertyFeature(
                        icon: Icons.home,
                        text: property.typeRealestate,
                        color: theme.colorScheme.primary,
                        fontSize: 14,
                        iconSize: 22,
                      ),
                      PropertyFeature(
                        icon: Icons.bed,
                        text: '${property.bedroom} Bedroom',
                        color: Colors.blue.shade600,
                        fontSize: 14,
                        iconSize: 22,
                      ),
                      PropertyFeature(
                        icon: Icons.bathtub,
                        text: '${property.bathroom} Bathroom',
                        color: Colors.red.shade600,
                        fontSize: 14,
                        iconSize: 22,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('รายละเอียด',
                      style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold, fontSize: 20)),
                ),
                // กรอบแสดงรายละเอียด
                Container(
                  width: double.infinity, // ✅ ขยายเต็มจอ
                  margin: EdgeInsets.symmetric(
                      horizontal: 8.0), // หรือ EdgeInsets.zero ถ้าอยากชิดสุด
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    property.details,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('ที่ตั้งอสังหา',
                      style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold, fontSize: 20)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                color: theme.iconTheme.color),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${property.address}\n${property.tambon}, ${property.amphur}, ${property.province}',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.navigation,
                                color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            const Text('แผนที่แบบย่อ'),
                            const Spacer(),
                            IconButton(
                              icon: Icon(
                                _isMapExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: theme.iconTheme.color,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isMapExpanded = !_isMapExpanded;
                                });
                              },
                            ),
                          ],
                        ),
                        AnimatedCrossFade(
                          firstChild: const SizedBox.shrink(),
                          secondChild: GestureDetector(
                            onTap: () async {
                              final url = Uri.parse(
                                  'https://www.google.com/maps/search/?api=1&query=${property.latitude},${property.longitude}');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url,
                                    mode: LaunchMode.externalApplication);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('ไม่สามารถเปิดแผนที่ได้')),
                                );
                              }
                            },
                            child: MiniMap(
                              latitude: property.latitude,
                              longitude: property.longitude,
                            ),
                          ),
                          crossFadeState: _isMapExpanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 300),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('อสังหาที่แนะนำ',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: FutureBuilder<List<RealEstate>>(
                    future: _recommendedPropertiesFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('ยังไม่มีอสังหาฯ แนะนำ'),
                        );
                      }

                      final properties = snapshot.data!
                          .where((p) => p.realEstateId != property.realEstateId)
                          .take(4)
                          .toList();

                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.7,
                        ),
                        padding: EdgeInsets.only(top: 4),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: properties.length,
                        itemBuilder: (context, index) {
                          final p = properties[index];

                          return RealEstateCard(
                            realEstateId: p.realEstateId,
                            imagePath: p.images.isNotEmpty
                                ? p.images.first
                                : 'assets/images/house1.jpg',
                            price: p.price.toString(),
                            name: p.name,
                            location: p.province,
                            sellType: p.typeSell,
                          );
                        },
                      );
                    },
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
