import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';
import '../models/user.dart';
import '../services/database_helper.dart';

class PokemonDetalheItem extends StatelessWidget {
  final Pokemon pokemon;
  final User currentUser;

  const PokemonDetalheItem({
    super.key,
    required this.pokemon,
    required this.currentUser,
  });

  Future<String> fetchPokemonType(int id) async {
    final res = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$id'));
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final types = (data['types'] as List)
          .map((t) => t['type']['name'] as String)
          .join(', ');
      return types;
    }
    return 'Desconhecido';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: fetchPokemonType(pokemon.pokedexNum),
      builder: (context, snapshot) {
        final type = snapshot.data ;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            pokemon.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(pokemon.imageUrl, height: 100, width: 100),
              const SizedBox(height: 10),
              Text('Geração: ${pokemon.generation}'),
              Text('Tipo: $type'),
              const SizedBox(height: 20),
              IconButton(
                icon:  Icon(Icons.catching_pokemon, color: Colors.red, size: 40),
                onPressed: () async {
                  await DatabaseHelper.instance.capturePokemon(
                    currentUser.id!,
                    pokemon,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${pokemon.name} foi capturado!'),
                    ),
                  );
                  Navigator.pop(context);
                },
              ),
               Text("Capturar Pokémon"),
            ],
          ),
        );
      },
    );
  }
}
