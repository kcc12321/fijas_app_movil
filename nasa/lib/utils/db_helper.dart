import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/apod_item.dart';

class DbHelper {
  final int version = 1;
  Database? db;

  static final DbHelper _dbHelper = DbHelper._internal();
  DbHelper._internal();
  factory DbHelper() => _dbHelper;

  Future<Database> openDb() async {
    db ??= await openDatabase(
      join(await getDatabasesPath(), 'nasa_apod_final.db'),
      version: version,
      onCreate: (db, version) {
        db.execute(
            'CREATE TABLE favorites('
                'date TEXT PRIMARY KEY, ' // La fecha es única
                'title TEXT, '
                'explanation TEXT, '
                'url TEXT, '
                'copyright TEXT)'
        );
      },
    );
    return db!;
  }

  // Insertar (Si existe, reemplaza)
  Future<int> insertFavorite(ApodItem item) async {
    final dbClient = await openDb();
    return await dbClient.insert(
        'favorites',
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  // Eliminar por fecha
  Future<int> deleteFavorite(String date) async {
    final dbClient = await openDb();
    return await dbClient.delete('favorites', where: 'date = ?', whereArgs: [date]);
  }

  // Verificar si existe (para pintar el ícono)
  Future<bool> isFavorite(String date) async {
    final dbClient = await openDb();
    final List<Map<String, dynamic>> maps =
    await dbClient.query('favorites', where: 'date = ?', whereArgs: [date]);
    return maps.isNotEmpty;
  }

  // Listar todos
  Future<List<ApodItem>> getFavorites() async {
    final dbClient = await openDb();
    final List<Map<String, dynamic>> maps = await dbClient.query('favorites');
    return List.generate(maps.length, (i) => ApodItem.fromMap(maps[i]));
  }
}