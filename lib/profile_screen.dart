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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Información del usuario
                Row(
                  children: [
                    // Icono de usuario (puedes cambiarlo por el que prefieras)
                    const Icon(
                      Icons.account_circle_outlined,
                      size: 100,
                    ),
                    const SizedBox(width: 16),
                    // Información del usuario
                    Text(
                      userModel.userName,
                      style: const TextStyle(
                          fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                const Divider(
                  color: Colors.black,
                  thickness: 1,
                ),
                Row(children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Información',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('Correo Electrónico: ${userModel.email}'),
                      Text('Número de Teléfono: ${userModel.phoneNumber}'),
                    ],
                  ),
                ]),
                const Divider(
                  color: Colors.black,
                  thickness: 1,
                ),
                // Configuración del usuario
                const Text('Configuración',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Row(
                    children: [
                      // Icono de eliminar usuario (puedes cambiarlo por el que prefieras)
                      const Icon(Icons.person_remove_rounded, size: 30),
                      const SizedBox(width: 16),
                      // Texto "Eliminar cuenta"
                      const Text(
                        'Eliminar cuenta',
                        style: TextStyle(fontSize: 15, color: Colors.black),
                      ),
                      // boton Icon button flecha alineado a la derecha
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          // Lógica para editar la cuenta
                        },
                        icon: const Icon(Icons.arrow_forward_rounded),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () => _signOut(context),
                    child: const Text('Cerrar sesión'),
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
