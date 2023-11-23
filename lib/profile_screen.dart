// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'main.dart';

class ProfileScreen extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const ProfileScreen({Key? key});

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthenticationWrapper()),
      );
    } catch (e) {
      print('Error during sign out: $e');
    }
  }

  // Fetch the actual properties based on the references
  Future<List<String>> fetchProperties(
      List<DocumentReference> references) async {
    List<String> properties = [];

    for (var reference in references) {
      DocumentSnapshot snapshot = await reference.get();
      if (snapshot.exists) {
        // Modifica esta línea según la estructura de tus documentos de propiedad
        String propertyName = snapshot.get('name') ?? '';

        properties.add(propertyName);
      }
    }

    return properties;
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);

    return FutureBuilder(
      future: fetchProperties(
          userModel.savedProperties.cast<DocumentReference<Object?>>()),
      builder: (context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Información del usuario
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [const Icon(
                    Icons.account_circle_outlined,
                    size: 100,
                  ),
                Text(
                  userModel.userName,
                  style: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.bold),
                ),
                  Text(userModel.email),
                  Text(userModel.phoneNumber),
                  ]
                ),
                const SizedBox(width: 16),
                // Información del usuario

                const Divider(
                  color: Colors.black,
                  thickness: 0.3,
                ),
                // Configuración del usuario

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(12))
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.logout_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: const Text("Cerrar Sesión"),
                      onTap: () => _signOut(context),
                    )
                
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
