import 'package:flutter/material.dart';
import '../models/cocktail.dart';
import '../utils/http_helper.dart';
import '../utils/db_helper.dart';

class CocktailDetail extends StatefulWidget {
  final Cocktail cocktail;
  const CocktailDetail(this.cocktail, {super.key});

  @override
  State<CocktailDetail> createState() => _CocktailDetailState();
}

class _CocktailDetailState extends State<CocktailDetail> {
  late Cocktail cocktail;
  bool loading = true;
  bool isFavorite = false;

  HttpHelper httpHelper = HttpHelper();
  DbHelper dbHelper = DbHelper();

  @override
  void initState() {
    super.initState();
    cocktail = widget.cocktail;

    // 1. Verificar si ya es favorito en la BD
    _checkFavorite();

    // 2. Descargar los detalles completos (Ingredientes e Instrucciones)
    _loadFullDetails();
  }

  void _checkFavorite() async {
    bool fav = await dbHelper.isFavorite(cocktail.id);
    if(mounted) setState(() => isFavorite = fav);
  }

  void _loadFullDetails() async {
    // Si viene de la lista, tiene datos por defecto ("Mezclar y servir").
    // Buscamos la info real en la API.
    Cocktail? fullCocktail = await httpHelper.getCocktailById(cocktail.id);

    if (fullCocktail != null && mounted) {
      setState(() {
        cocktail = fullCocktail; // ¡Aquí reemplazamos el objeto incompleto por el completo!
        loading = false;
      });
    } else {
      if(mounted) setState(() => loading = false);
    }
  }

  void _toggleFavorite() async {
    if (isFavorite) {
      await dbHelper.delete(cocktail.id);
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Eliminado de mis recetas")));
    } else {
      await dbHelper.insert(cocktail);
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Guardado en mis recetas ❤️")));
    }
    if(mounted) setState(() => isFavorite = !isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usamos CustomScrollView para un efecto visual de "App Moderna" con la imagen
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true, // La barra se queda fija al bajar
            flexibleSpace: FlexibleSpaceBar(
              title: Text(cocktail.name,
                  style: const TextStyle(
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                  )),
              background: Hero(
                tag: cocktail.id,
                child: Image.network(
                  cocktail.image,
                  fit: BoxFit.cover,
                  errorBuilder: (_,__,___) => Container(color: Colors.grey),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (loading) const LinearProgressIndicator(color: Colors.deepOrange),
                  const SizedBox(height: 10),

                  // Categoría
                  Chip(
                    label: Text(cocktail.category),
                    backgroundColor: Colors.deepOrange.withOpacity(0.1),
                    labelStyle: const TextStyle(color: Colors.deepOrange),
                  ),
                  const Divider(height: 30),

                  // Ingredientes
                  const Text("Ingredientes:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                      cocktail.ingredients.isEmpty ? "Cargando ingredientes..." : cocktail.ingredients,
                      style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87)
                  ),
                  const Divider(height: 30),

                  // Instrucciones
                  const Text("Preparación:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                      cocktail.instructions,
                      style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87)
                  ),

                  const SizedBox(height: 80), // Espacio para el botón flotante
                ],
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toggleFavorite,
        backgroundColor: isFavorite ? Colors.red : Colors.grey[800],
        icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.white),
        label: Text(isFavorite ? "Guardado" : "Guardar Receta", style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}