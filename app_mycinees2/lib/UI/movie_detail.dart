import 'package:flutter/material.dart';
import 'package:app_mycinees2/models/movie.dart';
import 'package:app_mycinees2/utils/db_helper.dart';

class MovieDetail extends StatefulWidget {
  final Movie movie;
  // Usamos const para mejorar rendimiento
  const MovieDetail(this.movie, {super.key});

  @override
  _MovieDetailState createState() => _MovieDetailState();
}

class _MovieDetailState extends State<MovieDetail> {
  late DbHelper dbHelper;
  String path = "";
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    dbHelper = DbHelper();
    // Verificamos si esta película ya es favorita al entrar
    checkFavorite();
  }

  // Consulta a la Base de Datos
  void checkFavorite() async {
    bool result = await dbHelper.isFavorite(widget.movie);
    setState(() {
      isFavorite = result;
    });
  }

  // Acción del botón flotante
  void toggleFavorite() async {
    if (isFavorite) {
      await dbHelper.deleteMovie(widget.movie);
    } else {
      await dbHelper.insertMovie(widget.movie);
    }
    setState(() {
      isFavorite = !isFavorite;
      // Actualizamos el objeto local para que al volver atrás se sepa
      widget.movie.isFavorite = isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    // Lógica de la imagen (igual que la tuya, pero más limpia)
    if (widget.movie.posterPath != null && widget.movie.posterPath!.isNotEmpty) {
      path = 'https://image.tmdb.org/t/p/w500${widget.movie.posterPath}';
    } else {
      path = 'https://upload.wikimedia.org/wikipedia/commons/d/d1/Image_not_available.png';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie.title ?? "Detalle"),
      ),
      // BOTÓN FLOTANTE DE FAVORITOS
      floatingActionButton: FloatingActionButton(
        backgroundColor: isFavorite ? Colors.red : Colors.grey,
        onPressed: toggleFavorite,
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              // 1. IMAGEN CON HERO
              Container(
                padding: const EdgeInsets.all(16),
                child: Hero(
                  tag: 'poster_${widget.movie.id}',
                  child: Image.network(
                    path,
                    height: height / 1.5,
                  ),
                ),
              ),

              // 2. INFORMACIÓN DETALLADA
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título Grande
                    Text(
                      widget.movie.title ?? "",
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),

                    // Fila de Fecha y Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Estreno: ${widget.movie.releaseDate ?? 'Desconocido'}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber),
                            Text(widget.movie.popularity?.toStringAsFixed(1) ?? "0.0"),
                          ],
                        )
                      ],
                    ),
                    const Divider(height: 30),

                    // Sinopsis
                    const Text("Sinopsis", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      widget.movie.overview ?? "No hay descripción disponible.",
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.justify,
                    ),
                    // Espacio al final para que el botón flotante no tape texto
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}