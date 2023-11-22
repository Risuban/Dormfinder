import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'property.dart';

class SavedScreen extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    // // Suponiendo que tienes una forma de obtener los IDs de las propiedades guardadas
    // List<String> savedPropertyIds = /* obtener los IDs de las propiedades guardadas */;

    // Query query = FirebaseFirestore.instance
    //     .collection('properties')
    //     .where(FieldPath.documentId, whereIn: savedPropertyIds);

    // // return PropertyList(query: query);
        return const Center(
      child: Text('Guardados'),
    );
  }
}
