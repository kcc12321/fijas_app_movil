import 'package:flutter/material.dart';
import '../models/cocktail.dart';
import '../utils/db_helper.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Cocktail> favorites = [];
  bool loading = true;
  DbHelper dbHelper = DbHelper();

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  // Cargar datos de SQLite (Funciona sin internet)
  void loadFavorites() async {
    List<Cocktail> result = await dbHelper.getFavorites();
    if (mounted) {
      setState(() {
        favorites = result;
        loading = false;
      });
    }
  }

  // Eliminar de la BD y refrescar lista
  void deleteFavorite(String id) async {
    await dbHelper.delete(id);
    loadFavorites(); // Recargamos para que desaparezca visualmente

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Eliminado de mis recetas"),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 1),
          )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mis Recetas (Offline)")),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
          : favorites.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.no_drinks, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text("Aún no tienes recetas guardadas",
                style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final drink = favorites[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ExpansionTile(
              // Usamos ExpansionTile para ver detalles rápidos sin cambiar de pantalla
              leading: CircleAvatar(
                backgroundImage: NetworkImage(drink.image),
                backgroundColor: Colors.grey[200],
              ),
              title: Text(drink.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(drink.category),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => deleteFavorite(drink.id),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Ingredientes:", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(drink.ingredients),
                      const SizedBox(height: 10),
                      const Text("Instrucciones:", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(drink.instructions),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}