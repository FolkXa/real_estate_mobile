import 'dart:convert';
import 'package:flutter/services.dart';

class ThailandDivision {
  List<Map<String, dynamic>> provinces = [];
  List<Map<String, dynamic>> amphures = [];
  List<Map<String, dynamic>> tambons = [];

  Future<void> loadJsonData() async {
    final String provinceJson =
        await rootBundle.loadString("assets/data/thai_provinces.json");
    final String amphureJson =
        await rootBundle.loadString("assets/data/thai_amphures.json");
    final String tambonJson =
        await rootBundle.loadString("assets/data/thai_tambons.json");

    provinces = List<Map<String, dynamic>>.from(json.decode(provinceJson));
    amphures = List<Map<String, dynamic>>.from(json.decode(amphureJson));
    tambons = List<Map<String, dynamic>>.from(json.decode(tambonJson));
  }

  List<Map<String, dynamic>> searchProvince(String query) {
    return provinces
        .where((province) => province['name_th'].toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  List<Map<String, dynamic>> searchAmphure(String query) {
    return amphures
        .where((amphure) => amphure['name_th'].toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  List<Map<String, dynamic>> searchTambon(String query) {
    return tambons
        .where((tambon) => tambon['name_th'].toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
