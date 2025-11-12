import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/pokemon.dart';
import '../models/user.dart';
import 'pokemon_detalhe_item.dart';

class PokemonItem extends StatelessWidget {
  final Pokemon pokemon;
  final User currentUser;

  const PokemonItem({
    super.key,
    required this.pokemon,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => PokemonDetalheItem(
            pokemon: pokemon,
            currentUser: currentUser,
          ),
        );
      },
      child: Card(
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '#${pokemon.pokedexNum}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
