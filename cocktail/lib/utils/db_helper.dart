import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/cocktail.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  factory DbHelper() => _instance;
  DbHelper._internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'bar_manager_v1.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute(
            'CREATE TABLE cocktails('
                'id TEXT PRIMARY KEY, ' // ID es texto en esta API
                'name TEXT, '
                'image TEXT, '
                'category TEXT, '
                'instructions TEXT, '
                'ingredients TEXT)'
        );
      },
    );
  }

  // Guardar (Si existe, actualiza)
  Future<int> insert(Cocktail cocktail) async {
    final dbClient = await db;
    return await dbClient.insert(
      'cocktails',
      cocktail.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Eliminar
  Future<int> delete(String id) async {
    final dbClient = await db;
    return await dbClient.delete('cocktails', where: 'id = ?', whereArgs: [id]);
  }

  // Verificar si es favorito (para pintar el corazón)
  Future<bool> isFavorite(String id) async {
    final dbClient = await db;
    final list = await dbClient.query('cocktails', where: 'id = ?', whereArgs: [id]);
    return list.isNotEmpty;
  }

  // Obtener todos (Modo Offline)
  Future<List<Cocktail>> getFavorites() async {
    final dbClient = await db;
    final list = await dbClient.query('cocktails');
    return list.map((c) => Cocktail.fromMap(c)).toList();
  }
}