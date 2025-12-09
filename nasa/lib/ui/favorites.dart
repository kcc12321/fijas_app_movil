import 'package:flutter/material.dart';
import '../models/apod_item.dart';
import '../utils/db_helper.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<ApodItem> favorites = [];
  DbHelper dbHelper = DbHelper();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final result = await dbHelper.getFavorites();
    setState(() {
      favorites = result;
    });
  }

  void deleteItem(String date) async {
    await dbHelper.deleteFavorite(date);
    loadData(); // Recargar lista
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Eliminado 🗑️"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mis Favoritos (Offline)")),
      body: favorites.isEmpty
          ? const Center(child: Text("No tienes favoritos guardados"))
          : ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final item = favorites[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: Column(
              children: [
                // IMAGEN PEQUEÑA (ListTile)
                ListTile(
                  leading: Image.network(
                    item.url,
                    width: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_,__,___) => const Icon(Icons.image),
                  ),
                  // ATRIBUTO 1: TÍTULO (Necesario para identificar)
                  title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),

                  // BOTÓN ELIMINAR
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteItem(item.date),
                  ),
                ),

                // ATRIBUTO 2 (DIFERENTE): EXPLICACIÓN
                // El examen pide atributos distintos a la pantalla anterior.
                // Aquí mostramos el texto descriptivo que no mostramos en la lista.
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    item.explanation,
                    maxLines: 3, // Cortamos a 3 líneas para que no sea gigante
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}