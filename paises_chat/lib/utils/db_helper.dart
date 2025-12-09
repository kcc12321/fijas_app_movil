import '../models/country.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  final int version = 1;
  Database? db;

  static final DbHelper _dbHelper = DbHelper._internal();

  DbHelper._internal();

  factory DbHelper() {
    return _dbHelper;
  }

  Future<Database> openDb() async {
    db ??= await openDatabase(join(await getDatabasesPath(), 'countries_v2.db'), // Cambié nombre para asegurar limpieza
          onCreate: (db, version) {
            // CAMBIO 2: ¡Creamos la tabla con TODOS los campos!
            db.execute(
                'CREATE TABLE countries('
                    'id TEXT PRIMARY KEY, '
                    'name TEXT, '
                    'capital TEXT, '
                    'flagUrl TEXT, '
                    'population INTEGER, '
                    'isFavorite INTEGER,'
                    'region TEXT,'
                    'latlng TEXT)' // Guardamos bool como 1 o 0
            );
          }, version: version);
    return db!;
  }

  Future<int> insertCountry(Country country) async {
    // Aseguramos que la DB esté abierta
    final dbClient = await openDb();
    int id = await dbClient.insert('countries', country.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  Future<bool> isFavorite(String countryId) async {
    final dbClient = await openDb();
    final List<Map<String, dynamic>> maps =
    await dbClient.query('countries', where: 'id = ?', whereArgs: [countryId]);
    return maps.isNotEmpty;
  }

  Future<int> deleteCountry(String countryId) async {
    final dbClient = await openDb();
    int result =
    await dbClient.delete('countries', where: 'id = ?', whereArgs: [countryId]);
    return result;
  }

  // CAMBIO 3: Nueva función para obtener la LISTA de favoritos (Offline)
  Future<List<Country>> getFavorites() async {
    final dbClient = await openDb();
    final List<Map<String, dynamic>> maps = await dbClient.query('countries');

    return List.generate(maps.length, (i) {
      return Country(
        id: maps[i]['id'],
        name: maps[i]['name'],
        capital: maps[i]['capital'],
        flagUrl: maps[i]['flagUrl'],
        population: maps[i]['population'],
        // Convertimos el 1 o 0 de SQLite a true/false
        isFavorite: maps[i]['isFavorite'] == 1,
        region: maps[i]['region'],
        latlng: maps[i]['latlng']
      );
    });
  }
}