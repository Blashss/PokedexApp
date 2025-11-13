import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../models/user.dart';
import '../services/database_helper.dart';

class PokemonDetalheItem extends StatelessWidget {
  final Pokemon pokemon;
  final User currentUser;
  final bool isFromUser;

  const PokemonDetalheItem({
    super.key,
    required this.pokemon,
    required this.currentUser,
    this.isFromUser = false,
  });

  @override
  Widget build(BuildContext context) {
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
          Text('Tipo: ${pokemon.type}'),
          const SizedBox(height: 20),
          if (isFromUser)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: Icons.add,
                  color: Colors.green,
                  label: 'Adicionar ao Time',
                  onPressed: () async {
                    await DatabaseHelper.instance.addPokemonToTeam(
                      currentUser.id!,
                      pokemon.captureId!,
                    );
                    Navigator.pop(context);
                  },
                ),
                _ActionButton(
                  icon: Icons.delete,
                  color: Colors.red,
                  label: 'Excluir Pokémon',
                  onPressed: () async {
                    await DatabaseHelper.instance.deleteUserPokemon(
                      pokemon.captureId!,
                    );
                    Navigator.pop(context);
                  },
                ),
              ],
            )
          else
            _ActionButton(
              icon: Icons.catching_pokemon,
              color: Colors.red,
              label: 'Capturar Pokémon',
              onPressed: () async {
                await DatabaseHelper.instance.capturePokemon(
                  currentUser.id!,
                  pokemon,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${pokemon.name.toUpperCase()} foi capturado!'),
                    duration: const Duration(seconds: 1),
                  ),
                );
                Navigator.pop(context);
              },
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: color, size: 36),
          onPressed: onPressed,
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
