import 'package:flutter/material.dart';
import 'package:pokedex_app/views/login.dart';
import 'package:pokedex_app/views/pokemons.dart';
import 'package:flutter/material.dart';
import 'models/user.dart';
import 'views/pokemons.dart';

void main() {
  final fakeUser = User(id: 1, name: 'aceRola', email: 'acerola@pokedex.com', password: 'MIMIKYUGOAT',);
  runApp(MyApp(currentUser: fakeUser));
}

class MyApp extends StatelessWidget {
  final User currentUser;

  const MyApp({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokedex',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
      ),
      debugShowCheckedModeBanner: false,
      home: Login(),
    );
  }
}
