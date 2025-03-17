import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String? selectedLocation;
  List<Map<String, dynamic>> provinces = [];
  List<Map<String, dynamic>> amphures = [];
  List<Map<String, dynamic>> tambons = [];
  List<String> searchSuggestions = [];

  TextEditingController _searchController = TextEditingController();
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();
  GlobalKey _textFieldKey = GlobalKey();

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

  void _searchLocation(String query) {
    if (query.isEmpty) {
      setState(() => searchSuggestions = []);
      _removeOverlay();
      return;
    }

    List<String> suggestions = [];

    // ✅ แนะนำ จังหวัด (กรณีผู้ใช้พิมพ์จังหวัด)
    provinces.forEach((p) {
      if (p["name_th"].startsWith(query) || p["name_th"].contains(query)) {
        suggestions.add(p["name_th"]);
        // ✅ หาอำเภอที่อยู่ในจังหวัดนี้
        List<Map<String, dynamic>> relatedAmphures =
            amphures.where((a) => a["province_id"] == p["id"]).toList();
        relatedAmphures.forEach((a) {
          suggestions.add("${p["name_th"]} -> ${a["name_th"]}");
          // ✅ หา ตำบลที่อยู่ในอำเภอนี้
          List<Map<String, dynamic>> relatedTambons =
              tambons.where((t) => t["amphure_id"] == a["id"]).toList();
          relatedTambons.forEach((t) {
            suggestions
                .add("${p["name_th"]} -> ${a["name_th"]} -> ${t["name_th"]}");
          });
        });
      }
    });

    // ✅ แนะนำ อำเภอ ที่มีคำที่ตรงกัน
    amphures.forEach((a) {
      if (a["name_th"].startsWith(query) || a["name_th"].contains(query)) {
        final province = provinces
            .firstWhere((p) => p["id"] == a["province_id"], orElse: () => {});
        suggestions.add("${province["name_th"]} -> ${a["name_th"]}");
        // ✅ หา ตำบลที่อยู่ในอำเภอนี้
        List<Map<String, dynamic>> relatedTambons =
            tambons.where((t) => t["amphure_id"] == a["id"]).toList();
        relatedTambons.forEach((t) {
          suggestions.add(
              "${province["name_th"]} -> ${a["name_th"]} -> ${t["name_th"]}");
        });
      }
    });

    // ✅ แนะนำ ตำบล (เฉพาะที่ชื่อเริ่มต้นหรือมีคำที่ตรงกัน)
    tambons.forEach((t) {
      if (t["name_th"].startsWith(query) || t["name_th"].contains(query)) {
        final amphure = amphures.firstWhere((a) => a["id"] == t["amphure_id"],
            orElse: () => {});
        final province = provinces.firstWhere(
            (p) => p["id"] == amphure["province_id"],
            orElse: () => {});
        suggestions.add(
            "${province["name_th"]} -> ${amphure["name_th"]} -> ${t["name_th"]}");
      }
    });

    setState(() {
      searchSuggestions = suggestions.toSet().toList();
    });

    if (searchSuggestions.isNotEmpty) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
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
          elevation: 4.0,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            constraints: BoxConstraints(maxHeight: 250),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: searchSuggestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(searchSuggestions[index]),
                  onTap: () {
                    setState(() {
                      selectedLocation = searchSuggestions[index];
                      _searchController.text = searchSuggestions[index];
                      searchSuggestions = [];
                    });
                    _removeOverlay();
                  },
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
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Search Real Estate"), backgroundColor: Colors.purple),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CompositedTransformTarget(
              link: _layerLink,
              child: TextField(
                key: _textFieldKey,
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: _searchLocation,
                decoration: InputDecoration(
                  hintText: "พิมพ์ชื่อจังหวัด อำเภอ หรือ ตำบล",
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => searchSuggestions = []);
                            _removeOverlay();
                          })
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
