import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:real_estate_project/firebase_options.dart';
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
import 'screens/my_estate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // โหลด .env ก่อน runApp
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
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
        '/my-estates': (context) => const MyEstatesScreen(),
        '/create-listing': (context) => const CreateListingScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
      },
    );
  }
}

