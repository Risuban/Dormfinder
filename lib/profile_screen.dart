import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart'; // Import your main.dart file where AuthenticationWrapper is defined

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key});

  // Function to sign out the user
  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate back to the authentication screen after signing out
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthenticationWrapper()),
      );
    } catch (e) {
      print('Error during sign out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Center(
          child: Text('Perfil'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () =>
              _signOut(context), // Pass the context to the _signOut function
          child: const Text('Cerrar sesión'),
        ),
      ],
    );
  }
}
