import 'package:flutter/material.dart';
import 'package:pokedex_app/models/user.dart';
import 'package:pokedex_app/views/edit_profile.dart';
import 'package:pokedex_app/views/login.dart';

class Profile extends StatefulWidget {
  final User currentUser;
  const Profile({super.key, required this.currentUser});

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
            Text(widget.currentUser.name, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 10),
            Text(
              widget.currentUser.email,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 10),
            IconButton(
              onPressed: () async {
                final updatedUser = await Navigator.push<User>(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditProfile(currentUser: widget.currentUser),
                  ),
                );

                if (updatedUser != null) {
                  setState(() {
                    widget.currentUser.name = updatedUser.name;
                    widget.currentUser.password = updatedUser.password;
                  });
                }
              },
              icon: const Icon(Icons.edit, size: 50),
            ),
            const SizedBox(height: 10),
            IconButton(
              onPressed: () async {
                await Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                );
              },
              icon: const Icon(Icons.logout, size: 50),
            ),
          ],
        ),
      ),
    );
  }
}
