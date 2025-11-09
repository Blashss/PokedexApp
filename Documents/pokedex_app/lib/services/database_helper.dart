import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:pokedex_app/models/user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/pokemon.dart';
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
        type TEXT NOT NULL
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
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<List<Pokemon>> getPokemons() async {
    Database db = await instance.database;
    final result = await db.query('pokemons', orderBy: 'pokedexNum ASC');
    return result.isNotEmpty
        ? result.map((item) => Pokemon.fromMap(item)).toList()
        : [];
  }

  Future<int> addPokemon(Pokemon newPokemon) async {
    Database db = await instance.database;
    return await db.insert('pokemons', newPokemon.toMap());
  }

  Future<int> removePokemon(int pokedexNum) async {
    Database db = await instance.database;
    return await db.delete(
      'pokemons',
      where: 'pokedexNum = ?',
      whereArgs: [pokedexNum],
    );
  }

  Future<int> updatePokemon(Pokemon pokemon) async {
    Database db = await instance.database;
    return await db.update(
      'pokemons',
      pokemon.toMap(),
      where: 'pokedexNum = ?',
      whereArgs: [pokemon.pokedexNum],
    );
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

  Future<int> removeUser(int id) async {
    Database db = await instance.database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateUser(User user) async {
    Database db = await instance.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
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
}
