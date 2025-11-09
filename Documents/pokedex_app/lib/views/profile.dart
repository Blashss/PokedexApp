import 'package:flutter/material.dart';
import 'package:pokedex_app/models/user.dart';

class Profile extends StatefulWidget {
  final User user;
  const Profile({super.key, required this.user});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Perfil",
          style: TextStyle(
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.person_add, size: 100),
            ),
            SizedBox(height: 10),
            Text(widget.user.name, style: const TextStyle(fontSize: 24)),
            SizedBox(height: 10),
            Text(widget.user.email, style: const TextStyle(fontSize: 24)),
            SizedBox(height: 10),
            IconButton(onPressed: () {}, icon: Icon(Icons.edit, size: 50)),
          ],
        ),
      ),
    );
  }
}
