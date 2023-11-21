import 'package:flutter/material.dart';
import 'package:flutter_application_1/saved_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'profile_screen.dart';
import 'property.dart'; // Asegúrate de importar PropertyList


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showPensiones = false;
  bool showRoomies = false;
  bool showArriendos = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
        child: Column(
          children: [
            const SearchBar(
              padding: MaterialStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 16.0)),
              leading: Icon(Icons.search),
              hintText: ("Pensión de estudiantes"),
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
                  child: Text('Pensiones'),
                  style: ElevatedButton.styleFrom(
                    primary: showPensiones ? Colors.blue : Colors.grey,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showRoomies = !showRoomies;
                    });
                  },
                  child: Text('Roomies'),
                  style: ElevatedButton.styleFrom(
                    primary: showRoomies ? Colors.blue : Colors.grey,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showArriendos = !showArriendos;
                    });
                  },
                  child: Text('Dptos'),
                  style: ElevatedButton.styleFrom(
                    primary: showArriendos ? Colors.blue : Colors.grey,
                  ),
                ),
              ],
            ),
              Expanded(
                child: PropertyList(
                  showPensiones: showPensiones,
                  showRoomies: showRoomies,
                  showArriendos: showArriendos,
                ),
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
    ProfileScreen(),
    SavedScreen(),
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
