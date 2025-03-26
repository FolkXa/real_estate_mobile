import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/user.dart';
import '../services/firebase_service.dart';
import '../utils/constants.dart';
import '../utils/permisssion.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({Key? key}) : super(key: key);

  @override
  _CreateListingScreenState createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _amphurController = TextEditingController();
  final TextEditingController _tambonController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _bedroomController = TextEditingController();
  final TextEditingController _bathroomController = TextEditingController();
  
  String _selectedType = 'คอนโด';
  String _selectedSellType = 'ขาย';
  bool _isPremium = false;
  bool _isLoading = false;
  String _errorMessage = '';
  List<File> _selectedImages = [];
  User? _currentUser;
  List<int> _selectedTags = [];
  List<User?> _workers = [];
  int _workerService = 1; // Default value
  
  final List<String> _propertyTypes = ['คอนโด', 'บ้าน', 'ทาวน์เฮาส์', 'ที่ดิน', 'อพาร์ทเมนท์', 'วิลล่า'];
  final List<String> _sellTypes = ['ขาย', 'เช่า'];
  
  // Map to store available tags
  Map<int, String> _availableTags = {};
  
  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadTags();
    _loadWorkerService();
  }
  
  Future<void> _loadCurrentUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final user = await _firebaseService.getUserByEmail(currentUser.email!);
      setState(() {
        _currentUser = user;
      });
    }
  }
  
  Future<void> _loadTags() async {
    try {
      final QuerySnapshot tagsSnapshot = await _firestore
          .collection('tags')
          .get();
      
      Map<int, String> tags = {};
      for (var doc in tagsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final tagId = data['tag_id'] as int;
        final tagName = data['tag_name'] as String;
        tags[tagId] = tagName;
      }
      
      setState(() {
        _availableTags = tags;
      });
    } catch (e) {
      print('Error loading tags: $e');
    }
  }
    Future<void> _loadWorkerService() async {
    try {
      List<User?> workers = await _firebaseService.getAllWorkers();
      setState(() {
        _workers = workers;
      });
    } catch (e) {
      print('Error loading tags: $e');
    }
  }
  
  Future<void> _pickImages() async {
    // Check for storage permission first
    bool hasPermission = await PermissionUtils.requestStoragePermissions(context);
    if (!hasPermission) {
      return;
    }
    
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((image) => File(image.path)).toList());
      });
    }
  }
  // Future<void> _takePhoto() async {
  //   // Check for camera permission first
  //   bool hasPermission = await PermissionUtils.requestCameraPermissions(context);
  //   if (!hasPermission) {
  //     return;
  //   }
    
  //   final ImagePicker picker = ImagePicker();
  //   final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    
  //   if (photo != null) {
  //     setState(() {
  //       _selectedImages.add(File(photo.path));
  //     });
  //   }
  // }
  
  // Helper methods for getting next IDs
  Future<int> _getNextImageId() async {
    final QuerySnapshot snapshot = await _firestore
        .collection('image_real_estate')
        .orderBy('image_id', descending: true)
        .limit(1)
        .get();
    
    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data() as Map<String, dynamic>;
      return (data['image_id'] as int) + 1;
    }
    
    return 1;
  }
  
  Future<int> _getNextTagRealId() async {
    final QuerySnapshot snapshot = await _firestore
        .collection('tags_real_estate')
        .orderBy('tag_real_id', descending: true)
        .limit(1)
        .get();
    
    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data() as Map<String, dynamic>;
      return (data['tag_real_id'] as int) + 1;
    }
    
    return 1;
  }
  
  Future<List<String>> _uploadImages(int realEstateId) async {
    List<String> imageUrls = [];
    int imageIndex = 1;
    
    for (var imageFile in _selectedImages) {
      final String fileName = 'property_${realEstateId}_${DateTime.now().millisecondsSinceEpoch}';
      final Reference storageRef = _storage.ref().child('image_real_estate/$fileName');
      
      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot taskSnapshot = await uploadTask;
      
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      
      // Add image to image_real_estate collection
      await _firestore.collection('image_real_estate').add({
        'image_id': await _getNextImageId(),
        'image_path': downloadUrl,
        'real_estate_id': realEstateId,
        'title_img': imageIndex == 1 ? 1 : 0, // First image is the title image
      });
      
      imageUrls.add(downloadUrl);
      imageIndex++;
    }
    
    return imageUrls;
  }
  
  Future<void> _saveTags(int realEstateId) async {
    int nextTagRealId = await _getNextTagRealId();
    
    for (int tagId in _selectedTags) {
      await _firestore.collection('tags_real_estate').add({
        'real_estate_id': realEstateId,
        'tag_id': tagId,
        'tag_real_id': nextTagRealId++,
      });
    }
  }
  
  Future<void> _createListing() async {
    if (_currentUser == null) {
      setState(() {
        _errorMessage = 'You must be logged in to create a listing';
      });
      return;
    }
    
    if (_nameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _provinceController.text.isEmpty ||
        _amphurController.text.isEmpty ||
        _tambonController.text.isEmpty ||
        _detailsController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _areaController.text.isEmpty ||
        _bedroomController.text.isEmpty ||
        _bathroomController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all required fields';
      });
      return;
    }
    
    if (_selectedImages.isEmpty) {
      setState(() {
        _errorMessage = 'Please select at least one image';
      });
      return;
    }
    
    int price, area, bedroom, bathroom;
    try {
      price = int.parse(_priceController.text.replaceAll(',', ''));
      area = int.parse(_areaController.text.replaceAll(',', ''));
      bedroom = int.parse(_bedroomController.text);
      bathroom = int.parse(_bathroomController.text);
    } catch (e) {
      setState(() {
        _errorMessage = 'Please enter valid numbers for price, area, bedrooms, and bathrooms';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // Get the next real_estate_id
      final QuerySnapshot realEstateSnapshot = await _firestore
          .collection('real_estate')
          .orderBy('real_estate_id', descending: true)
          .limit(1)
          .get();
      
      int nextRealEstateId = 1;
      if (realEstateSnapshot.docs.isNotEmpty) {
        final data = realEstateSnapshot.docs.first.data() as Map<String, dynamic>;
        if (data['real_estate_id'] is int) {
          nextRealEstateId = data['real_estate_id'] + 1;
        } else if (data['real_estate_id'] is String) {
          nextRealEstateId = int.tryParse(data['real_estate_id']) ?? 1;
          nextRealEstateId += 1;
        }
      }
      
      // Create real estate document
      await _firestore.collection('real_estate').add({
        'active': true,
        'address': _addressController.text,
        'amphur': _amphurController.text,
        'area': area,
        'bathroom': bathroom,
        'bedroom': bedroom,
        'details': _detailsController.text,
        'name': _nameController.text,
        'premium_promote': _isPremium,
        'price': price,
        'promote_at': DateTime.now().toIso8601String(),
        'promote_end': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        'province': _provinceController.text,
        'real_estate_id': nextRealEstateId,
        'tambon': _tambonController.text,
        'type_realestate': _selectedType,
        'type_sell': _selectedSellType,
        'user_id': _currentUser!.userId,
        'view': 0,
        'worker_service': _workerService,
      });
      
      // Upload images and create image records
      await _uploadImages(nextRealEstateId);
      
      // Save tags
      await _saveTags(nextRealEstateId);
      
      // Navigate back to listings
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error creating listing: $e';
      });
      print('Error creating listing: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _toggleTag(int tagId) {
    setState(() {
      if (_selectedTags.contains(tagId)) {
        _selectedTags.remove(tagId);
      } else {
        _selectedTags.add(tagId);
      }
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
          "Create New Listing",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _currentUser == null
          ? const Center(child: Text('Loading user data...'))
          : _currentUser!.role != 'worker'
              ? const Center(child: Text('You do not have permission to create listings'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_errorMessage.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red.shade700),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage,
                                  style: TextStyle(color: Colors.red.shade700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      // Property Images
                      const Text(
                        "Property Images",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            // Add image button
                            InkWell(
                              onTap: _pickImages,
                              child: Container(
                                width: 100,
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate, size: 32, color: Colors.grey),
                                    SizedBox(height: 4),
                                    Text("Add Images", style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                            // InkWell(
                            //   onTap: _takePhoto,
                            //   child: Container(
                            //     width: 100,
                            //     margin: const EdgeInsets.all(8),
                            //     decoration: BoxDecoration(
                            //       color: Colors.grey.shade100,
                            //       borderRadius: BorderRadius.circular(8),
                            //       border: Border.all(color: Colors.grey.shade300),
                            //     ),
                            //     child: const Column(
                            //       mainAxisAlignment: MainAxisAlignment.center,
                            //       children: [
                            //         Icon(Icons.camera_alt, size: 32, color: Colors.grey),
                            //         SizedBox(height: 4),
                            //         Text("Camera", style: TextStyle(fontSize: 12)),
                            //       ],
                            //     ),
                            //   ),
                            // ),
                            // Selected images
                            Expanded(
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _selectedImages.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: 100,
                                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: FileImage(_selectedImages[index]),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                _selectedImages.removeAt(index);
                                              });
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (index == 0)
                                          Positioned(
                                            bottom: 0,
                                            left: 0,
                                            right: 0,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 2),
                                              color: Colors.black54,
                                              child: const Text(
                                                "Main Image",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Property Name
                      const Text(
                        "Property Name",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: "e.g. บ้านเดี่ยว 100 ตรว. เขตห้วยขวาง",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Property Type
                      const Text(
                        "Property Type",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedType,
                            isExpanded: true,
                            items: _propertyTypes.map((String type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedType = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Sell Type
                      const Text(
                        "Listing Type",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedSellType,
                            isExpanded: true,
                            items: _sellTypes.map((String type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedSellType = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Property Details (Area, Bedrooms, Bathrooms)
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Area (sq.m)",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _areaController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: "Area",
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Bedrooms",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _bedroomController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: "Bedrooms",
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Bathrooms",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _bathroomController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: "Bathrooms",
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Address
                      const Text(
                        "Address",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          hintText: "Street address",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Location details (Province, Amphur, Tambon)
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Province",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _provinceController,
                                  decoration: InputDecoration(
                                    hintText: "Province",
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "District",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _amphurController,
                                  decoration: InputDecoration(
                                    hintText: "District",
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Tambon (Sub-district)
                      const Text(
                        "Sub-district",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _tambonController,
                        decoration: InputDecoration(
                          hintText: "Sub-district",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Price
                      const Text(
                        "Price",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Price in THB",
                          prefixText: "฿ ",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Tags
                      const Text(
                        "Property Tags",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableTags.entries.map((entry) {
                          final isSelected = _selectedTags.contains(entry.key);
                          return InkWell(
                            onTap: () => _toggleTag(entry.key),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.blue : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                entry.value,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black87,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Details
                      const Text(
                        "Property Description",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _detailsController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: "Describe your property...",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Worker Service Level
                      const Text(
                        "Worker Service",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _workerService,
                            isExpanded: true,
                            items: _workers.map((User? worker) {
                              return DropdownMenuItem<int>(
                                value: worker!.userId,
                                child: Text(worker.email),
                              );
                            }).toList(),
                            onChanged: (int? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _workerService = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Premium Promotion
                      SwitchListTile(
                        title: const Text(
                          "Premium Promotion",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: const Text(
                          "Your listing will be featured and get more visibility",
                          style: TextStyle(fontSize: 12),
                        ),
                        value: _isPremium,
                        activeColor: Colors.amber,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (bool value) {
                          setState(() {
                            _isPremium = value;
                          });
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _createListing,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  "Create Listing",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }
}