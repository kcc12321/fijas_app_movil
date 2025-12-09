import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../util/db_helper.dart';
import '../util/http_helper.dart';

class PokemonDetail extends StatefulWidget {
  final Pokemon pokemon;
  const PokemonDetail(this.pokemon, {super.key});

  @override
  State<PokemonDetail> createState() => _PokemonDetailState();
}

class _PokemonDetailState extends State<PokemonDetail> {
  late Pokemon pokemon;
  bool loading = true;
  bool isCaptured = false;

  HttpHelper httpHelper = HttpHelper();
  DbHelper dbHelper = DbHelper();

  @override
  void initState() {
    super.initState();
    pokemon = widget.pokemon;
    _initializeData();
  }

  void _initializeData() async {
    // 1. Verificar si ya lo tenemos capturado en la BD
    bool captured = await dbHelper.isCaptured(pokemon.id);

    // 2. Si viene de la lista, le faltan datos (peso, tipos). Los descargamos.
    // Usamos el ID para pedir el detalle completo a la API.
    Pokemon? fullData = await httpHelper.getPokemonDetail(pokemon.id.toString());

    if (mounted) {
      setState(() {
        isCaptured = captured;
        if (fullData != null) {
          pokemon = fullData; // Actualizamos con la info completa
        }
        loading = false;
      });
    }
  }

  void _toggleCapture() async {
    if (isCaptured) {
      await dbHelper.deletePokemon(pokemon.id);
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pokémon liberado 🍃")));
    } else {
      await dbHelper.insertPokemon(pokemon);
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("¡Pokémon capturado! 🔴⚪")));
    }

    if (mounted) {
      setState(() {
        isCaptured = !isCaptured;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(pokemon.name.toUpperCase())),

      // BOTÓN FLOTANTE (POKEBOLA)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: loading ? null : _toggleCapture,
        backgroundColor: isCaptured ? Colors.red : Colors.blue,
        icon: const Icon(Icons.catching_pokemon, color: Colors.white),
        label: Text(isCaptured ? "LIBERAR" : "CAPTURAR", style: const TextStyle(color: Colors.white)),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            // 1. IMAGEN GRANDE CON FONDO
            Container(
              width: double.infinity,
              height: 250,
              color: Colors.grey[200],
              child: Hero(
                tag: pokemon.id,
                child: Image.network(
                  pokemon.image,
                  fit: BoxFit.contain,
                  errorBuilder: (_,__,___) => const Icon(Icons.broken_image, size: 80),
                ),
              ),
            ),

            // 2. DATOS
            Padding(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(pokemon.name.toUpperCase(),
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const Divider(),

                      // TIPOS
                      const Text("Tipos", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 5),
                      Wrap(
                        spacing: 8,
                        children: pokemon.types.split(', ').map((type) => Chip(
                          label: Text(type.toUpperCase()),
                          backgroundColor: Colors.redAccent.withOpacity(0.1),
                        )).toList(),
                      ),
                      const Divider(),

                      // PESO Y ALTURA
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem("Peso", "${pokemon.weight} hg", Icons.monitor_weight),
                          _buildStatItem("Altura", "${pokemon.height} dm", Icons.height),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.redAccent, size: 30),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}