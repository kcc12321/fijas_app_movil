import 'package:app_mycinees2/models/movie.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  // CAMBIO 1: Subimos la versión para indicar que la estructura cambió
  final int version = 2;
  Database? db;

  static final DbHelper _dbHelper = DbHelper._internal();

  DbHelper._internal();

  factory DbHelper() {
    return _dbHelper;
  }

  Future<Database> openDb() async {
    if (db == null) {
      db = await openDatabase(join(await getDatabasesPath(), 'movies_v2.db'), // Cambié nombre para asegurar limpieza
          onCreate: (db, version) {
            // CAMBIO 2: ¡Creamos la tabla con TODOS los campos!
            db.execute(
                'CREATE TABLE movies('
                    'id INTEGER PRIMARY KEY, '
                    'title TEXT, '
                    'popularity REAL, '
                    'poster_path TEXT, '
                    'overview TEXT, '
                    'release_date TEXT, '
                    'isFavorite INTEGER)' // Guardamos bool como 1 o 0
            );
          }, version: version);
    }
    return db!;
  }

  Future<int> insertMovie(Movie movie) async {
    // Aseguramos que la DB esté abierta
    final dbClient = await openDb();
    int id = await dbClient.insert('movies', movie.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  Future<bool> isFavorite(Movie movie) async {
    final dbClient = await openDb();
    final List<Map<String, dynamic>> maps =
    await dbClient.query('movies', where: 'id = ?', whereArgs: [movie.id]);
    return maps.isNotEmpty;
  }

  Future<int> deleteMovie(Movie movie) async {
    final dbClient = await openDb();
    int result =
    await dbClient.delete('movies', where: 'id = ?', whereArgs: [movie.id]);
    return result;
  }

  // CAMBIO 3: Nueva función para obtener la LISTA de favoritos (Offline)
  Future<List<Movie>> getFavorites() async {
    final dbClient = await openDb();
    final List<Map<String, dynamic>> maps = await dbClient.query('movies');

    return List.generate(maps.length, (i) {
      return Movie(
        id: maps[i]['id'],
        title: maps[i]['title'],
        popularity: maps[i]['popularity'],
        posterPath: maps[i]['poster_path'],
        overview: maps[i]['overview'],
        releaseDate: maps[i]['release_date'],
        // Convertimos el 1 o 0 de SQLite a true/false
        isFavorite: maps[i]['isFavorite'] == 1,
      );
    });
  }
}