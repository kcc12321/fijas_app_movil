import 'package:flutter/material.dart';
import 'package:pokemon/ui/pokemon_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pokemon.dart';
import '../util/http_helper.dart';
import 'favorites_page.dart';
import 'login_page.dart';
// import 'pokemon_detail.dart'; // PRÓXIMO PASO
// import 'favorites_page.dart'; // PRÓXIMO PASO

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Pokemon> pokemonList = [];
  bool loading = true;
  HttpHelper httpHelper = HttpHelper();
  String trainerName = "Entrenador";

  // Controladores de búsqueda
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getTrainerName();
    getData();
  }

  void getTrainerName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      trainerName = prefs.getString('trainer_name') ?? "Entrenador";
    });
  }

  // 1. Cargar lista inicial (20 pokemones)
  void getData() async {
    setState(() => loading = true);
    final result = await httpHelper.getPokemonList();
    setState(() {
      pokemonList = result;
      loading = false;
    });
  }

  // 2. Buscar por nombre exacto (ej: "mew")
  void search() async {
    String query = searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      getData(); // Si borran, recargamos la lista
      return;
    }

    setState(() => loading = true);
    // Buscamos el detalle directamente
    final result = await httpHelper.getPokemonDetail(query);

    setState(() {
      loading = false;
      if (result != null) {
        pokemonList = [result]; // Mostramos solo ese resultado en la lista
      } else {
        pokemonList = []; // Lista vacía si no encuentra
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Pokémon no encontrado"))
        );
      }
    });
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pokedex de $trainerName"),
        actions: [
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesPage()));
            },
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: logout),
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
                hintText: "Buscar Pokémon (ej: pikachu)",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    getData();
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onSubmitted: (_) => search(),
            ),
          ),

          // LISTADO
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : pokemonList.isEmpty
                ? const Center(child: Text("No hay datos"))
                : ListView.builder(
              itemCount: pokemonList.length,
              itemBuilder: (context, index) {
                final poke = pokemonList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: Image.network(
                      poke.image,
                      width: 60,
                      height: 60,
                      errorBuilder: (_,__,___) => const Icon(Icons.help),
                    ),
                    title: Text(
                        poke.name.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold)
                    ),
                    subtitle: Text("#${poke.id}"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // NAVEGACIÓN AL DETALLE
                       Navigator.push(context, MaterialPageRoute(builder: (_) => PokemonDetail(poke)));
                    },
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