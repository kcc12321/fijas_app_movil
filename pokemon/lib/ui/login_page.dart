import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController nameController = TextEditingController();

  void login() async {
    if (nameController.text.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('trainer_name', nameController.text);

      if (mounted) {
        // Matamos el login para no volver atrás
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.redAccent, // Color Pokedex
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.catching_pokemon, size: 100, color: Colors.red),
                const SizedBox(height: 20),
                const Text("POKEDEX REGIONAL", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Nombre de Entrenador",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text("INICIAR AVENTURA"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}