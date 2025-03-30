import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:real_estate_project/favorite_screen.dart';
import 'package:real_estate_project/firebase_options.dart';
import 'package:real_estate_project/my_property_screen.dart';
import 'package:real_estate_project/profile_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:real_estate_project/sub_category_screen.dart';
import 'package:real_estate_project/screens/my_listing.dart';
import 'package:real_estate_project/screens/create_listing.dart';

import 'login_screen.dart';
import 'home_screen.dart';
import 'screens/my_estate.dart';
import 'screens/sign_up.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // โหลด .env ก่อน runApp
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Real Estate App',
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/home': (context) => HomeScreen(),
        '/profile': (context) => ProfileScreen(),
        '/my_properties': (context) => MyPropertyScreen(),
        '/favorite': (context) => FavoriteScreen(),
        '/login': (context) => LoginScreen(),
        '/category': (context) => SubCategoryScreen(category: "บ้านเดี่ยว"),
        '/my-listings': (context) => const MyListingsScreen(),
        '/my-estates': (context) => const MyEstatesScreen(),
        '/create-listing': (context) => const CreateListingScreen(),
      },
    );
  }
}
