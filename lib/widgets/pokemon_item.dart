import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PokemonItem extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonItem({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CachedNetworkImage(
            imageUrl: pokemon.imageUrl,
            height: 70,
            width: 70,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                const CircularProgressIndicator(strokeWidth: 2),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
          const SizedBox(height: 8),
          Text(
            pokemon.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            '#${pokemon.pokedexNum}',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
