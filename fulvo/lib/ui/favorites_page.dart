import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player.dart';
import '../utils/db_helper.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late DbHelper dbHelper;
  late Future<List<Player>> loadFuture;
  int totalGoals = 0;

  @override
  void initState() {
    super.initState();
    dbHelper = DbHelper();
    loadFuture = loadFavorites();
  }

  Future<List<Player>> loadFavorites() async {
    final list = await dbHelper.getFavorites();
    int sum = list.fold(0, (prev, p) => prev + p.goals);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('total_goals', sum);

    totalGoals = sum;
    return list;
  }

  void refresh() {
    setState(() {
      loadFuture = loadFavorites();
    });
  }

  void confirmDelete(Player player) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eliminar Favorito"),
        content: Text("¿Eliminar a ${player.name}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await dbHelper.deletePlayer(player.id);
              refresh();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Eliminar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void editGoals(Player player) {
    final controller = TextEditingController(text: player.goals.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Goles de ${player.name}"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Cantidad", // Texto más corto para ahorrar espacio
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              int? newGoals = int.tryParse(controller.text);
              if (newGoals != null) {
                player.goals = newGoals;
                await dbHelper.insertPlayer(player); // INSERT actúa como UPDATE
                refresh();
                Navigator.pop(context);
              }
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Player>>(
      future: loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('Error: ${snapshot.error}')));
        }

        final favorites = snapshot.data ?? [];

        return Scaffold(
          appBar: AppBar(title: const Text("Mis Favoritos")),
          body: Column(
            children: [
              // PANEL TOTALES
              Container(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                color: Colors.indigo.withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text("Jugadores", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("${favorites.length}",
                            style: const TextStyle(fontSize: 22, color: Colors.indigo, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      children: [
                        const Text("Total Goles", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("$totalGoals",
                            style: const TextStyle(fontSize: 22, color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),

              // LISTA
              Expanded(
                child: favorites.isEmpty
                    ? const Center(child: Text("Sin favoritos"))
                    : ListView.builder(
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final player = favorites[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10), // Menos relleno
                        leading: CircleAvatar(
                          radius: 20, // Avatar un poco más pequeño
                          backgroundImage: NetworkImage(player.picture),
                          backgroundColor: Colors.grey[200],
                        ),
                        title: Text(player.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text("Edad: ${player.age}\nGoles: ${player.goals}",
                            style: const TextStyle(fontSize: 12)),
                        isThreeLine: true,

                        // --- SOLUCIÓN DE ESPACIO EXTREMA ---
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min, // Ocupa el mínimo espacio posible
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                              onPressed: () => editGoals(player),
                              padding: EdgeInsets.zero, // Sin relleno interno
                              constraints: const BoxConstraints(), // Sin tamaño mínimo
                              visualDensity: VisualDensity.compact, // Compacto
                            ),
                            const SizedBox(width: 15), // Separación justa
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                              onPressed: () => confirmDelete(player),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}