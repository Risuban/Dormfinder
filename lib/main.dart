// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/user_login.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      darkTheme:
          ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
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
}
