import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:real_estate_project/screens/SearchResultPage.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // Controllers
  TextEditingController _provinceController = TextEditingController();
  TextEditingController _bedroomController = TextEditingController();
  TextEditingController _bathroomController = TextEditingController();
  TextEditingController _minPriceController = TextEditingController();
  TextEditingController _maxPriceController = TextEditingController();
  RangeValues _priceRange = RangeValues(300000, 1000000);
  TextEditingController _minRentController = TextEditingController();
  TextEditingController _maxRentController = TextEditingController();
  RangeValues _rentRange = RangeValues(3000, 30000);
  final NumberFormat currencyFormat = NumberFormat("#,###");
  double minLimit = 100000;
  double maxLimit = 100000000;
  double step = 100000;
  bool isSellSelected = false;
  bool isRentSelected = false;
  List<String> selectedSaleTypes = [];

  void _updatePriceTextFields() {
    _minPriceController.text = currencyFormat.format(_priceRange.start.toInt());
    _maxPriceController.text = currencyFormat.format(_priceRange.end.toInt());
  }

  void _onMinPriceChanged(String value) {
    String clean = value.replaceAll(",", "");
    double? parsed = double.tryParse(clean);
    if (parsed != null) {
      double newMin = parsed.clamp(minLimit, maxLimit - step);
      double newMax = (newMin + step).clamp(newMin + step, maxLimit);

      setState(() {
        _priceRange = RangeValues(newMin, newMax);
        _minPriceController.text = currencyFormat.format(newMin.toInt());
        _maxPriceController.text = currencyFormat.format(newMax.toInt());
      });
    }
  }

  void _onMinRentChanged(String value) {
    String clean = value.replaceAll(",", "");
    double? parsed = double.tryParse(clean);
    if (parsed != null) {
      double newMin = parsed.clamp(1000, 100000 - 1000);
      double newMax = (newMin + 1000).clamp(newMin + 1000, 100000);
      setState(() {
        _rentRange = RangeValues(newMin, newMax);
        _minRentController.text = currencyFormat.format(newMin.toInt());
        _maxRentController.text = currencyFormat.format(newMax.toInt());
      });
    }
  }

  void _onMaxPriceChanged(String value) {
    String clean = value.replaceAll(",", "");
    double? parsed = double.tryParse(clean);
    if (parsed != null) {
      double newMax = parsed.clamp(_priceRange.start + step, maxLimit);
      setState(() {
        _priceRange = RangeValues(_priceRange.start, newMax);
        _maxPriceController.text = currencyFormat.format(newMax.toInt());
      });
    }
  }

  void _onMaxRentChanged(String value) {
    String clean = value.replaceAll(",", "");
    double? parsed = double.tryParse(clean);
    if (parsed != null) {
      double newMax = parsed.clamp(_rentRange.start + 1000, 100000);
      setState(() {
        _rentRange = RangeValues(_rentRange.start, newMax);
        _maxRentController.text = currencyFormat.format(newMax.toInt());
      });
    }
  }

  // รายการข้อมูล
  List<Map<String, dynamic>> provinces = [];
  List<Map<String, dynamic>> amphures = [];
  List<Map<String, dynamic>> tambons = [];

  // เก็บค่าที่เลือก
  String? selectedProvince;
  String? selectedAmphure;
  String? selectedTambon;
  String? selectedPropertyType;
  List<Map<String, dynamic>> filteredAmphures = [];
  List<Map<String, dynamic>> filteredTambons = [];

  // Suggest Overlay
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();
  GlobalKey _textFieldKey = GlobalKey();
  List<String> searchSuggestions = [];

  // รายการประเภทอสังหาริมทรัพย์
  final List<String> propertyTypes = [
    "บ้านเดี่ยว",
    "ทาวเฮ้า",
    "คอนโด",
    "ที่ดิน"
  ];

  @override
  void initState() {
    super.initState();
    _loadJsonData();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _removeOverlay();
      }
    });
  }

  Future<void> _loadJsonData() async {
    final String provinceJson =
        await rootBundle.loadString("assets/data/thai_provinces.json");
    final String amphureJson =
        await rootBundle.loadString("assets/data/thai_amphures.json");
    final String tambonJson =
        await rootBundle.loadString("assets/data/thai_tambons.json");

    setState(() {
      provinces = List<Map<String, dynamic>>.from(json.decode(provinceJson));
      amphures = List<Map<String, dynamic>>.from(json.decode(amphureJson));
      tambons = List<Map<String, dynamic>>.from(json.decode(tambonJson));
    });
  }

  void _searchProvince(String query) {
    if (query.isEmpty) {
      setState(() => searchSuggestions = []);
      _removeOverlay();
      return;
    }

    List<String> suggestions = provinces
        .where((p) => p["name_th"].contains(query))
        .map((p) => p["name_th"].toString())
        .toList();

    setState(() {
      searchSuggestions = suggestions;
    });

    if (searchSuggestions.isNotEmpty) {
      _showOverlay(context, searchSuggestions, _onProvinceSelected);
    } else {
      _removeOverlay();
    }
  }

  void _searchAmphure(String query) {
    if (query.isEmpty) {
      setState(() => searchSuggestions = []);
      _removeOverlay();
      return;
    }

    List<String> suggestions = filteredAmphures
        .where((a) => a["name_th"].contains(query))
        .map((a) => a["name_th"].toString())
        .toList();

    setState(() {
      searchSuggestions = suggestions;
    });

    if (searchSuggestions.isNotEmpty) {
      _showOverlay(context, searchSuggestions, _onAmphureSelected);
    } else {
      _removeOverlay();
    }
  }

  void _searchTambon(String query) {
    if (query.isEmpty) {
      setState(() => searchSuggestions = []);
      _removeOverlay();
      return;
    }

    List<String> suggestions = filteredTambons
        .where((t) => t["name_th"].contains(query))
        .map((t) => t["name_th"].toString())
        .toList();

    setState(() {
      searchSuggestions = suggestions;
    });

    if (searchSuggestions.isNotEmpty) {
      _showOverlay(context, searchSuggestions, _onTambonSelected);
    } else {
      _removeOverlay();
    }
  }

  void _onProvinceSelected(String value) {
    setState(() {
      selectedProvince = value;
      selectedAmphure = null;
      selectedTambon = null;
      _provinceController.text = value;
      searchSuggestions = [];

      final selectedProvinceId = provinces
              .firstWhere((p) => p["name_th"] == value, orElse: () => {})
              .containsKey("id")
          ? provinces.firstWhere((p) => p["name_th"] == value)["id"]
          : null;

      filteredAmphures = amphures
          .where((a) => a["province_id"] == selectedProvinceId)
          .toList();
      filteredTambons = [];
    });

    _removeOverlay();
  }

  void _onAmphureSelected(String? value) {
    if (value == null) return;
    setState(() {
      selectedAmphure = value;
      selectedTambon = null;

      final selectedAmphureId = filteredAmphures
              .firstWhere((a) => a["name_th"] == value, orElse: () => {})
              .containsKey("id")
          ? filteredAmphures.firstWhere((a) => a["name_th"] == value)["id"]
          : null;

      filteredTambons =
          tambons.where((t) => t["amphure_id"] == selectedAmphureId).toList();
    });
  }

  void _onTambonSelected(String? value) {
    if (value == null) return;
    setState(() {
      selectedTambon = value;
    });
  }

  void _onPropertyTypeSelected(String? value) {
    setState(() {
      selectedPropertyType = value;
    });
  }

  void _clearSelection() {
    setState(() {
      selectedProvince = null;
      selectedAmphure = null;
      selectedTambon = null;
      selectedPropertyType = null;
      _provinceController.clear();
      _bedroomController.clear();
      _bathroomController.clear();
      filteredAmphures = [];
      filteredTambons = [];
      searchSuggestions = [];
    });
    _removeOverlay();
  }

  void _showOverlay(BuildContext context, List<String> suggestions,
      Function(String) onSelect) {
    _removeOverlay();
    final overlay = Overlay.of(context);
    final RenderBox renderBox =
        _textFieldKey.currentContext!.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 5,
        width: size.width,
        child: Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          child: Container(
            constraints: BoxConstraints(maxHeight: 250),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                  child: ListTile(
                    title: Text(
                      suggestions[index],
                      style: TextStyle(fontSize: 16),
                    ),
                    trailing: Icon(Icons.location_on, color: Colors.blueAccent),
                    onTap: () {
                      onSelect(suggestions[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _provinceController.dispose();
    _bedroomController.dispose();
    _bathroomController.dispose();
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Search Real Estate"), backgroundColor: Colors.purple),
      body: SafeArea(
        child: GestureDetector(
          onTap: () =>
              FocusScope.of(context).unfocus(), // ปิดคีย์บอร์ดเมื่อแตะข้างนอก
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("ประเภทการขาย",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        title: Text("ขายขาด"),
                        value: isSellSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            isSellSelected = value ?? false;
                            if (isSellSelected) {
                              if (!selectedSaleTypes.contains("ขายขาด")) {
                                selectedSaleTypes.add("ขายขาด");
                              }
                            } else {
                              selectedSaleTypes.remove("ขายขาด");
                            }
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        title: Text("เช่า"),
                        value: isRentSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            isRentSelected = value ?? false;
                            if (isRentSelected) {
                              if (!selectedSaleTypes.contains("เช่า")) {
                                selectedSaleTypes.add("เช่า");
                              }
                            } else {
                              selectedSaleTypes.remove("เช่า");
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text("เลือกที่ตั้ง",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    )),
                SizedBox(height: 10),
                TextField(
                  key: _textFieldKey,
                  controller: _provinceController,
                  focusNode: _focusNode,
                  onChanged: _searchProvince,
                  decoration: InputDecoration(
                    hintText: "พิมพ์ชื่อจังหวัด",
                    prefixIcon: Icon(Icons.location_city, color: Colors.blue),
                    suffixIcon: _provinceController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                selectedProvince = null;
                                selectedAmphure = null;
                                selectedTambon = null;
                                _provinceController.clear();
                                filteredAmphures = [];
                                filteredTambons = [];
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text("เลือกอำเภอ"),
                SizedBox(height: 5),
                DropdownButtonFormField<String>(
                  value: selectedAmphure,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.map, color: Colors.orange),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  hint: Text("เลือกอำเภอ"),
                  isExpanded: true,
                  items: filteredAmphures.map((a) {
                    return DropdownMenuItem<String>(
                      value: a['name_th'],
                      child: Text(a['name_th']),
                    );
                  }).toList(),
                  onChanged: _onAmphureSelected,
                ),
                SizedBox(height: 10),
                Text("เลือกตำบล"),
                SizedBox(height: 5),
                DropdownButtonFormField<String>(
                  value: selectedTambon,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.place, color: Colors.red),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  hint: Text("เลือกตำบล"),
                  isExpanded: true,
                  items: filteredTambons.map((t) {
                    return DropdownMenuItem<String>(
                      value: t['name_th'],
                      child: Text(t['name_th']),
                    );
                  }).toList(),
                  onChanged: _onTambonSelected,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "เลือกประเภทอสังหาริมทรัพย์",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          selectedPropertyType = null;
                          _bedroomController.clear();
                          _bathroomController.clear();
                        });
                      },
                      label: Text("รีเซ็ต",
                          style: TextStyle(
                              color: const Color.fromARGB(255, 104, 103, 103))),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                DropdownButton<String>(
                  value: selectedPropertyType,
                  hint: Text("เลือกประเภท"),
                  isExpanded: true,
                  items: propertyTypes.map((p) {
                    return DropdownMenuItem<String>(
                      value: p,
                      child: Text(p),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPropertyType = value;
                    });
                  },
                ),
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0.0, -0.3),
                        end: Offset.zero,
                      ).animate(animation),
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: (selectedPropertyType == "บ้านเดี่ยว" ||
                          selectedPropertyType == "ทาวเฮ้า")
                      ? Column(
                          key: ValueKey<String>(selectedPropertyType ?? ""),
                          children: [
                            SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: TextField(
                                controller: _bedroomController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.right,
                                decoration: InputDecoration(
                                  labelText: "จำนวนห้องนอน",
                                  prefixIcon:
                                      Icon(Icons.bed, color: Colors.purple),
                                  suffixText: " ห้อง",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 16),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: TextField(
                                controller: _bathroomController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.right,
                                decoration: InputDecoration(
                                  labelText: "จำนวนห้องน้ำ",
                                  prefixIcon:
                                      Icon(Icons.bathtub, color: Colors.blue),
                                  suffixText: " ห้อง",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 16),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
                        )
                      : SizedBox.shrink(),
                ),
                SizedBox(height: 20),
                SizedBox(height: 5),
                if (isSellSelected)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("ช่วงราคาขายขาดที่ต้องการ",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      buildPriceInputSection(
                        minController: _minPriceController,
                        maxController: _maxPriceController,
                        suffix: " บาท",
                        onMinChanged: _onMinPriceChanged,
                        onMaxChanged: _onMaxPriceChanged,
                      ),
                      SizedBox(height: 5),
                      buildPriceRangeSlider(
                        rangeValues: _priceRange,
                        min: minLimit,
                        max: maxLimit,
                        step: step,
                        formatter: currencyFormat,
                        onChanged: (RangeValues values) {
                          if (values.start < values.end) {
                            setState(() {
                              _priceRange = RangeValues(
                                (values.start / step).round() * step,
                                (values.end / step).round() * step,
                              );
                              _minPriceController.text = currencyFormat
                                  .format(_priceRange.start.toInt());
                              _maxPriceController.text = currencyFormat
                                  .format(_priceRange.end.toInt());
                            });
                          }
                        },
                      ),
                    ],
                  ),
                if (isRentSelected)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("ช่วงราคาเช่าที่ต้องการ (บาท/เดือน)",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      buildPriceInputSection(
                        minController: _minRentController,
                        maxController: _maxRentController,
                        suffix: " /เดือน",
                        onMinChanged: _onMinRentChanged,
                        onMaxChanged: _onMaxRentChanged,
                      ),
                      SizedBox(height: 5),
                      buildPriceRangeSlider(
                        rangeValues: _rentRange,
                        min: 1000,
                        max: 100000,
                        step: 1000,
                        formatter: currencyFormat,
                        onChanged: (RangeValues values) {
                          setState(() {
                            _rentRange = values;
                            _minRentController.text =
                                currencyFormat.format(values.start.toInt());
                            _maxRentController.text =
                                currencyFormat.format(values.end.toInt());
                          });
                        },
                      ),
                    ],
                  ),
                SizedBox(height: 2),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchResultPage(
                          province: selectedProvince,
                          amphure: selectedAmphure,
                          tambon: selectedTambon,
                          propertyType: selectedPropertyType,
                          bedroom: _bedroomController.text.isNotEmpty
                              ? int.tryParse(_bedroomController.text)
                              : null,
                          bathroom: _bathroomController.text.isNotEmpty
                              ? int.tryParse(_bathroomController.text)
                              : null,
                          minPrice: _minPriceController.text.isNotEmpty
                              ? double.tryParse(
                                  _minPriceController.text.replaceAll(",", ""))
                              : null,
                          maxPrice: _maxPriceController.text.isNotEmpty
                              ? double.tryParse(
                                  _maxPriceController.text.replaceAll(",", ""))
                              : null,

                          // 🔹 เพิ่มการส่งค่าราคาเช่า
                          minRent: _minRentController.text.isNotEmpty
                              ? double.tryParse(
                                  _minRentController.text.replaceAll(",", ""))
                              : null,
                          maxRent: _maxRentController.text.isNotEmpty
                              ? double.tryParse(
                                  _maxRentController.text.replaceAll(",", ""))
                              : null,
                          saleTypes: selectedSaleTypes,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Center(
                    child: Text("ค้นหา",
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPriceInputSection({
    required TextEditingController minController,
    required TextEditingController maxController,
    required String suffix,
    required void Function(String) onMinChanged,
    required void Function(String) onMaxChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: minController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            onChanged: onMinChanged,
            decoration: InputDecoration(
              labelText: "ต่ำสุด",
              prefixText: "฿ ",
              suffixText: suffix,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: maxController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            onChanged: onMaxChanged,
            decoration: InputDecoration(
              labelText: "สูงสุด",
              prefixText: "฿ ",
              suffixText: suffix,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildPriceRangeSlider({
    required RangeValues rangeValues,
    required double min,
    required double max,
    required double step,
    required ValueChanged<RangeValues> onChanged,
    required NumberFormat formatter,
  }) {
    return RangeSlider(
      values: rangeValues,
      min: min,
      max: max,
      divisions: ((max - min) ~/ step),
      labels: RangeLabels(
        formatter.format(rangeValues.start.toInt()),
        formatter.format(rangeValues.end.toInt()),
      ),
      onChanged: (RangeValues values) {
        if (values.start < values.end) {
          onChanged(
            RangeValues(
              (values.start / step).round() * step,
              (values.end / step).round() * step,
            ),
          );
        }
      },
    );
  }
}
