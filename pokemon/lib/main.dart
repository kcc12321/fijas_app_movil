import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ui/login_page.dart';
import 'ui/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool isLogged = prefs.getBool('is_logged_in') ?? false;

  runApp(MyApp(isLogged: isLogged));
}

class MyApp extends StatelessWidget {
  final bool isLogged;
  const MyApp({super.key, required this.isLogged});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokedex',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
      ),
      home: isLogged ? const HomePage() : const LoginPage(),
    );
  }
}