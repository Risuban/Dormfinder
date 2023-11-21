import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'main.dart';

class ProfileScreen extends StatelessWidget {
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
          List<String> properties = snapshot.data ?? [];

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Email: ${userModel.email}'),
              Text('Username: ${userModel.userName}'),
              Text('Phone Number: ${userModel.phoneNumber}'),
              Text('Saved Properties: ${properties.join(', ')}'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _signOut(context),
                child: const Text('Cerrar sesión'),
              ),
            ],
          );
        }
      },
    );
  }
}
