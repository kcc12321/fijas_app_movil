import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cocktail.dart';
import 'login_page.dart';
import '../utils/http_helper.dart';
import 'cocktail_detail.dart'; // Crearemos este en el siguiente paso
import '../utils/db_helper.dart';
import 'favorites_page.dart'; // Crearemos este al final

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Cocktail> drinks = [];
  bool loading = true;
  HttpHelper httpHelper = HttpHelper();

  // Controladores para búsqueda
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  // Carga por defecto (Categoría Cocktail)
  void loadInitialData() async {
    setState(() => loading = true);
    // Usamos el método de filtrar por categoría que creamos en HttpHelper
    List<Cocktail> result = await httpHelper.getCocktailsByCategory();
    setState(() {
      drinks = result;
      loading = false;
    });
  }

  // Búsqueda por nombre
  void search() async {
    String query = searchController.text;
    if (query.isEmpty) {
      loadInitialData(); // Si borran, volvemos al inicio
      return;
    }

    setState(() => loading = true);
    List<Cocktail> result = await httpHelper.searchCocktail(query);
    setState(() {
      drinks = result;
      loading = false;
    });
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage())
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BarManager 🍸"),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.redAccent),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesPage()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),
      body: Column(
        children: [
          // BARRA DE BÚSQUEDA
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Buscar trago (ej: Margarita)",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    loadInitialData();
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onSubmitted: (_) => search(), // Buscar al dar Enter
            ),
          ),

          // LISTA DE RESULTADOS
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : drinks.isEmpty
                ? const Center(child: Text("No se encontraron bebidas"))
                : ListView.builder(
              itemCount: drinks.length,
              itemBuilder: (context, index) {
                return CocktailRow(
                      cocktail: drinks[index],
                      key: ValueKey(drinks[index].id), 
                    );
              },
            ),
          ),
        ],
      ),
    );
  }
}


class CocktailRow extends StatefulWidget {
  final Cocktail cocktail;
  const CocktailRow({super.key, required this.cocktail});

  @override
  State<CocktailRow> createState() => _CocktailRowState();
}

class _CocktailRowState extends State<CocktailRow> {
  bool isFavorite = false;
  DbHelper dbHelper = DbHelper();

  @override
  void initState() {
    super.initState();
    checkFavorite();
  }

  void checkFavorite() async {
    bool fav = await dbHelper.isFavorite(widget.cocktail.id);
    if (mounted) setState(() => isFavorite = fav);
  }

  void toggleFavorite() async {
    if (isFavorite) {
      await dbHelper.delete(widget.cocktail.id);
    } else {
      await dbHelper.insert(widget.cocktail);
    }
    if (mounted) setState(() => isFavorite = !isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.network(widget.cocktail.image, width: 50),
        title: Text(widget.cocktail.name),
        
        // AQUÍ ESTÁ EL BOTÓN EN LA LISTA
        trailing: IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.grey,
          ),
          onPressed: toggleFavorite,
        ),
        
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CocktailDetail(widget.cocktail))
          ).then((_) => checkFavorite()); // Al volver, actualizamos por si cambió en el detalle
        },
      ),
    );
  }
}