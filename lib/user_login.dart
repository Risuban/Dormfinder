// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/user_signup.dart';
import 'package:provider/provider.dart';
import 'main.dart'; // Import your main.dart file where AuthenticationWrapper is defined

class LoginScreen extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const LoginScreen({Key? key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Function to sign in the user
  Future<void> _signIn(BuildContext context) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      User user = userCredential.user!;

      // User signed in successfully, check if the user is authenticated
      if (user.uid.isNotEmpty) {
        // ignore: use_build_context_synchronously
        final userModel = Provider.of<UserModel>(context, listen: false);
        await userModel.updateUserInfoFromFirebase(user);

        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const AuthenticationWrapper()),
        );
        print('User signed in successfully!');
      } else {
        // If user is not authenticated, show an error message or handle it accordingly
        print('User is not authenticated.');
      }
    } catch (e) {
      // Handle errors (e.g., invalid email/password, user not found, etc.)
      print('Error during sign in: $e');

      // Show a snackbar with an error message
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Error al iniciar sesión. Correo o contraseña incorrectos.',
          ),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio de sesión'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () =>
                  _signIn(context), // Pass the context to the _signIn function
              child: const Text('Iniciar Sesión'),
            ),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: () {
                // Navigate to the sign-up screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpScreen()),
                );
              },
              child: const Text('Registrarse'),
            ),
          ],
        ),
      ),
    );
  }
}
