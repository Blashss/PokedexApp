import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  String? _selectedGeneration;

  final generations = ['Kanto','Johto','Hoenn','Sinnoh','Unova','Kalos','Alola'];

  @override
  void initState() {
    super.initState();
    _futurePokemons = fetchPokemons();
  }

  Future<List<Pokemon>> fetchPokemons() async {
    final res = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=778'));
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return (data['results'] as List).map((item) => Pokemon.fromApi(item)).toList();
    }
    throw Exception('Falha ao carregar Pokémons');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pokédex"),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: FutureBuilder<List<Pokemon>>(
        future: _futurePokemons,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum Pokémon encontrado.'));
          }

          final pokemons = snapshot.data!.where((p) => _selectedGeneration == null || p.generation == _selectedGeneration).toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<String>(
                  value: _selectedGeneration,
                  items: [null, ...generations].map((gen) {
                    return DropdownMenuItem(
                      value: gen,
                      child: Text(gen ?? "Todas"),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedGeneration = val;
                    });
                  },
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: pokemons.length,
                  itemBuilder: (context, index) {
                    return PokemonItem(
                      pokemon: pokemons[index],
                      currentUser: widget.currentUser,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
