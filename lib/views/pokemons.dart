import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pokedex_app/services/database_helper.dart';
import '../models/pokemon.dart';
import '../models/user.dart';
import '../widgets/pokemon_item.dart';

class Pokemons extends StatefulWidget {
  final User currentUser;
  const Pokemons({super.key, required this.currentUser});

  @override
  State<Pokemons> createState() => _PokemonsState();
}

class _PokemonsState extends State<Pokemons> {
  late Future<List<Pokemon>> _futurePokemons;

  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _futurePokemons = _loadPokemons();
  }

  Future<List<Pokemon>> _loadPokemons() async {
    final db = DatabaseHelper.instance;
    final dbPokemons = await _getPokemonsFromDB();

    if (dbPokemons.isNotEmpty) {
      return dbPokemons;
    }

    final apiPokemons = await _fetchPokemons();
    for (final p in apiPokemons) {
      await db.addPokemon(p);
    }
    return apiPokemons;
  }

  Future<List<Pokemon>> _getPokemonsFromDB() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('pokemons');
    return result.map((map) => Pokemon.fromMap(map)).toList();
  }

  Future<List<Pokemon>> _fetchPokemons() async {
    final res = await http.get(
      Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=807'),
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final results = data['results'] as List;

      final pokemons = await Future.wait(
        results.map((item) => Pokemon.fromApi(item)),
      );

      return pokemons;
    } else {
      throw Exception('Falha ao carregar Pokémons da API');
    }
  }

  bool _matchesSearch(Pokemon p) {
    return _searchQuery.isEmpty ||
        p.name.toLowerCase().contains(_searchQuery.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Pesquisar Pokémon...',
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : Text(
                "Pokédex",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            onPressed: () {
              setState(() {
                if (_isSearching) _searchQuery = '';
                _isSearching = !_isSearching;
              });
            },
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      body: FutureBuilder<List<Pokemon>>(
        future: _futurePokemons,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum Pokémon encontrado.'));
          }

          final filtered = snapshot.data!.where(_matchesSearch).toList();

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              return PokemonItem(
                pokemon: filtered[index],
                currentUser: widget.currentUser,
              );
            },
          );
        },
      ),
    );
  }
}
