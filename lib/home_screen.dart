import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  List<Property> properties = [];

  void _onSearchSubmitted(String searchText) {
    setState(() {
      searchController.text = searchText;
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialize the properties list or perform any other setup if needed
    properties = [];

    // Use a StreamBuilder to listen for changes in the Firestore data
    // and update the properties list accordingly
    buildHomeQuery(
      showPensiones: showPensiones,
      showRoomies: showRoomies,
      showArriendos: showArriendos,
      searchText: searchController.text,
    ).snapshots().listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          properties = snapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            switch (data['type']) {
              case 'roomie':
                return Roomie.fromMap(data, doc.reference);
              case 'pension':
                return Pension.fromMap(data, doc.reference);
              case 'departamento':
                return Departamento.fromMap(data, doc.reference);
              default:
                return Property.fromMap(data, doc.reference);
            }
          }).toList();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SearchAnchor(
                builder:
                    (BuildContext context, SearchController searchController) {
                  return SearchBar(
                    padding: const MaterialStatePropertyAll<EdgeInsets>(
                      EdgeInsets.symmetric(horizontal: 16),
                    ),
                    leading: const Icon(Icons.search),
                    hintText: ("Buscar viviendas"),
                    controller: searchController,
                    onSubmitted: _onSearchSubmitted,
                    onTap: () {
                      searchController.openView();
                    },
                    onChanged: (_) {
                      searchController.openView();
                    },
                  );
                },
                suggestionsBuilder:
                    (BuildContext context, SearchController searchController) {
                  return List<ListTile>.generate(5, (int index) {
                    final String item = 'item $index';
                    return ListTile(
                      title: Text(item),
                      onTap: () {
                        setState(() {
                          searchController.closeView(item);
                        });
                      },
                    );
                  });
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Wrap(
                spacing: 10,
                children: [
                  FilterChip(
                    showCheckmark: false,
                    label: const Text("Pensiones"),
                    selected: showPensiones,
                    onSelected: (bool selected) {
                      setState(() {
                        showPensiones = !showPensiones;
                      });
                    },
                  ),
                  FilterChip(
                    showCheckmark: false,
                    label: const Text("Roomies"),
                    selected: showRoomies,
                    onSelected: (bool selected) {
                      setState(() {
                        showRoomies = !showRoomies;
                      });
                    },
                  ),
                  FilterChip(
                    showCheckmark: false,
                    label: const Text("Departamentos"),
                    selected: showArriendos,
                    onSelected: (bool selected) {
                      setState(() {
                        showArriendos = !showArriendos;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          // SliverList is a direct child of CustomScrollView
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                // Use the PropertyCard widget here
                return PropertyCard(property: properties[index]);
              },
              childCount: properties.length,
            ),
          ),
        ],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPageIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    const ProfileScreen(),
    const SavedScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'DormFinder',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
      ),
      body: _pages[currentPageIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: Theme.of(context).colorScheme.secondaryContainer,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: <Widget>[
          NavigationDestination(
            icon: Icon(
              Icons.home_rounded,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
            label: 'Perfil',
          ),
          NavigationDestination(
            icon: FaIcon(
              FontAwesomeIcons.heart,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
            label: 'Guardados',
          ),
        ],
      ),
    );
  }
}
