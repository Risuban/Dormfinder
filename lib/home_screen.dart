import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'saved_screen.dart';
import 'property.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                    // Handle bdutton 1 action
                  },
                  child: const Text('Pensiones'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle button 2 action
                  },
                  child: const Text('Roomies'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle button 3 action
                  },
                  child: const Text('Arriendos'),
                ),
              ],
            ),
            const Expanded(
              child: PropertyList(), // Use PropertyList to display properties
            )
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
    const SavedScreen(),
    const ProfileScreen(),
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
          NavigationDestination(
              icon: FaIcon(FontAwesomeIcons.heart), label: 'Guardados'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Perfil')
        ],
      ),
    );
  }
}
