import 'package:cloud_firestore/cloud_firestore.dart';
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
  Future<List<RealEstate>> getNearbyRealEstate(String province, int currentId) async {
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

  Future<User?> getUserByUid(String uid) async {
    try {
      final DocumentSnapshot snapshot = await _firestore.collection('users').doc(uid).get();
      if (snapshot.exists) {
        return User.fromMap(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  Future<User?> getUserByEmail(String email) async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('users').where('email', isEqualTo: email).limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        return User.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  Future<List<User?>> getAllWorkers() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('users').where('role', isEqualTo: 'worker').get();
      return snapshot.docs.map((doc) => User.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching user: $e');
      return [];
    }
  }
  // Get real estate listings by user ID
  Future<List<RealEstate>> getRealEstateByUserId(int userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('real_estate')
          .where('user_id', isEqualTo: userId)
          .where('active', isEqualTo: true)
          .get();
      List<RealEstate> realEstates = [];
      for (var doc in snapshot.docs) {
        realEstates.add(RealEstate.fromMap(doc.data() as Map<String, dynamic>));
      }
      for (var realEstate in realEstates) {
        final List<String> images = await getImagesForRealEstate(realEstate.realEstateId);
        realEstate.images.addAll(images);
      }

      return realEstates;
    } catch (e) {
      print('Error fetching real estate by user ID: $e');
      return [];
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

  Future<List<String>> getImagesForRealEstate(int realEstateId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('image_real_estate')
          .where('real_estate_id', isEqualTo: realEstateId)
          .orderBy('image_id', descending: false)
          .get();
      
      if (snapshot.docs.isEmpty) {
        print('No images found for real estate ID: $realEstateId');
        return [];
      }
      
      // Extract image paths from the documents
      List<String> imagePaths = [];
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final String? imagePath = data['image_path'] as String?;
        
        if (imagePath != null && imagePath.isNotEmpty) {
          // Validate the URL format
          if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
            imagePaths.add(imagePath);
          } else {
            print('Invalid image URL format: $imagePath');
          }
        }
      }
      
      print('Found ${imagePaths.length} images for real estate ID: $realEstateId');
      return imagePaths;
    } catch (e) {
      print('Error fetching images for real estate ID $realEstateId: $e');
      return [];
    }
  }
}