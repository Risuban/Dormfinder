import 'package:flutter/material.dart';
import 'package:flutter_application_1/saved_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'profile_screen.dart';
import 'property.dart'; // Asegúrate de importar PropertyList
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

Query buildHomeQuery({
  required bool showPensiones,
  required bool showRoomies,
  required bool showArriendos,
  required String searchText,
}) {
  Query query = FirebaseFirestore.instance.collection('properties');

  // Filtrar por tipo
  List<String> types = [];
  if (showPensiones) types.add('pension');
  if (showRoomies) types.add('roomie');
  if (showArriendos) types.add('departamento');
  if (types.isNotEmpty) {
    query = query.where('type', whereIn: types);
  }

  // Filtrar por texto de búsqueda
  if (searchText.isNotEmpty) {
    query = query.where('name', isEqualTo: searchText);
  }

  return query;
}

Query buildSavedQuery(List<String> savedPropertyIds) {
  return FirebaseFirestore.instance
      .collection('properties')
      .where(FieldPath.documentId, whereIn: savedPropertyIds);
}

class _HomeScreenState extends State<HomeScreen> {
  bool showPensiones = false;
  bool showRoomies = false;
  bool showArriendos = false;
  final TextEditingController searchController = TextEditingController();
  int currentPageIndex = 0;

  void _onSearchSubmitted(String searchText) {
    setState(() {
      searchController.text = searchText;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    // Por defecto, establecemos el contenido de la página de inicio
    Query homeQuery = buildHomeQuery(
      showPensiones: showPensiones,
      showRoomies: showRoomies,
      showArriendos: showArriendos,
      searchText: searchController.text,
    );
    content = PropertyList(query: homeQuery);

    // Cambia el contenido según el índice de la página actual
    if (currentPageIndex == 1) {
      content = const ProfileScreen();
    } else if (currentPageIndex == 2) {
      // // Aquí puedes definir el contenido para la página de guardados
      // // Ejemplo (debes completar la lógica para obtener savedPropertyIds):
      // List<String> savedPropertyIds = /* Obtén los IDs de las propiedades guardadas */;
      // Query savedQuery = buildSavedQuery(savedPropertyIds);
      // content = PropertyList(query: savedQuery);
    }
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Pensión de estudiantes',
                border: OutlineInputBorder(),
              ),
              onSubmitted:
                  _onSearchSubmitted, // Se llama cuando se presiona Enter
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showPensiones = !showPensiones;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    primary: showPensiones ? Colors.blue : Colors.grey,
                  ),
                  child: const Text('Pensiones'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showRoomies = !showRoomies;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    primary: showRoomies ? Colors.blue : Colors.grey,
                  ),
                  child: const Text('Roomies'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showArriendos = !showArriendos;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    primary: showArriendos ? Colors.blue : Colors.grey,
                  ),
                  child: const Text('Dptos'),
                ),
              ],
            ),
            Expanded(
              child: content,
            ),
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPageIndex = 0;

  final List<Widget> _pages = [
    // ignore: prefer_const_constructors
    HomeScreen(),
    const ProfileScreen(),
    const SavedScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DormFinder'),
      ),
      body: _pages[currentPageIndex],
      bottomNavigationBar: NavigationBar(
        height: 80,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
              icon: Icon(Icons.home_rounded), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
          NavigationDestination(
              icon: FaIcon(FontAwesomeIcons.heart), label: 'Guardados'),
        ],
      ),
    );
  }
}
