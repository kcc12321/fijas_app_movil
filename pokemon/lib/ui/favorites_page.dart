import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../util/db_helper.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Pokemon> myTeam = [];
  bool loading = true;
  int totalWeight = 0; // Variable para el cálculo
  DbHelper dbHelper = DbHelper();

  @override
  void initState() {
    super.initState();
    _loadTeam();
  }

  void _loadTeam() async {
    // 1. Cargar de SQLite
    List<Pokemon> list = await dbHelper.getTeam();

    // 2. CALCULAR PESO TOTAL (Requerimiento)
    int sum = 0;
    for (var p in list) {
      sum += p.weight;
    }

    if (mounted) {
      setState(() {
        myTeam = list;
        totalWeight = sum;
        loading = false;
      });
    }
  }

  void _releasePokemon(int id) async {
    await dbHelper.deletePokemon(id);
    _loadTeam(); // Recargar para actualizar lista y resta del peso
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mi Equipo Pokémon")),
      body: Column(
        children: [
          // PANEL DE ESTADÍSTICAS
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.red[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text("Miembros", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("${myTeam.length}", style: const TextStyle(fontSize: 22, color: Colors.red)),
                  ],
                ),
                Column(
                  children: [
                    const Text("Peso Total", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("$totalWeight hg", style: const TextStyle(fontSize: 22, color: Colors.blue)),
                  ],
                ),
              ],
            ),
          ),

          // LISTA
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : myTeam.isEmpty
                ? const Center(child: Text("Tu equipo está vacío"))
                : ListView.builder(
              itemCount: myTeam.length,
              itemBuilder: (context, index) {
                final poke = myTeam[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: Image.network(poke.image, width: 50),
                    title: Text(poke.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Tipo: ${poke.types} | Peso: ${poke.weight}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _releasePokemon(poke.id),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}