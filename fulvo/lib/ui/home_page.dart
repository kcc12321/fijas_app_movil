import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player.dart';
import '../utils/http_helper.dart';
// import 'favorites_page.dart'; // Crearemos esta después
import 'favorites_page.dart';
import 'login_page.dart';
import 'player_detail.dart'; // Crearemos esta después

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 1. Variables de Estado
  List<Player> players = [];
  bool loading = false;

  // Lista de opciones para el Dropdown (Tal cual pide el examen)
  final List<String> positions = ['Portero', 'Defensor', 'Mediocampista', 'Delantero'];

  // Variable para guardar la opción seleccionada (Inicia con la primera)
  String selectedPosition = 'Portero';

  late HttpHelper httpHelper;

  @override
  void initState() {
    super.initState();
    httpHelper = HttpHelper();
    // Opcional: Podrías cargar la primera posición automáticamente al iniciar
    // searchPlayers();
  }

  // Función para buscar
  void searchPlayers() async {
    setState(() {
      loading = true; // Mostramos círculo de carga
      players = [];   // Limpiamos la lista anterior
    });

    // Llamamos a la API con la posición seleccionada
    // .toLowerCase() es importante si la API espera "portero" y no "Portero"
    List<Player> result = await httpHelper.getPlayers(selectedPosition.toLowerCase());

    setState(() {
      players = result;
      loading = false; // Ocultamos círculo
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ProPlayer"),
        actions: [
          // Botón para ir a Favoritos
          IconButton(
            icon: const Icon(Icons.star),
            tooltip: "Ir a Favoritos",
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FavoritesPage())
              );
            },
          ),
          // IconButton(
          //   icon: const Icon(Icons.logout),
          //   tooltip: "Salir",
          //   onPressed: () async {
          //     // 1. Borramos la bandera de sesión
          //     final prefs = await SharedPreferences.getInstance();
          //     await prefs.clear(); // O prefs.setBool('is_logged_in', false);
          //
          //     // 2. Volvemos al Login y matamos el Home
          //     if (context.mounted) {
          //       Navigator.pushReplacement(
          //         context,
          //         MaterialPageRoute(builder: (context) => const LoginPage()),
          //       );
          //     }
          //   },
          // ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- ZONA DE FILTROS ---
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text("Buscar por posición:", style: TextStyle(fontWeight: FontWeight.bold)),

                    // EL DROPDOWN (ComboBox)
                    DropdownButton<String>(
                      value: selectedPosition,
                      isExpanded: true, // Ocupa todo el ancho
                      items: positions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedPosition = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 10),

                    // BOTÓN BUSCAR
                    ElevatedButton.icon(
                      onPressed: searchPlayers, // Llama a la función
                      icon: const Icon(Icons.search),
                      label: const Text("BUSCAR JUGADORES"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 45)
                      ),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- LISTA DE RESULTADOS ---
            Expanded( // Ocupa el resto del espacio
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : players.isEmpty
                  ? const Center(child: Text("Selecciona una posición y busca"))
                  : ListView.builder(
                itemCount: players.length,
                itemBuilder: (context, index) {
                  return PlayerRow(player: players[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget separado para cada jugador (Más ordenado)
class PlayerRow extends StatelessWidget {
  final Player player;
  const PlayerRow({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Image.network(
          player.picture,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => const Icon(Icons.person, size: 50),
        ),
        title: Text(player.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${player.country} | ${player.team}"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // AQUÍ NAVEGAREMOS AL DETALLE

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PlayerDetail(player))
          );

        },
      ),
    );
  }
}