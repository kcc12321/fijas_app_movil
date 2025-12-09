import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../models/country.dart';
import '../utils/db_helper.dart';
import '../utils/http_helper.dart';
import 'country_detail.dart';

// import 'country_detail.dart';

class CountryList extends StatefulWidget {
  const CountryList({super.key});

  @override
  _CountryListState createState() => _CountryListState();
}

class _CountryListState extends State<CountryList> {
  List<Country> countries = [];
  int page = 1;
  bool loading = true;
  List<Country> allCountries = [];
  String currentFilter = "Todos";

  late HttpHelper helper;
  late DbHelper dbHelper; // Necesario para cargar favoritos

  ScrollController? _scrollController;

  // Variables para la Búsqueda
  Icon visibleIcon = const Icon(Icons.search);
  Widget searchBar = const Text('Países');
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
          loadData();
        }
      }
    });
  }

  Future initialize() async {
    // Carga inicial
    loadData();
  }

  // Cargar datos de la API
  void loadData() {
    helper.getCountries().then((value) {
      setState(() {
        countries = value;
        allCountries = value;
        loading = false;
      });
    });
  }

  // Buscar en la API
  void search(String text) async {
    if (text.isEmpty) {
    // Si borran el texto, restauramos la lista original completa
      setState(() {
        countries = List.from(allCountries);
      });
      return;
    }

    final query = text.toLowerCase();

    setState(() {
      countries = allCountries.where((country) {
        // Extraemos los datos del país (asegurando que no sean nulos)
        final name = country.name.toLowerCase();
        final region = country.region.toLowerCase(); // Asegúrate de haber agregado 'region' al modelo Country
        final id = country.id.toLowerCase();

        // CONDICIÓN MÁGICA: ¿Coincide el nombre O la región O el ID?
        return name.contains(query) || region.contains(query) || id.contains(query);
      }).toList();
    });
  }

  // Cargar Favoritos de la Base de Datos Local
  void toggleFavorites() async {
    setState(() {
      showFavorites = !showFavorites; // Invertimos el valor
    });

    if (showFavorites) {
      // Modo Offline/Favoritos: Cargar de SQLite
      List<Country> favcountries = await dbHelper.getFavorites();
      setState(() {
        countries = favcountries;
      });
    } else {
      loadData();
    }
  }

  void applyFilter(String option) {
    setState(() {
      currentFilter = option;
      if (option == "Todos") {
        countries = List.from(allCountries); // Restauramos la lista original
      } else if (option == "Europa") {
        countries = allCountries.where((c) => c.region == "Europe").toList();
      } else if (option == "Africa") {
        countries = allCountries.where((c) => c.region == "Africa").toList();
      } else if (option == "Asia") {
        countries = allCountries.where((c) => c.region == "Asia").toList();
      } else if (option == "Oceania") {
        countries = allCountries.where((c) => c.region == "Oceania").toList();
      } else if (option == "Americas") {
        countries = allCountries.where((c) => c.region == "Americas").toList();
      } else if (option == "Población +") {
        // Ordenar Mayor a Menor
        countries.sort((a, b) => b.population.compareTo(a.population));
      } else if (option == "Población -") {
        // Ordenar Menor a Mayor
        countries.sort((a, b) => a.population.compareTo(b.population));
      }
    });
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
                      style: const TextStyle(color: Colors.black, fontSize: 20.0),
                      onSubmitted: (String text) {
                        isSearching = true;
                        search(text);
                      },
                      decoration: const InputDecoration(
                          hintText: "Buscar un país...",
                          hintStyle: TextStyle(color: Colors.black)
                      ),
                    );
                  } else {
                    setState(() {
                      visibleIcon = const Icon(Icons.search);
                      searchBar = const Text('Países');
                      loadData(); // Resetear lista

                    });
                  }
                });

              },
            ),
          PopupMenuButton<String>(
            onSelected: applyFilter,
            itemBuilder: (BuildContext context) {
              return {'Todos', 'Europa', 'Africa', 'Asia', 'Oceania', 'Americas', 'Población +', 'Población -'}
                  .map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
          // BOTÓN 3: Modo Oscuro (Shared Preferences)
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () async {
              // 1. Obtenemos instancia de SharedPreferences
              final prefs = await SharedPreferences.getInstance();

              // 2. Verificamos el estado actual
              final isDark = themeNotifier.value == ThemeMode.dark;

              // 3. Cambiamos e invertimos
              final newStatus = !isDark;

              // 4. Guardamos en disco
              await prefs.setBool('isDark', newStatus);

              // 5. Actualizamos la app en vivo
              themeNotifier.value = newStatus ? ThemeMode.dark : ThemeMode.light;
            },
          ),
        ],
      ),
      body: loading
      ? const Center(child: CircularProgressIndicator())
      :
      ListView.builder(
        controller: _scrollController,
        itemCount: countries.length,
        itemBuilder: (context, index) {
          return CountryRow(
              countries[index],
                  key: ValueKey(countries[index].id)
          );
        },
      ),
    );
  }
}

// --- WIDGET SEPARADO PARA LA FILA ---

class CountryRow extends StatefulWidget {
  final Country country;
  const CountryRow(this.country, {super.key});

  @override
  _CountryRowState createState() => _CountryRowState();
}

class _CountryRowState extends State<CountryRow> {
  late bool favorite;
  late DbHelper dbHelper;

  @override
  void initState() {
    super.initState();
    favorite = false;
    dbHelper = DbHelper();
    checkFavorite();
  }

  // Verificar si es favorito al iniciar
  Future checkFavorite() async {
    bool result = await dbHelper.isFavorite(widget.country.id);
    if (mounted) {
      setState(() {
        favorite = result;
        widget.country.isFavorite = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {


    return Card(
      color: Colors.white,
      elevation: 2.0,
      child: ListTile(
        leading: Hero(
          tag: 'poster_${widget.country.id}',
          child: Image.network(
            widget.country.flagUrl, // <-- URL directa del modelo
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.public, size: 40),
            fit: BoxFit.cover,
          ), // Usamos la imagen validada
        ),
        title: Text(widget.country.name),
        subtitle: Text(
            widget.country.region
        ),

        trailing: IconButton(
          icon: Icon(Icons.favorite),
          color: favorite ? Colors.red : Colors.grey,
          onPressed: () {
            // Lógica de guardado/borrado
            if (favorite) {
              dbHelper.deleteCountry(widget.country.id);
            } else {
              dbHelper.insertCountry(widget.country);
            }
            setState(() {
              favorite = !favorite;
              widget.country.isFavorite = favorite;
            });
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => CountryDetail(widget.country)
            ),
          ).then((value) {
            checkFavorite();
          });
        },

      ),
    );
  }
}

