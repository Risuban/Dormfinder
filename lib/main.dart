// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/user_login.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'color_schemes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme
      ),
      darkTheme:
          ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
      home: const AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if the user is signed in
    if (FirebaseAuth.instance.currentUser == null) {
      // If not signed in, navigate to the sign-up screen
      return const LoginScreen();
    } else {
      // reconstruye UserModel con la key del usuario actual
      final userModel = Provider.of<UserModel>(context, listen: false);
      userModel.updateUserInfoFromFirebase(FirebaseAuth.instance.currentUser!);

      return const MyHomePage();
    }
  }
}

class UserModel extends ChangeNotifier {
  final String _userId = FirebaseAuth.instance.currentUser!.uid;
  String _email = '';
  String _userName = '';
  String _phoneNumber = '';
  List<DocumentReference> _savedProperties = [];

  String get email => _email;
  String get userName => _userName;
  String get phoneNumber => _phoneNumber;
  List<DocumentReference> get savedProperties => _savedProperties;

  Future<void> updateUserInfoFromFirebase(User user) async {
    try {
      // Obtener referencia al documento del usuario en Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // Verificar si el documento existe antes de acceder a los datos
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        _email = user.email ?? '';
        _userName = userData['name'] ?? '';
        _phoneNumber = userData['phone'] ?? '';
        _savedProperties =
            List<DocumentReference>.from(userData['saved_properties'] ?? []);

        notifyListeners();
      }
      print('User signed in successfully!');
    } catch (e) {
      print('Error updating user info from Firestore: $e');
    }
  }

  void toggleFavorite(BuildContext context, DocumentReference owner) {
    // Usa 'context' según sea necesario

    // Verificar si la propiedad está en favoritos
    if (savedProperties.contains(owner)) {
      // Si está en favoritos, quitarla de la lista
      removeFromFavorites(owner);
    } else {
      // Si no está en favoritos, agregarla a la lista
      addToFavorites(owner);
    }
  }

  Future<void> addToFavorites(DocumentReference propertyReference) async {
    try {
      // Añadir la referencia de la propiedad a la lista de propiedades guardadas
      _savedProperties.add(propertyReference);

      // Actualizar la base de datos
      await FirebaseFirestore.instance
          .collection('users')
          .doc(
              _userId) // Asegúrate de tener el ID del usuario almacenado en _userId
          .update({'saved_properties': _savedProperties});

      // Notificar a los listeners que los datos han cambiado
      notifyListeners();
    } catch (e) {
      print('Error adding property to favorites: $e');
    }
  }

  Future<void> removeFromFavorites(DocumentReference property) async {
    try {
      // Verificar si la propiedad está en la lista de favoritos
      if (_savedProperties.contains(property)) {
        // Quitar la propiedad de la lista
        _savedProperties.remove(property);

        // Actualizar la base de datos con la nueva lista de favoritos
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .update({'saved_properties': _savedProperties});

        // Notificar a los oyentes del cambio
        notifyListeners();
      }
    } catch (e) {
      print('Error removing property from favorites: $e');
    }
  }
}
