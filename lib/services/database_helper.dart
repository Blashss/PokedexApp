import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/pokemon.dart';
import '../models/user.dart';
import 'package:crypto/crypto.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  static const int _version = 1;
  static const String _dbName = "pokedex_db.db";

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _dbName);
    return openDatabase(path, version: _version, onCreate: _createDb);
  }

  Future _createDb(Database db, int version) async {
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
        name TEXT,
        email TEXT UNIQUE,
        password TEXT
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
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<List<User>> getUsers() async {
    Database db = await instance.database;
    final result = await db.query('users', orderBy: 'id ASC');
    return result.isNotEmpty
        ? result.map((item) => User.fromMap(item)).toList()
        : [];
  }

  Future<int> addUser(User user) async {
    final db = await instance.database;
    final userMap = user.toMap();
    userMap['password'] = _hashPassword(user.password);
    return await db.insert('users', userMap);
  }

  Future<User?> loginUser(String email, String password) async {
    final db = await instance.database;
    final res = await db.query('users', where: 'email = ?', whereArgs: [email]);

    if (res.isNotEmpty) {
      final user = User.fromMap(res.first);
      final hashedInput = _hashPassword(password);
      if (hashedInput == user.password) {
        return user;
      }
    }
    return null;
  }

  Future<int> updateUser(User user) async {
  final db = await database;
  final needsHash = !RegExp(r'^[a-f0-9]{64}$').hasMatch(user.password);
  final updated = user.toMap()
    ..['password'] = needsHash ? _hashPassword(user.password) : user.password;
  return db.update('users', updated, where: 'id = ?', whereArgs: [user.id]);
}

  Future<User?> getUserById(int id) async {
    final db = await database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<int> addPokemon(Pokemon newPokemon) async {
  final db = await instance.database;
  final existing = await db.query(
    'pokemons',
    where: 'pokedexNum = ?',
    whereArgs: [newPokemon.pokedexNum],
  );
  if (existing.isNotEmpty) return existing.first['pokedexNum'] as int;
  return await db.insert('pokemons', newPokemon.toMap());
}

  Future<void> capturePokemon(int userId, Pokemon pokemon) async {
    final db = await instance.database;
    await addPokemon(pokemon);
    await db.insert('user_pokemons', {
      'userId': userId,
      'pokedexNum': pokemon.pokedexNum,
    });
  }

  Future<void> saveAllPokemons(List<Pokemon> pokemons) async {
  final db = await instance.database;
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

Future<List<Pokemon>> getAllPokemonsFromDB() async {
  final db = await instance.database;
  final result = await db.query('pokemons', orderBy: 'pokedexNum ASC');
  return result.map((item) => Pokemon.fromMap(item)).toList();
}
}


