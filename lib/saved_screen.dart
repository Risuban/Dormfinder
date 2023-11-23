// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/property.dart';
import 'package:provider/provider.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    // Obtener UserModel usando Provider
    UserModel userModel = Provider.of<UserModel>(context);

    // Obtener las referencias de los documentos guardados desde UserModel
    List<DocumentReference> savedPropertyReferences = userModel.savedProperties;
    print(savedPropertyReferences);

    // Si no hay propiedades guardadas, mostrar un mensaje en el centro de la pantalla
    if (savedPropertyReferences.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Aún no has guardado propiedades.',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      );
    }

    // Crear una consulta que obtenga los documentos correspondientes a las referencias guardadas
    Query query = FirebaseFirestore.instance.collection('properties').where(
          FieldPath.documentId,
          whereIn: savedPropertyReferences.map((ref) => ref.id),
        );

    return PropertyList(query: query);
  }
}
