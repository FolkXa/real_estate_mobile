import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:real_estate_project/models/thailand_division.dart';
import 'dart:io';
import '../models/area.dart';
import '../models/user.dart';
import '../services/firebase_service.dart';

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
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  // Area controllers
  final TextEditingController _raiController = TextEditingController();
  final TextEditingController _nganController = TextEditingController();
  final TextEditingController _waController = TextEditingController();

  final TextEditingController _bedroomController = TextEditingController();
  final TextEditingController _bathroomController = TextEditingController();
  final TextEditingController _searchUserController = TextEditingController();

  String _selectedType = 'คอนโด';
  String _selectedSellType = 'ขายขาด';
  bool _isPremium = false;
  bool _isLoading = false;
  bool _isInitialLoading = true;
  bool _isSearchingUser = false;
  String _errorMessage = '';
  List<File> _images = [];
  User? _currentUser;
  List<int> _selectedTags = [];
  List<User?> _workers = [];
  List<User?> _searchResults = [];
  int _workerService = 1;
  int _ownerId = 0;
  ThailandDivision? _thailandDivision;

  // Location search
  bool _isSearchingProvince = false;
  bool _isSearchingAmphur = false;
  bool _isSearchingTambon = false;
  List<Map<String, dynamic>> _provinceResults = [];
  List<Map<String, dynamic>> _amphurResults = [];
  List<Map<String, dynamic>> _tambonResults = [];
  Map<String, dynamic>? _selectedProvince;
  Map<String, dynamic>? _selectedAmphur;
  Map<String, dynamic>? _selectedTambon;

  final List<String> _estateTypes = [
    'คอนโด',
    'บ้านเดี่ยว',
    'ทาวน์เฮ้าส์',
    'ที่ดิน',
    'อพาร์ทเมนท์',
    'วิลล่า'
  ];
  final List<String> _sellTypes = ['ขายขาด', 'เช่า'];

  // Map to store available tags
  Map<int, String> _availableTags = {};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      // Load current user
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final user = await _firebaseService.getUserByEmail(currentUser.email!);
        setState(() {
          _currentUser = user;

          // Set current user as owner by default
          if (user != null) {
            _ownerId = user.userId;
            _searchUserController.text = user.email;
          }
        });
      }

      // Load Thailand division data
      await _loadThailandDivision();

      // Load tags
      await _loadTags();

      // Load workers
      await _loadWorkerService();

      // Set default values
      _bedroomController.text = "0";
      _bathroomController.text = "0";
      _raiController.text = "0";
      _nganController.text = "0";
      _waController.text = "0";

      setState(() {
        _isInitialLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาดในการโหลดข้อมูล: $e';
        _isInitialLoading = false;
      });
      print('Error loading initial data: $e');
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

  Future<void> _loadThailandDivision() async {
    try {
      final divisions = ThailandDivision();
      await divisions.loadJsonData();
      setState(() {
        _thailandDivision = divisions;
      });
    } catch (e) {
      print('Error loading Thailand division: $e');
    }
  }

  Future<void> _loadWorkerService() async {
    try {
      List<User?> workers = await _firebaseService.getAllWorkers();
      setState(() {
        _workers = workers;

        // Set current user as worker service if they are a worker
        if (_currentUser != null && _currentUser!.role == 'worker') {
          _workerService = _currentUser!.userId;
        } else if (workers.isNotEmpty) {
          _workerService = workers.first!.userId;
        }
      });
    } catch (e) {
      print('Error loading workers: $e');
    }
  }

  // Search functions for location
  void _searchProvinces(String query) {
    if (_thailandDivision == null) return;

    setState(() {
      _isSearchingProvince = true;
    });

    try {
      final results = _thailandDivision!.searchProvince(query);
      setState(() {
        _provinceResults = results;
        _isSearchingProvince = false;
      });
    } catch (e) {
      print('Error searching provinces: $e');
      setState(() {
        _isSearchingProvince = false;
      });
    }
  }

  void _searchAmphures(String query) {
    if (_thailandDivision == null || _selectedProvince == null) return;

    setState(() {
      _isSearchingAmphur = true;
    });

    try {
      final results = _thailandDivision!
          .searchAmphure(query)
          .where((amphur) => amphur['province_id'] == _selectedProvince!['id'])
          .toList();

      setState(() {
        _amphurResults = results;
        _isSearchingAmphur = false;
      });
    } catch (e) {
      print('Error searching amphures: $e');
      setState(() {
        _isSearchingAmphur = false;
      });
    }
  }

  void _searchTambons(String query) {
    if (_thailandDivision == null || _selectedAmphur == null) return;

    setState(() {
      _isSearchingTambon = true;
    });

    try {
      final results = _thailandDivision!
          .searchTambon(query)
          .where((tambon) => tambon['amphure_id'] == _selectedAmphur!['id'])
          .toList();

      setState(() {
        _tambonResults = results;
        _isSearchingTambon = false;
      });
    } catch (e) {
      print('Error searching tambons: $e');
      setState(() {
        _isSearchingTambon = false;
      });
    }
  }

  void _selectProvince(Map<String, dynamic> province) {
    setState(() {
      _selectedProvince = province;
      _provinceController.text = province['name_th'];
      _provinceResults = [];

      // Reset amphur and tambon when province changes
      _selectedAmphur = null;
      _selectedTambon = null;
      _amphurController.text = '';
      _tambonController.text = '';
    });
  }

  void _selectAmphur(Map<String, dynamic> amphur) {
    setState(() {
      _selectedAmphur = amphur;
      _amphurController.text = amphur['name_th'];
      _amphurResults = [];

      // Reset tambon when amphur changes
      _selectedTambon = null;
      _tambonController.text = '';
    });
  }

  void _selectTambon(Map<String, dynamic> tambon) {
    setState(() {
      _selectedTambon = tambon;
      _tambonController.text = tambon['name_th'];
      _tambonResults = [];
    });
  }

  Future<void> _searchUsersByEmail(String email) async {
    if (email.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearchingUser = false;
      });
      return;
    }

    setState(() {
      _isSearchingUser = true;
    });

    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('email', isGreaterThanOrEqualTo: email)
          .where('email', isLessThanOrEqualTo: email + '\uf8ff')
          .limit(5)
          .get();

      List<User?> users = [];
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        users.add(User.fromMap(data));
      }

      setState(() {
        _searchResults = users;
        _isSearchingUser = false;
      });
    } catch (e) {
      print('Error searching users: $e');
      setState(() {
        _isSearchingUser = false;
      });
    }
  }

  void _selectUser(User user) {
    setState(() {
      _ownerId = user.userId;
      _searchUserController.text = user.email;
      _searchResults = [];
    });
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> pickedImages = await picker.pickMultiImage();

    if (pickedImages.isNotEmpty) {
      List<File> finalImages = [];

      for (var xfile in pickedImages) {
        File originalFile = File(xfile.path);
        int fileSizeInBytes = await originalFile.length();
        double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

        if (fileSizeInMB > 10) {
          // ถ้าใหญ่กว่า 10MB → บีบอัด
          File compressed = await compressImage(originalFile);
          finalImages.add(compressed);
        } else {
          // ถ้าไม่เกิน → ใช้ไฟล์เดิม
          finalImages.add(originalFile);
        }
      }

      setState(() {
        _images.addAll(finalImages);
      });
    }
  }

  Future<File> compressImage(File file) async {
    final originalBytes = await file.readAsBytes();
    final decodedImage = img.decodeImage(originalBytes);

    final resized = img.copyResize(decodedImage!, width: 800); // ลดความกว้าง
    final compressedBytes = img.encodeJpg(resized, quality: 85); // บีบอัด

    final tempDir = Directory.systemTemp;
    final compressedFile = File('${tempDir.path}/${path.basename(file.path)}');
    await compressedFile.writeAsBytes(compressedBytes);

    return compressedFile;
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  // Calculate total area in square wa
  double _calculateTotalAreaInSquareWa() {
    try {
      double rai =
          double.tryParse(_raiController.text.replaceAll(',', '')) ?? 0;
      double ngan =
          double.tryParse(_nganController.text.replaceAll(',', '')) ?? 0;
      double wa = double.tryParse(_waController.text.replaceAll(',', '')) ?? 0;

      // Convert all to square wa
      return (rai * 400) + (ngan * 100) + wa;
    } catch (e) {
      print('Error calculating area: $e');
      return 0;
    }
  }

  Future<int> _getNextRealEstateId() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('real_estate')
          .orderBy('real_estate_id', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data() as Map<String, dynamic>;
        return (data['real_estate_id'] as int) + 1;
      }

      return 1; // Default if no real estate exists yet
    } catch (e) {
      print('Error getting next real estate ID: $e');
      throw e;
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

  Future<List<String>> _uploadImages(int realEstateId) async {
    List<String> imageUrls = [];

    for (var i = 0; i < _images.length; i++) {
      final imageFile = _images[i];
      final String fileName =
          '$realEstateId-${DateTime.now().millisecondsSinceEpoch}-$i.jpg';

      final Reference storageRef =
          _storage.ref().child('image_real_estate/$fileName');

      // ✅ จำกัดขนาด metadata, ไม่แนบข้อมูลแปลกๆ
      final UploadTask uploadTask = storageRef.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final TaskSnapshot taskSnapshot = await uploadTask;
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      await _firestore.collection('image_real_estate').add({
        'image_id': await _getNextImageId(),
        'image_path': downloadUrl,
        'real_estate_id': realEstateId,
        'title_img': i == 0 ? 1 : 0,
      });

      imageUrls.add(downloadUrl);
    }

    return imageUrls;
  }

  Future<void> _saveTags(int realEstateId) async {
    try {
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
          'real_estate_id': realEstateId,
          'tag_id': tagId,
          'tag_real_id': nextTagRealId++,
        });
      }
    } catch (e) {
      print('Error saving tags: $e');
      throw e;
    }
  }

  bool _validateAreaFields() {
    // Validate rai (max 4 characters)
    if (_raiController.text.isNotEmpty && _raiController.text.length > 4) {
      setState(() {
        _errorMessage = 'จำนวนไร่ต้องไม่เกิน 4 หลัก';
      });
      return false;
    }

    // Validate ngan (0-3)
    int ngan = int.tryParse(_nganController.text) ?? 0;
    if (ngan < 0 || ngan >= 4) {
      setState(() {
        _errorMessage = 'งานต้องอยู่ระหว่าง 0-3';
      });
      return false;
    }

    // Validate wa (0-99)
    int wa = int.tryParse(_waController.text) ?? 0;
    if (wa < 0 || wa >= 100) {
      setState(() {
        _errorMessage = 'ตารางวาต้องอยู่ระหว่าง 0-99';
      });
      return false;
    }

    return true;
  }

  bool _validateLocationFields() {
    if (_selectedProvince == null) {
      setState(() {
        _errorMessage = 'กรุณาเลือกจังหวัด';
      });
      return false;
    }

    if (_selectedAmphur == null) {
      setState(() {
        _errorMessage = 'กรุณาเลือกอำเภอ/เขต';
      });
      return false;
    }

    if (_selectedTambon == null) {
      setState(() {
        _errorMessage = 'กรุณาเลือกตำบล/แขวง';
      });
      return false;
    }

    return true;
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

  Future<void> _createListing() async {
    if (_currentUser == null) {
      setState(() {
        _errorMessage = 'คุณต้องเข้าสู่ระบบก่อนสร้างรายการ';
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
        _bedroomController.text.isEmpty ||
        _bathroomController.text.isEmpty ||
        _latitudeController.text.isEmpty ||
        _longitudeController.text.isEmpty) {
      setState(() {
        _errorMessage = 'กรุณากรอกข้อมูลให้ครบทุกช่อง';
      });
      return;
    }

    if (_images.isEmpty) {
      setState(() {
        _errorMessage = 'กรุณาเลือกรูปภาพอย่างน้อย 1 รูป';
      });
      return;
    }

    // Validate area fields
    if (!_validateAreaFields()) {
      return;
    }

    // Validate location fields
    if (!_validateLocationFields()) {
      return;
    }

    int price, bedroom, bathroom;
    double area;
    try {
      price = int.parse(_priceController.text.replaceAll(',', ''));
      area = _calculateTotalAreaInSquareWa();
      bedroom = int.parse(_bedroomController.text);
      bathroom = int.parse(_bathroomController.text);

      if (area <= 0) {
        setState(() {
          _errorMessage = 'กรุณากรอกพื้นที่ให้ถูกต้อง';
        });
        return;
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'กรุณากรอกตัวเลขให้ถูกต้องสำหรับราคา พื้นที่ จำนวนห้องนอน และห้องน้ำ';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Get next real estate ID
      final int realEstateId = await _getNextRealEstateId();
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
        'province': _provinceController.text,
        'real_estate_id': realEstateId,
        'tambon': _tambonController.text,
        'type_realestate': _selectedType,
        'type_sell': _selectedSellType,
        'worker_service': _workerService,
        'user_id': _ownerId,
        'latitude': double.parse(_latitudeController.text),
        'longitude': double.parse(_longitudeController.text),
      });
      // Upload images
      await _uploadImages(realEstateId);
      // Save tags
      await _saveTags(realEstateId);
      // Navigate back to listings
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/my-listings',
        (Route<dynamic> route) => route.isFirst,
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาดในการสร้างรายการ: $e';
      });
      print('Error creating listing: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if worker service field should be disabled
    bool disableWorkerService =
        _currentUser != null && _currentUser!.role == 'worker';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "สร้างรายการใหม่",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onBackground),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isInitialLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentUser == null
              ? const Center(child: Text('กำลังโหลดข้อมูลผู้ใช้...'))
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
                            color: Theme.of(context)
                                .colorScheme
                                .error
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .error
                                    .withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline,
                                  color: Theme.of(context).colorScheme.error),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage,
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.error),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Estate Images
                      const Text(
                        "รูปภาพอสังหาริมทรัพย์",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withOpacity(0.5)),
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
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceVariant,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline
                                          .withOpacity(0.5)),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate,
                                        size: 32, color: Colors.grey),
                                    SizedBox(height: 4),
                                    Text("เพิ่มรูปภาพ",
                                        style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),

                            // Selected images
                            Expanded(
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _images.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: 100,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: FileImage(_images[index]),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: InkWell(
                                            onTap: () => _removeImage(index),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .error,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.close,
                                                size: 16,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onError,
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 2),
                                              color: Colors.black54,
                                              child: const Text(
                                                "ภาพหลัก",
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

                      // Estate Name
                      const Text(
                        "ชื่ออสังหาริมทรัพย์",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: "เช่น บ้านเดี่ยว 100 ตรว. เขตห้วยขวาง",
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withOpacity(0.5)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withOpacity(0.5)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Estate Type
                      const Text(
                        "ประเภทอสังหาริมทรัพย์",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withOpacity(0.5)),
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
                        "ประเภทการขาย",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withOpacity(0.5)),
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

                      // Area Fields (Rai, Ngan, Wa)
                      const Text(
                        "พื้นที่",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Rai
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "ไร่",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                TextFormField(
                                  controller: _raiController,
                                  keyboardType: TextInputType.number,
                                  maxLength: 4,
                                  decoration: InputDecoration(
                                    hintText: "ไร่",
                                    filled: true,
                                    fillColor:
                                        Theme.of(context).colorScheme.surface,
                                    counterText: "",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline
                                              .withOpacity(0.5)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline
                                              .withOpacity(0.5)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Ngan
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "งาน",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                TextFormField(
                                  controller: _nganController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: "งาน",
                                    filled: true,
                                    fillColor:
                                        Theme.of(context).colorScheme.surface,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline
                                              .withOpacity(0.5)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline
                                              .withOpacity(0.5)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Wa
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "ตารางวา",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                TextFormField(
                                  controller: _waController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: "ตารางวา",
                                    filled: true,
                                    fillColor:
                                        Theme.of(context).colorScheme.surface,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline
                                              .withOpacity(0.5)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline
                                              .withOpacity(0.5)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "* พื้นที่ทั้งหมดจะถูกแปลงเป็นตารางวาเพื่อบันทึกลงฐานข้อมูล",
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Bedrooms and Bathrooms
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "ห้องนอน",
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
                                    hintText: "จำนวนห้องนอน",
                                    filled: true,
                                    fillColor:
                                        Theme.of(context).colorScheme.surface,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline
                                              .withOpacity(0.5)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline
                                              .withOpacity(0.5)),
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
                                  "ห้องน้ำ",
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
                                    hintText: "จำนวนห้องน้ำ",
                                    filled: true,
                                    fillColor:
                                        Theme.of(context).colorScheme.surface,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline
                                              .withOpacity(0.5)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline
                                              .withOpacity(0.5)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          // Latitude
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "ละติจูด",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                TextFormField(
                                  controller: _latitudeController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: "ละติจูด",
                                    filled: true,
                                    fillColor:
                                        Theme.of(context).colorScheme.surface,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline
                                              .withOpacity(0.5)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline
                                              .withOpacity(0.5)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Longitude
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "ลองติจูด",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                TextFormField(
                                  controller: _longitudeController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: "ลองติจูด",
                                    filled: true,
                                    fillColor:
                                        Theme.of(context).colorScheme.surface,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline
                                              .withOpacity(0.5)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline
                                              .withOpacity(0.5)),
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
                        "ที่อยู่",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          hintText: "บ้านเลขที่ ถนน ซอย",
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withOpacity(0.5)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withOpacity(0.5)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Province (with search)
                      const Text(
                        "จังหวัด",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: [
                          TextFormField(
                            controller: _provinceController,
                            decoration: InputDecoration(
                              hintText: "ค้นหาจังหวัด",
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _provinceController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setState(() {
                                          _provinceController.clear();
                                          _provinceResults = [];
                                          _selectedProvince = null;
                                        });
                                      },
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outline
                                        .withOpacity(0.5)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outline
                                        .withOpacity(0.5)),
                              ),
                            ),
                            onChanged: (value) {
                              if (value.length >= 2) {
                                _searchProvinces(value);
                              } else if (value.isEmpty) {
                                setState(() {
                                  _provinceResults = [];
                                });
                              }
                            },
                            readOnly: _selectedProvince != null,
                          ),
                          if (_isSearchingProvince)
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          if (_provinceResults.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outline
                                        .withOpacity(0.5)),
                              ),
                              constraints: BoxConstraints(
                                maxHeight: 200,
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: _provinceResults.length,
                                itemBuilder: (context, index) {
                                  final province = _provinceResults[index];
                                  return ListTile(
                                    title: Text(province['name_th']),
                                    onTap: () => _selectProvince(province),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Amphur (with search)
                      const Text(
                        "อำเภอ/เขต",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: [
                          TextFormField(
                            controller: _amphurController,
                            decoration: InputDecoration(
                              hintText: "ค้นหาอำเภอ/เขต",
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _amphurController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setState(() {
                                          _amphurController.clear();
                                          _amphurResults = [];
                                          _selectedAmphur = null;
                                        });
                                      },
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outline
                                        .withOpacity(0.5)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outline
                                        .withOpacity(0.5)),
                              ),
                            ),
                            onChanged: (value) {
                              if (_selectedProvince != null &&
                                  value.length >= 2) {
                                _searchAmphures(value);
                              } else if (value.isEmpty) {
                                setState(() {
                                  _amphurResults = [];
                                });
                              }
                            },
                            readOnly: _selectedProvince == null ||
                                _selectedAmphur != null,
                            enabled: _selectedProvince != null,
                          ),
                          if (_isSearchingAmphur)
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          if (_amphurResults.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outline
                                        .withOpacity(0.5)),
                              ),
                              constraints: BoxConstraints(
                                maxHeight: 200,
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: _amphurResults.length,
                                itemBuilder: (context, index) {
                                  final amphur = _amphurResults[index];
                                  return ListTile(
                                    title: Text(amphur['name_th']),
                                    onTap: () => _selectAmphur(amphur),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Tambon (with search)
                      const Text(
                        "ตำบล/แขวง",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: [
                          TextFormField(
                            controller: _tambonController,
                            decoration: InputDecoration(
                              hintText: "ค้นหาตำบล/แขวง",
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _tambonController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setState(() {
                                          _tambonController.clear();
                                          _tambonResults = [];
                                          _selectedTambon = null;
                                        });
                                      },
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outline
                                        .withOpacity(0.5)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outline
                                        .withOpacity(0.5)),
                              ),
                            ),
                            onChanged: (value) {
                              if (_selectedAmphur != null &&
                                  value.length >= 2) {
                                _searchTambons(value);
                              } else if (value.isEmpty) {
                                setState(() {
                                  _tambonResults = [];
                                });
                              }
                            },
                            readOnly: _selectedAmphur == null ||
                                _selectedTambon != null,
                            enabled: _selectedAmphur != null,
                          ),
                          if (_isSearchingTambon)
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          if (_tambonResults.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outline
                                        .withOpacity(0.5)),
                              ),
                              constraints: BoxConstraints(
                                maxHeight: 200,
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: _tambonResults.length,
                                itemBuilder: (context, index) {
                                  final tambon = _tambonResults[index];
                                  return ListTile(
                                    title: Text(tambon['name_th']),
                                    onTap: () => _selectTambon(tambon),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Price
                      const Text(
                        "ราคา",
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
                          hintText: "ราคา (บาท)",
                          prefixText: "฿ ",
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withOpacity(0.5)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withOpacity(0.5)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Owner (user_id) search
                      const Text(
                        "เจ้าของอสังหาริมทรัพย์",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: [
                          TextFormField(
                            controller: _searchUserController,
                            decoration: InputDecoration(
                              hintText: "ค้นหาผู้ใช้ด้วยอีเมล",
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _searchUserController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setState(() {
                                          _searchUserController.clear();
                                          _searchResults = [];
                                        });
                                      },
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outline
                                        .withOpacity(0.5)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outline
                                        .withOpacity(0.5)),
                              ),
                            ),
                            onChanged: (value) {
                              if (value.length >= 3) {
                                _searchUsersByEmail(value);
                              } else if (value.isEmpty) {
                                setState(() {
                                  _searchResults = [];
                                });
                              }
                            },
                          ),
                          if (_isSearchingUser)
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          if (_searchResults.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outline
                                        .withOpacity(0.5)),
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _searchResults.length,
                                itemBuilder: (context, index) {
                                  final user = _searchResults[index]!;
                                  return ListTile(
                                    title: Text(user.email),
                                    subtitle: Text('Name: ${user.fullName}'),
                                    onTap: () => _selectUser(user),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Tags
                      const Text(
                        "แท็กอสังหาริมทรัพย์",
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                        .colorScheme
                                        .surfaceVariant,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                entry.value,
                                style: TextStyle(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
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
                        "รายละเอียดอสังหาริมทรัพย์",
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
                          hintText: "อธิบายรายละเอียดอสังหาริมทรัพย์...",
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withOpacity(0.5)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withOpacity(0.5)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Worker Service Level
                      const Text(
                        "พนักงานดูแล",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withOpacity(0.5)),
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
                            onChanged: disableWorkerService
                                ? null
                                : (int? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _workerService = newValue;
                                      });
                                    }
                                  },
                          ),
                        ),
                      ),
                      if (disableWorkerService)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            "* คุณไม่สามารถเปลี่ยนพนักงานดูแลได้เนื่องจากคุณเป็นพนักงานดูแลรายการนี้",
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Premium Promotion
                      SwitchListTile(
                        title: const Text(
                          "โปรโมชั่นพรีเมียม",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: const Text(
                          "รายการของคุณจะได้รับการโปรโมทและมองเห็นได้มากขึ้น",
                          style: TextStyle(fontSize: 12),
                        ),
                        value: _isPremium,
                        activeColor: Theme.of(context).colorScheme.primary,
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
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary)
                              : const Text(
                                  "สร้างรายการ",
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
