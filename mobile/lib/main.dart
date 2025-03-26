import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:real_estate_project/favorite_screen.dart';
import 'package:real_estate_project/my_property_screen.dart';
import 'package:real_estate_project/profile_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:real_estate_project/sub_category_screen.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'screens/sign_up.dart';

const FirebaseOptions android = FirebaseOptions(
  apiKey: 'AIzaSyChHwsM17SBFySEgtHIJtzqRWI0kkJ6kWo',
  appId: '1:266614568627:android:042069257b56d65dffa2c6',
  messagingSenderId: '266614568627',
  projectId: 'pj-realestate',
  storageBucket: 'pj-realestate.firebasestorage.app',
);

const FirebaseOptions ios = FirebaseOptions(
  apiKey: 'AIzaSyCjVN5Su92iL5oomLHtMecYZVVfTboVH74',
  appId: '1:266614568627:ios:23a543b5bc86cccdffa2c6',
  messagingSenderId: '266614568627',
  projectId: 'pj-realestate',
  storageBucket: 'pj-realestate.firebasestorage.app',
  iosBundleId: 'com.example.realEstateProject',
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // โหลด .env ก่อน runApp
  await Firebase.initializeApp(options: ios);
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
      },
    );
  }
}
