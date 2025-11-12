import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import '../models/pokemon.dart';
import '../models/user.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  static const String _dbName = "pokedex_db.db";

  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _dbName);
    final exists = await databaseExists(path);

    final db = await openDatabase(path);
    if (!exists) {
      await _createDb(db);
    }
    return db;
  }

  Future<void> _createDb(Database db) async {
    await db.execute('''
      CREATE TABLE pokemons(
        pokedexNum INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        generation TEXT NOT NULL,
        pkmType TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE user_pokemons(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        pokedexNum INTEGER,
        FOREIGN KEY (userId) REFERENCES users(id),
        FOREIGN KEY (pokedexNum) REFERENCES pokemons(pokedexNum)
      )
    ''');

    await db.execute('''
      CREATE TABLE teams(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        pokedexNum INTEGER,
        captureId INTEGER UNIQUE,
        FOREIGN KEY (userId) REFERENCES users(id),
        FOREIGN KEY (pokedexNum) REFERENCES pokemons(pokedexNum),
        FOREIGN KEY (captureId) REFERENCES user_pokemons(id)
      )
    ''');
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  String _normalizePassword(String password) {
    final isHashed = RegExp(r'^[a-f0-9]{64}$').hasMatch(password);
    return isHashed ? password : _hashPassword(password);
  }

  Future<List<User>> getUsers() async {
    final db = await database;
    final result = await db.query('users', orderBy: 'id ASC');
    return result.isNotEmpty ? result.map(User.fromMap).toList() : [];
  }

  Future<int> addUser(User user) async {
    final db = await database;
    final userMap = user.toMap()..['password'] = _normalizePassword(user.password);
    return await db.insert('users', userMap);
  }

  Future<User?> loginUser(String email, String password) async {
    final db = await database;
    final res = await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (res.isNotEmpty) {
      final user = User.fromMap(res.first);
      final hashedInput = _hashPassword(password);
      if (hashedInput == user.password) return user;
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    final updated = user.toMap()..['password'] = _normalizePassword(user.password);
    return db.update('users', updated, where: 'id = ?', whereArgs: [user.id]);
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty ? User.fromMap(maps.first) : null;
  }

  Future<int> addPokemon(Pokemon newPokemon) async {
    final db = await database;
    final existing = await db.query(
      'pokemons',
      where: 'pokedexNum = ?',
      whereArgs: [newPokemon.pokedexNum],
    );
    if (existing.isNotEmpty) return existing.first['pokedexNum'] as int;
    return await db.insert('pokemons', newPokemon.toMap());
  }

  Future<void> capturePokemon(int userId, Pokemon pokemon) async {
    final db = await database;
    await addPokemon(pokemon);
    await db.insert('user_pokemons', {
      'userId': userId,
      'pokedexNum': pokemon.pokedexNum,
    });
  }

  Future<void> saveAllPokemons(List<Pokemon> pokemons) async {
    final db = await database;
    final batch = db.batch();
    for (final pokemon in pokemons) {
      batch.insert(
        'pokemons',
        pokemon.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit();
  }

  Future<List<Pokemon>> _mapPokemonQuery(String sql, [List<Object?>? args]) async {
    final db = await database;
    final result = await db.rawQuery(sql, args);
    return result.map(Pokemon.fromMap).toList();
  }

  Future<List<Pokemon>> getAllPokemonsFromDB() =>
      _mapPokemonQuery('SELECT * FROM pokemons ORDER BY pokedexNum ASC');

  Future<List<Pokemon>> getUserPokemons(int userId) =>
      _mapPokemonQuery('''
        SELECT p.pokedexNum, p.name, p.imageUrl, p.generation, p.pkmType, up.id
        FROM pokemons p
        INNER JOIN user_pokemons up ON up.pokedexNum = p.pokedexNum
        LEFT JOIN teams t ON t.captureId = up.id AND t.userId = up.userId
        WHERE up.userId = ? AND t.id IS NULL
      ''', [userId]);

  Future<void> deleteUserPokemon(int captureId) async {
    final db = await database;
    await db.delete('user_pokemons', where: 'id = ?', whereArgs: [captureId]);
  }

  Future<void> addPokemonToTeam(int userId, int captureId) async {
    final db = await database;
    await db.transaction((txn) async {
      final count = Sqflite.firstIntValue(await txn.rawQuery(
        'SELECT COUNT(*) FROM teams WHERE userId = ?', [userId])) ?? 0;
      if (count >= 6) return;

      final existing = await txn.query(
        'teams',
        where: 'userId = ? AND captureId = ?',
        whereArgs: [userId, captureId],
      );
      if (existing.isNotEmpty) return;

      final pokemonData = await txn.query(
        'user_pokemons',
        columns: ['pokedexNum'],
        where: 'id = ?',
        whereArgs: [captureId],
      );
      if (pokemonData.isEmpty) return;

      await txn.insert('teams', {
        'userId': userId,
        'pokedexNum': pokemonData.first['pokedexNum'],
        'captureId': captureId,
      });
    });
  }

  Future<List<Pokemon>> getUserTeam(int userId) =>
      _mapPokemonQuery('''
        SELECT p.pokedexNum, p.name, p.imageUrl, p.generation, p.pkmType, t.id
        FROM pokemons p
        INNER JOIN teams t ON t.pokedexNum = p.pokedexNum
        WHERE t.userId = ?
      ''', [userId]);

  Future<void> removePokemonFromTeam(int teamEntryId) async {
    final db = await database;
    await db.delete('teams', where: 'id = ?', whereArgs: [teamEntryId]);
  }
}
