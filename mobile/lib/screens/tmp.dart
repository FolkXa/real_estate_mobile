import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/real_estate.dart';
import '../models/user.dart';
import '../services/firebase_service.dart';
import '../utils/constants.dart';
import '../utils/image_viewer.dart';

class EditListingScreen extends StatefulWidget {
  final int realEstateId;

  const EditListingScreen({Key? key, required this.realEstateId})
      : super(key: key);

  @override
  _EditListingScreenState createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
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
  String _selectedSellType = 'ขายขาด';
  bool _isPremium = false;
  bool _isLoading = false;
  bool _isInitialLoading = true;
  String _errorMessage = '';
  List<String> _existingImages = [];
  List<File> _newImages = [];
  List<String> _imagesToDelete = [];
  User? _currentUser;
  List<int> _selectedTags = [];
  List<User?> _workers = [];
  int _workerService = 1;
  String _docId = '';

  final List<String> _estateTypes = [
    'คอนโด',
    'บ้าน',
    'ทาวน์เฮ้าส์',
    'ที่ดิน',
    'อพาร์ทเมนท์',
    'วิลล่า'
  ];
  final List<String> _sellTypes = ['ขายขาด', 'เช่า'];

  // Map to store available tags
  Map<int, String> _availableTags = {};
  Map<int, bool> _propertyTags = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load current user
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final user = await _firebaseService.getUserByEmail(currentUser.email!);
        setState(() {
          _currentUser = user;
        });
      }

      // Load property data
      final property =
          await _firebaseService.getRealEstateById(widget.realEstateId);
      if (property == null) {
        setState(() {
          _errorMessage = 'Property not found';
          _isInitialLoading = false;
        });
        return;
      }

      // Get document ID for the property
      final QuerySnapshot snapshot = await _firestore
          .collection('real_estate')
          .where('real_estate_id', isEqualTo: widget.realEstateId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        _docId = snapshot.docs.first.id;
      }

      // Load images
      _existingImages =
          await _firebaseService.getImagesForRealEstate(widget.realEstateId);

      // Load tags
      await _loadTags();
      await _loadPropertyTags();

      // Load workers
      await _loadWorkerService();

      // Populate form fields
      _nameController.text = property.name;
      _addressController.text = property.address;
      _provinceController.text = property.province;
      _amphurController.text = property.amphur;
      _tambonController.text = property.tambon;
      _detailsController.text = property.details;
      _priceController.text = property.price.toString();
      _areaController.text = property.area.toString();
      _bedroomController.text = property.bedroom.toString();
      _bathroomController.text = property.bathroom.toString();

      setState(() {
        _selectedType = property.typeRealestate;
        _selectedSellType = property.typeSell;
        _isPremium = property.premiumPromote;
        _workerService = property.workerService;
        _isInitialLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading property data: $e';
        _isInitialLoading = false;
      });
      print('Error loading property data: $e');
    }
  }

  Future<void> _loadTags() async {
    try {
      final QuerySnapshot tagsSnapshot =
          await _firestore.collection('tags').get();

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

  Future<void> _loadPropertyTags() async {
    try {
      final QuerySnapshot tagsSnapshot = await _firestore
          .collection('tags_real_estate')
          .where('real_estate_id', isEqualTo: widget.realEstateId)
          .get();

      List<int> selectedTags = [];
      for (var doc in tagsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final tagId = data['tag_id'] as int;
        selectedTags.add(tagId);
      }

      setState(() {
        _selectedTags = selectedTags;
      });
    } catch (e) {
      print('Error loading property tags: $e');
    }
  }

  Future<void> _loadWorkerService() async {
    try {
      List<User?> workers = await _firebaseService.getAllWorkers();
      setState(() {
        _workers = workers;
      });
    } catch (e) {
      print('Error loading workers: $e');
    }
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        _newImages.addAll(images.map((image) => File(image.path)).toList());
      });
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      String imageToRemove = _existingImages[index];
      _imagesToDelete.add(imageToRemove);
      _existingImages.removeAt(index);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  Future<void> _deleteImages() async {
    for (String imageUrl in _imagesToDelete) {
      try {
        // Find the document with this image URL
        final QuerySnapshot snapshot = await _firestore
            .collection('image_real_estate')
            .where('image_path', isEqualTo: imageUrl)
            .where('real_estate_id', isEqualTo: widget.realEstateId)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          await _firestore
              .collection('image_real_estate')
              .doc(snapshot.docs.first.id)
              .delete();

          // Try to delete from storage if possible
          try {
            final ref = FirebaseStorage.instance.refFromURL(imageUrl);
            await ref.delete();
          } catch (e) {
            print('Could not delete image from storage: $e');
          }
        }
      } catch (e) {
        print('Error deleting image: $e');
      }
    }
  }

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

  Future<List<String>> _uploadNewImages() async {
    List<String> imageUrls = [];
    int imageIndex = _existingImages.length + 1;

    for (var imageFile in _newImages) {
      final String fileName =
          'estate_${widget.realEstateId}_${DateTime.now().millisecondsSinceEpoch}';
      final Reference storageRef =
          _storage.ref().child('image_real_estate/$fileName');

      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot taskSnapshot = await uploadTask;

      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      // Add image to image_real_estate collection
      await _firestore.collection('image_real_estate').add({
        'image_id': await _getNextImageId(),
        'image_path': downloadUrl,
        'real_estate_id': widget.realEstateId,
        'title_img': imageIndex == 1 && _existingImages.isEmpty ? 1 : 0,
      });

      imageUrls.add(downloadUrl);
      imageIndex++;
    }

    return imageUrls;
  }

  Future<void> _updateTags() async {
    try {
      // First, delete all existing tags for this property
      final QuerySnapshot tagsSnapshot = await _firestore
          .collection('tags_real_estate')
          .where('real_estate_id', isEqualTo: widget.realEstateId)
          .get();

      for (var doc in tagsSnapshot.docs) {
        await _firestore.collection('tags_real_estate').doc(doc.id).delete();
      }

      // Then add the selected tags
      int nextTagRealId = 1;
      final QuerySnapshot lastTagSnapshot = await _firestore
          .collection('tags_real_estate')
          .orderBy('tag_real_id', descending: true)
          .limit(1)
          .get();

      if (lastTagSnapshot.docs.isNotEmpty) {
        final data = lastTagSnapshot.docs.first.data() as Map<String, dynamic>;
        nextTagRealId = (data['tag_real_id'] as int) + 1;
      }

      for (int tagId in _selectedTags) {
        await _firestore.collection('tags_real_estate').add({
          'real_estate_id': widget.realEstateId,
          'tag_id': tagId,
          'tag_real_id': nextTagRealId++,
        });
      }
    } catch (e) {
      print('Error updating tags: $e');
      throw e;
    }
  }

  Future<void> _updateListing() async {
    if (_currentUser == null) {
      setState(() {
        _errorMessage = 'You must be logged in to update a listing';
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

    if (_existingImages.isEmpty && _newImages.isEmpty) {
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
        _errorMessage =
            'Please enter valid numbers for price, area, bedrooms, and bathrooms';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Update real estate document
      if (_docId.isNotEmpty) {
        await _firestore.collection('real_estate').doc(_docId).update({
          'address': _addressController.text,
          'amphur': _amphurController.text,
          'area': area,
          'bathroom': bathroom,
          'bedroom': bedroom,
          'details': _detailsController.text,
          'name': _nameController.text,
          'premium_promote': _isPremium,
          'price': price,
          'province': _provinceController.text,
          'tambon': _tambonController.text,
          'type_realestate': _selectedType,
          'type_sell': _selectedSellType,
          'worker_service': _workerService,
        });
      } else {
        setState(() {
          _errorMessage = 'Error: Could not find the property document';
          _isLoading = false;
        });
        return;
      }

      // Delete removed images
      await _deleteImages();

      // Upload new images
      await _uploadNewImages();

      // Update tags
      await _updateTags();

      // Navigate back to listings
      Navigator.pushNamedAndRemoveUntil(context, '/my-listings', (_) => false);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error updating listing: $e';
      });
      print('Error updating listing: $e');
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

  void _viewFullImage(List<String> images, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageViewer(
          images: images,
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Edit Listing",
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
      body: _isInitialLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentUser == null
              ? const Center(child: Text('Loading user data...'))
              : _currentUser!.role != 'worker'
                  ? const Center(
                      child:
                          Text('You do not have permission to edit listings'))
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
                                  Icon(Icons.error_outline,
                                      color: Colors.red.shade700),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage,
                                      style:
                                          TextStyle(color: Colors.red.shade700),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Estate Images
                          const Text(
                            "Estate Images",
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
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                    ),
                                    child: const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_photo_alternate,
                                            size: 32, color: Colors.grey),
                                        SizedBox(height: 4),
                                        Text("Add Images",
                                            style: TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ),

                                // Existing images
                                Expanded(
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _existingImages.length +
                                        _newImages.length,
                                    itemBuilder: (context, index) {
                                      if (index < _existingImages.length) {
                                        // Existing image
                                        return GestureDetector(
                                          onTap: () => _viewFullImage(
                                              _existingImages, index),
                                          child: Container(
                                            width: 100,
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 4),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                    _existingImages[index]),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            child: Stack(
                                              children: [
                                                Positioned(
                                                  top: 0,
                                                  right: 0,
                                                  child: InkWell(
                                                    onTap: () =>
                                                        _removeExistingImage(
                                                            index),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4),
                                                      decoration:
                                                          const BoxDecoration(
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
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 2),
                                                      color: Colors.black54,
                                                      child: const Text(
                                                        "Main Image",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        );
                                      } else {
                                        // New image
                                        final newIndex =
                                            index - _existingImages.length;
                                        return Container(
                                          width: 100,
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 4),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            image: DecorationImage(
                                              image: FileImage(
                                                  _newImages[newIndex]),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                top: 0,
                                                right: 0,
                                                child: InkWell(
                                                  onTap: () =>
                                                      _removeNewImage(newIndex),
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    decoration:
                                                        const BoxDecoration(
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
                                              if (_existingImages.isEmpty &&
                                                  newIndex == 0)
                                                Positioned(
                                                  bottom: 0,
                                                  left: 0,
                                                  right: 0,
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 2),
                                                    color: Colors.black54,
                                                    child: const Text(
                                                      "Main Image",
                                                      textAlign:
                                                          TextAlign.center,
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
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Estate Name
                          const Text(
                            "Estate Name",
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
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Estate Type
                          const Text(
                            "Estate Type",
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
                                items: _estateTypes.map((String type) {
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

                          // Estate Details (Area, Bedrooms, Bathrooms)
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Area (sq.wa)",
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
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
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
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
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
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
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
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
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
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
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
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
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
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
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
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Tags
                          const Text(
                            "Estate Tags",
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
                              final isSelected =
                                  _selectedTags.contains(entry.key);
                              return InkWell(
                                onTap: () => _toggleTag(entry.key),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.blue
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    entry.value,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black87,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 16),

                          // Details
                          const Text(
                            "Estate Description",
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
                              hintText: "Describe your estate...",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
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
                              onPressed: _isLoading ? null : _updateListing,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text(
                                      "Update Listing",
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
