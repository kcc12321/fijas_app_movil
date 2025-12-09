import 'package:flutter/material.dart';

import 'apod_list.dart';
import 'favorites.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 1. DATOS DEL ALUMNO (Requisito)
  final String studentName = "Cassius Martel";
  final int studentCode = 202312287; // ¡PON UN CÓDIGO IMPAR AQUÍ! (Termina en 3)

  String apiName = "";
  String message = "";

  @override
  void initState() {
    super.initState();
    calculateApi();
  }

  // 2. ALGORITMO DE SELECCIÓN DE API (Requisito Crítico)
  void calculateApi() {
    // Obtenemos el último dígito
    int lastDigit = studentCode % 10;

    if (lastDigit % 2 != 0) {
      // Es IMPAR
      apiName = "APOD (Astronomy Picture of the Day)";
      message = "Tu código termina en $lastDigit (Impar).";
    } else {
      // Es PAR (Mars Rover) - No deberíamos caer aquí si tu código es impar
      apiName = "Mars Rover Photos";
      message = "Tu código termina en $lastDigit (Par).";
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
            image: DecorationImage(
              // Imagen de fondo espacial
                image: NetworkImage("https://apod.nasa.gov/apod/image/2311/M33_Triangulum_2023_1024.jpg"),
                fit: BoxFit.cover,
                opacity: 0.6
            )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage("https://cdn-icons-png.flaticon.com/512/1995/1995655.png"), // Icono astronauta
            ),
            const SizedBox(height: 20),
            Text("Bienvenido, $studentName",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            Text("Código: $studentCode",
                style: const TextStyle(fontSize: 18, color: Colors.white70)),
            const SizedBox(height: 30),

            // TARJETA CON EL RESULTADO DEL ALGORITMO
            Card(
              color: Colors.black54,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(message, style: const TextStyle(color: Colors.yellowAccent)),
                    const SizedBox(height: 10),
                    const Text("API Asignada:", style: TextStyle(color: Colors.white)),
                    Text(apiName,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 50),

            // BOTONES DE NAVEGACIÓN
            ElevatedButton.icon(
              icon: const Icon(Icons.rocket_launch),
              label: const Text("MOSTRAR (API)"),
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: Colors.blueAccent
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ApodListPage()));
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.star),
              label: const Text("FAVORITOS (BD)"),
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: Colors.orangeAccent
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesPage()));
              },
            ),
          ],
        ),
      ),
    );
  }
}