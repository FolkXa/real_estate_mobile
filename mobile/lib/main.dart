import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:real_estate_project/firebase_options.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'screens/create_listing.dart';
import 'screens/my_listing.dart';
import 'screens/sign_up.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        '/login': (context) => LoginScreen(),
        '/my-listings': (context) => const MyListingsScreen(),
        '/create-listing': (context) => const CreateListingScreen(),
      },
    );
  }
}

