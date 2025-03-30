import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:real_estate_project/screens/forgot_password_screen.dart';
import 'screens/settings_screen.dart';
import 'theme.dart';
import 'theme_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/sign_up.dart';
import 'package:real_estate_project/screens/favorite_screen.dart';
import 'package:real_estate_project/screens/my_property_screen.dart';
import 'package:real_estate_project/screens/profile_screen.dart';
import 'package:real_estate_project/screens/sub_category_screen.dart';
import 'package:real_estate_project/screens/my_listing.dart';
import 'package:real_estate_project/screens/create_listing.dart';

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
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: ios);

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Real Estate App',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: MyThemes.lightTheme,
      darkTheme: MyThemes.darkTheme,
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
        '/create-listing': (context) => const CreateListingScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
      },
    );
  }
}
