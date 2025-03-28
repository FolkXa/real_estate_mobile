import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:real_estate_project/models/user.dart';
import '../models/real_estate.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get property by ID
  Future<RealEstate?> getRealEstateById(int id) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('real_estate')
          .where('real_estate_id', isEqualTo: id)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data() as Map<String, dynamic>;
        return RealEstate.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Error fetching real estate: $e');
      return null;
    }
  }

  // Get nearby properties
  Future<List<RealEstate>> getNearbyRealEstate(
      String province, int currentId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('real_estate')
          .where('province', isEqualTo: province)
          .where('active', isEqualTo: true)
          .limit(4)
          .get();

      return snapshot.docs
          .map((doc) => RealEstate.fromMap(doc.data() as Map<String, dynamic>))
          .where((property) => property.realEstateId != currentId)
          .toList();
    } catch (e) {
      print('Error fetching nearby properties: $e');
      return [];
    }
  }

  Future<Set<int>> getFavoriteIds() async {
    final userEmail = auth.FirebaseAuth.instance.currentUser?.email;

    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: userEmail)
        .limit(1)
        .get();

    if (userSnapshot.docs.isEmpty) return {};

    final userId = userSnapshot.docs.first['user_id'];

    final favSnapshot = await FirebaseFirestore.instance
        .collection('favorite_real_estate')
        .where('user_id', isEqualTo: userId)
        .get();

    return favSnapshot.docs.map((doc) => doc['real_estate_id'] as int).toSet();
  }

  static Future<bool> toggleFavoriteInFirestore(int realEstateId) async {
    final userEmail = auth.FirebaseAuth.instance.currentUser?.email;

    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: userEmail)
        .limit(1)
        .get();

    if (userSnapshot.docs.isEmpty) return false;
    final userId = userSnapshot.docs.first['user_id'];

    final favoriteRef =
        FirebaseFirestore.instance.collection('favorite_real_estate');

    final existing = await favoriteRef
        .where('user_id', isEqualTo: userId)
        .where('real_estate_id', isEqualTo: realEstateId)
        .get();

    if (existing.docs.isNotEmpty) {
      await favoriteRef.doc(existing.docs.first.id).delete();
      return false;
    } else {
      await favoriteRef.add({
        "user_id": userId,
        "real_estate_id": realEstateId,
        "favorite_id": DateTime.now().millisecondsSinceEpoch,
      });
      return true;
    }
  }

  // Get user by ID
  Future<User?> getUserById(int userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('user_id', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data() as Map<String, dynamic>;
        return User.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  // Get property images
  Stream<QuerySnapshot> getPropertyImages(int realEstateId) {
    return _firestore
        .collection('image_real_estate')
        .where('real_estate_id', isEqualTo: realEstateId)
        .limit(1)
        .snapshots();
  }
}
