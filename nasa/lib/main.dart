import 'package:flutter/material.dart';
import 'package:nasa/ui/home_page.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyNasaInsights',
      theme: ThemeData.dark(), // Tema oscuro estilo espacio
      home: const HomePage(),
    );
  }
}

