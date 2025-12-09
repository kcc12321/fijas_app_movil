import '../models/player.dart';
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
    db ??= await openDatabase(join(await getDatabasesPath(), 'player_v3.db'), // Cambié nombre para asegurar limpieza
        onCreate: (db, version) {
          // CAMBIO 2: ¡Creamos la tabla con TODOS los campos!
          db.execute(
              'CREATE TABLE players('
                  'id INTEGER PRIMARY KEY, '
                  'name TEXT, '
                  'country TEXT, '
                  'age INTEGER, '
                  'position TEXT, '
                  'team TEXT,'
                  'placeOfBirth TEXT,'
                  'goals INTEGER,'
                  'number INTEGER,'
                  'picture TEXT,'
                  'isFavorite INTEGER)'
          );
        }, version: version);
    return db!;
  }

  Future<int> insertPlayer(Player player) async {
    // Aseguramos que la DB esté abierta
    final dbClient = await openDb();
    int id = await dbClient.insert('players', player.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  Future<bool> isFavorite(int playerId) async {
    final dbClient = await openDb();
    final List<Map<String, dynamic>> maps =
    await dbClient.query('players', where: 'id = ?', whereArgs: [playerId]);
    return maps.isNotEmpty;
  }

  Future<int> deletePlayer(int playerId) async {
    final dbClient = await openDb();
    int result =
    await dbClient.delete('players', where: 'id = ?', whereArgs: [playerId]);
    return result;
  }

  // CAMBIO 3: Nueva función para obtener la LISTA de favoritos (Offline)
  Future<List<Player>> getFavorites() async {
    final dbClient = await openDb();
    final List<Map<String, dynamic>> maps = await dbClient.query('players');

    return List.generate(maps.length, (i) {
      return Player.fromMap(maps[i]); // Usamos el factory que creamos en el modelo para limpiar código
    });
  }


  Future<int> updatePlayer(Player player) async {
    final dbClient = await openDb();
    return await dbClient.update(
      'players',
      player.toMap(),
      where: 'id = ?',
      whereArgs: [player.id],
    );
  }
}