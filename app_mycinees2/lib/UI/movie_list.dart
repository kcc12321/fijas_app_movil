import 'package:flutter/material.dart';
import 'package:app_mycinees2/utils/db_helper.dart';
import 'package:app_mycinees2/utils/http_helper.dart';
import 'package:app_mycinees2/models/movie.dart';
import 'package:app_mycinees2/UI/movie_detail.dart';

class MovieList extends StatefulWidget {
  const MovieList({super.key});

  @override
  _MovieListState createState() => _MovieListState();
}

class _MovieListState extends State<MovieList> {
  List<Movie> movies = [];
  int page = 1;
  bool loading = true;

  late HttpHelper helper;
  late DbHelper dbHelper; // Necesario para cargar favoritos

  ScrollController? _scrollController;

  // Variables para la Búsqueda
  Icon visibleIcon = const Icon(Icons.search);
  Widget searchBar = const Text('Películas');
  bool isSearching = false;

  // Variable para alternar vistas (API vs Favoritos)
  bool showFavorites = false;

  @override
  void initState() {
    super.initState();
    helper = HttpHelper();
    dbHelper = DbHelper(); // Inicializamos DB
    initialize();

    // Configuración del scroll infinito
    _scrollController = ScrollController();
    _scrollController!.addListener(() {
      if (_scrollController!.position.pixels ==
          _scrollController!.position.maxScrollExtent) {
        // Solo cargamos más si NO estamos en modo favoritos ni buscando
        if (!showFavorites && !isSearching) {
          loadMore();
        }
      }
    });
  }

  Future initialize() async {
    // Carga inicial
    loadMore();
  }

  // Cargar datos de la API
  void loadMore() {
    helper.getUpcoming(page.toString()).then((value) {
      setState(() {
        movies += value;
        page++;
      });
    });
  }

  // Buscar en la API
  void search(String text) async {
    if (text.isEmpty) {
      setState(() {
        movies.clear();
        page = 1;
      });
      loadMore();
      return;
    }

    List<Movie> result = await helper.findMovies(text);
    setState(() {
      movies = result; // Reemplazamos la lista con los resultados
    });
  }

  // Cargar Favoritos de la Base de Datos Local
  void toggleFavorites() async {
    setState(() {
      showFavorites = !showFavorites; // Invertimos el valor
    });

    if (showFavorites) {
      // Modo Offline/Favoritos: Cargar de SQLite
      List<Movie> localMovies = await dbHelper.getFavorites();
      setState(() {
        movies = localMovies;
      });
    } else {
      // Volver a modo Online: Reiniciar y cargar de API
      setState(() {
        movies.clear();
        page = 1;
      });
      loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: searchBar,
        actions: <Widget>[
          // BOTÓN 1: Cambiar entre Favoritos y API
          IconButton(
            icon: Icon(showFavorites ? Icons.cloud_off : Icons.favorite),
            tooltip: showFavorites ? "Ver Todo" : "Ver Favoritos",
            onPressed: () {
              toggleFavorites();
            },
          ),
          // BOTÓN 2: Búsqueda (Solo visible si no estamos en favoritos)
          if (!showFavorites)
            IconButton(
              icon: visibleIcon,
              onPressed: () {
                setState(() {
                  if (visibleIcon.icon == Icons.search) {
                    visibleIcon = const Icon(Icons.cancel);
                    searchBar = TextField(
                      textInputAction: TextInputAction.search,
                      style: const TextStyle(color: Colors.white, fontSize: 20.0),
                      onSubmitted: (String text) {
                        isSearching = true;
                        search(text);
                      },
                      decoration: const InputDecoration(
                          hintText: "Buscar película...",
                          hintStyle: TextStyle(color: Colors.white)
                      ),
                    );
                  } else {
                    setState(() {
                      visibleIcon = const Icon(Icons.search);
                      searchBar = const Text('Películas');
                      isSearching = false;
                      movies.clear();
                      page = 1;
                      loadMore();
                    });
                  }
                });
              },
            ),
        ],
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: movies.length,
        itemBuilder: (BuildContext context, int index) {
          return MovieRow(movies[index]);
        },
      ),
    );
  }
}

// --- WIDGET SEPARADO PARA LA FILA ---

class MovieRow extends StatefulWidget {
  final Movie movie;
  const MovieRow(this.movie, {super.key});

  @override
  _MovieRowState createState() => _MovieRowState();
}

class _MovieRowState extends State<MovieRow> {
  late bool favorite;
  late DbHelper dbHelper;

  @override
  void initState() {
    super.initState();
    favorite = false;
    dbHelper = DbHelper();
    isFavorite();
  }

  // Verificar si es favorito al iniciar
  Future isFavorite() async {
    // SQLite guarda 1 o 0, pero tu función devuelve bool, así que estamos bien
    bool result = await dbHelper.isFavorite(widget.movie);
    setState(() {
      favorite = result;
      widget.movie.isFavorite = result; // Sincronizamos el objeto
    });
  }

  @override
  Widget build(BuildContext context) {
    // Validamos imagen para evitar crash
    final imageWidget = (widget.movie.posterPath != null)
        ? Image.network(
      'https://image.tmdb.org/t/p/w500${widget.movie.posterPath}',
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50),
    )
        : const Icon(Icons.movie, size: 50);

    return Card(
      color: Colors.white,
      elevation: 2.0,
      child: ListTile(
        leading: Hero(
          tag: 'poster_${widget.movie.id}',
          child: imageWidget, // Usamos la imagen validada
        ),
        title: Text(widget.movie.title ?? "Sin título"),
        subtitle: Text(
            widget.movie.overview != null && widget.movie.overview!.length > 50
                ? "${widget.movie.overview!.substring(0, 50)}..." // Cortar texto largo
                : widget.movie.overview ?? "Sin descripción"
        ),
        onTap: () {
          // Navegar al detalle (Debe existir movie_detail.dart)
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => MovieDetail(widget.movie)
            ),
          ).then((value) {
            // Al volver, verificamos si cambió el estado de favorito
            isFavorite();
          });
        },
        trailing: IconButton(
          icon: Icon(Icons.favorite),
          color: favorite ? Colors.red : Colors.grey,
          onPressed: () {
            // Lógica de guardado/borrado
            if (favorite) {
              dbHelper.deleteMovie(widget.movie);
            } else {
              dbHelper.insertMovie(widget.movie);
            }
            setState(() {
              favorite = !favorite;
              widget.movie.isFavorite = favorite;
            });
          },
        ),
      ),
    );
  }
}