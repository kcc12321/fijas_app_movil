import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/pokemon.dart';

class DbHelper {
  final int version = 1;
  Database? db;

  // Patrón Singleton (Solo una conexión a la vez)
  static final DbHelper _dbHelper = DbHelper._internal();
  DbHelper._internal();
  factory DbHelper() => _dbHelper;

  Future<Database> openDb() async {
    // Usamos un nombre nuevo para evitar conflictos con exámenes anteriores
    db ??= await openDatabase(
        join(await getDatabasesPath(), 'pokedex_regional_v1.db'),
        onCreate: (db, version) {
          // Creamos la tabla 'team' (Tu equipo Pokémon)
          db.execute(
              'CREATE TABLE team('
                  'id INTEGER PRIMARY KEY, ' // El ID de la Pokedex es único
                  'name TEXT, '
                  'image TEXT, '
                  'types TEXT, '
                  'weight INTEGER, '
                  'height INTEGER)'
          );
        },
        version: version,
      );
    return db!;
  }

  // 1. CAPTURAR (Insertar)
  Future<int> insertPokemon(Pokemon pokemon) async {
    final dbClient = await openDb();
    // Usamos replace: Si capturas al mismo dos veces, actualiza sus datos
    return await dbClient.insert(
      'team',
      pokemon.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 2. LIBERAR (Eliminar)
  Future<int> deletePokemon(int id) async {
    final dbClient = await openDb();
    return await dbClient.delete('team', where: 'id = ?', whereArgs: [id]);
  }

  // 3. ¿ESTÁ CAPTURADO? (Verificar para pintar la Pokebola)
  Future<bool> isCaptured(int id) async {
    final dbClient = await openDb();
    final list = await dbClient.query('team', where: 'id = ?', whereArgs: [id]);
    return list.isNotEmpty;
  }

  // 4. VER MI EQUIPO (Listar todos)
  Future<List<Pokemon>> getTeam() async {
    final dbClient = await openDb();
    final list = await dbClient.query('team');
    return list.map((map) => Pokemon.fromMap(map)).toList();
  }
}