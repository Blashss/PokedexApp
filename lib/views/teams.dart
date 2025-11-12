import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pokedex_app/widgets/pokemon_detalhe_item.dart';
import '../models/pokemon.dart';
import '../models/user.dart';
import '../services/database_helper.dart';

class Teams extends StatefulWidget {
final User currentUser;

const Teams({super.key, required this.currentUser});

@override
State<Teams> createState() => _TeamsState();
}

class _TeamsState extends State<Teams> {
List<Pokemon> userPokemons = [];
List<Pokemon> teamPokemons = [];

@override
void initState() {
 super.initState();
 _loadPokemons();
}

Future<void> _loadPokemons() async {
 final db = DatabaseHelper.instance;
 final userPkm = await db.getUserPokemons(widget.currentUser.id!); 
 final teamPkm = await db.getUserTeam(widget.currentUser.id!);
 setState(() {
 userPokemons = userPkm;
 teamPokemons = teamPkm;
 });
}

@override
Widget build(BuildContext context) {
 final colorScheme = Theme.of(context).colorScheme;

 return Scaffold(
 appBar: AppBar(
  title: Text(
  "Time Pokémon",
  style: TextStyle(color: colorScheme.primaryContainer),
  ),
  backgroundColor: colorScheme.onPrimaryContainer,
  centerTitle: true,
 ),
 body: Padding(
  padding: const EdgeInsets.all(10),
  child: Column(
  children: [
   const SizedBox(height: 10),
   const Text(
   "Seu Time Atual",
   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
   ),
   const SizedBox(height: 10),

   GridView.builder(
   shrinkWrap: true,
   physics: const NeverScrollableScrollPhysics(),
   itemCount: 6,
   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3,
    crossAxisSpacing: 10,
    mainAxisSpacing: 10,
    childAspectRatio: 1,
   ),
   itemBuilder: (context, index) {
    final pokemon = index < teamPokemons.length ? teamPokemons[index] : null;

    if (pokemon == null) {
    return Card(
     shape: RoundedRectangleBorder(
     borderRadius: BorderRadius.circular(12),
     ),
     elevation: 4,
     child: const Center(
     child: Icon(Icons.add, color: Colors.grey, size: 40),
     ),
    );
    }

    return GestureDetector(
    onTap: () async {
     await DatabaseHelper.instance.removePokemonFromTeam(
     pokemon.captureId!, 
     );
     await _loadPokemons(); 
    },
    child: Card(
     shape: RoundedRectangleBorder(
     borderRadius: BorderRadius.circular(12),
     ),
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
      errorWidget: (context, url, error) =>
       const Icon(Icons.error),
      ),
      const SizedBox(height: 8),
      Text(
      pokemon.name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontWeight: FontWeight.bold),
      ),
     ],
     ),
    ),
    );
   },
   ),

   const SizedBox(height: 20),

   const Text(
   "Pokémons Capturados (Disponíveis)",
   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
   ),
   const SizedBox(height: 10),

   Expanded(
   child: userPokemons.isEmpty
    ? const Center(
     child: Text(
      "Você não tem Pokémons disponíveis.",
      style: TextStyle(color: Colors.grey),
     ),
     )
    : GridView.builder(
     padding: const EdgeInsets.only(bottom: 10),
     itemCount: userPokemons.length,
     gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
       crossAxisCount: 3,
       crossAxisSpacing: 10,
       mainAxisSpacing: 10,
       childAspectRatio: 0.8,
      ),
     itemBuilder: (context, index) {
      final pokemon = userPokemons[index];
      return GestureDetector(
      onTap: () async {
       await showDialog(
       context: context,
       builder: (context) => PokemonDetalheItem(
        pokemon: pokemon,
        currentUser: widget.currentUser,
        isFromUser: true,
       ),
       );

       await _loadPokemons(); 
      },
      child: Card(
       shape: RoundedRectangleBorder(
       borderRadius: BorderRadius.circular(12),
       ),
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
         const CircularProgressIndicator(
          strokeWidth: 2,
         ),
        errorWidget: (context, url, error) =>
         const Icon(Icons.error),
        ),
        const SizedBox(height: 8),
        Text(
        pokemon.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
         fontWeight: FontWeight.bold,
        ),
        ),
        Text(
        '#${pokemon.pokedexNum}',
        style: const TextStyle(color: Colors.grey),
        ),
       ],
       ),
      ),
      );
     },
     ),
   ),
  ],
  ),
 ),
 );
}
}