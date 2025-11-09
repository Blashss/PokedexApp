import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pokedex_app/widgets/pokemon_item.dart';
import '../models/pokemon.dart';

class Pokemons extends StatefulWidget {
  const Pokemons({super.key});

  @override
  State<Pokemons> createState() => _PokemonsState();
}

class _PokemonsState extends State<Pokemons> {
  late Future<List<Pokemon>> _futurePokemons;

  @override
  void initState() {
    super.initState();
    _futurePokemons = fetchPokemons();
  }

  Future<List<Pokemon>> fetchPokemons() async {
    final response = await http.get(
      Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=700'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      return results.map((item) => Pokemon.fromApi(item)).toList();
    } else {
      throw Exception('Falha ao carregar Pokémons');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Pokedex",
          style: TextStyle(
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
        ),
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

          final pokemons = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemCount: pokemons.length,
            itemBuilder: (context, index) {
              return PokemonItem(pokemon: pokemons[index]);
            },
          );
        },
      ),
    );
  }
}
