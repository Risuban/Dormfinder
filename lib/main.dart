import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class Property {
  final String name;
  final String info1;
  final String info2;
  final double price;
  final String imageUrl;

  Property({
    required this.name,
    required this.info1,
    required this.info2,
    required this.price,
    required this.imageUrl,
  });
}

class PropertyList extends StatelessWidget {
  final List<Property> properties;

  const PropertyList({super.key, required this.properties});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: properties.length,
      itemBuilder: (context, index) {
        final property = properties[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            children: [
              ClipRRect(
                // Wrap the image with ClipRRect
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
                child: Image.network(
                  property.imageUrl,
                  width: double.infinity,
                  height: 150.0,
                  fit: BoxFit.cover,
                ),
              ),
              ListTile(
                title: Text(property.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(property.info1),
                    Text(property.info2),
                    Text('\$${property.price.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class RoundedSearchBarWithButtons extends StatelessWidget {
  final Function()? onSearchPressed;
  final Function()? onButton1Pressed;
  final Function()? onButton2Pressed;
  final Function()? onButton3Pressed;

  const RoundedSearchBarWithButtons({
    super.key,
    this.onSearchPressed,
    this.onButton1Pressed,
    this.onButton2Pressed,
    this.onButton3Pressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16.0),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(30.0),
              border: Border.all(color: Colors.grey)),
          child: Row(
            children: [
              const Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '¿Que tipo de alojamiento buscas?',
                    // add a black border
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: onSearchPressed,
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: onButton1Pressed,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromARGB(
                    255, 92, 92, 92), // Change text color here
              ),
              child: const Text(
                'Pensiones',
                style: TextStyle(color: Colors.white), // Text color override
              ),
            ),
            ElevatedButton(
              onPressed: onButton2Pressed,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromARGB(
                    255, 92, 92, 92), // Change text color here
              ),
              child: const Text(
                'Roomies',
                style: TextStyle(color: Colors.white), // Text color override
              ),
            ),
            ElevatedButton(
              onPressed: onButton3Pressed,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromARGB(
                    255, 92, 92, 92), // Change text color here
              ),
              child: const Text(
                'Arriendos',
                style: TextStyle(color: Colors.white), // Text color override
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
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
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    const SavedScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Title: DormFinder in black
        title: const Text(
          'DormFinder',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            // Heart icon
            icon: FaIcon(FontAwesomeIcons.heart),
            label: 'Guardados',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final List<Property> properties = [
    Property(
      name: 'Property 1',
      info1: 'Info 1',
      info2: 'Info 2',
      price: 100000.0,
      imageUrl: 'https://via.placeholder.com/150',
    ),
    Property(
      name: 'Property 1',
      info1: 'Info 1',
      info2: 'Info 2',
      price: 100000.0,
      imageUrl: 'https://via.placeholder.com/150',
    ),
    Property(
      name: 'Property 1',
      info1: 'Info 1',
      info2: 'Info 2',
      price: 100000.0,
      imageUrl: 'https://via.placeholder.com/150',
    ),
    Property(
      name: 'Property 1',
      info1: 'Info 1',
      info2: 'Info 2',
      price: 100000.0,
      imageUrl: 'https://via.placeholder.com/150',
    ),
    Property(
      name: 'Property 1',
      info1: 'Info 1',
      info2: 'Info 2',
      price: 100000.0,
      imageUrl: 'https://via.placeholder.com/150',
    ),
    // Add more properties here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          RoundedSearchBarWithButtons(
            onSearchPressed: () {
              // Implement search functionality here
            },
            onButton1Pressed: () {
              // Implement button 1 functionality here
            },
            onButton2Pressed: () {
              // Implement button 2 functionality here
            },
            onButton3Pressed: () {
              // Implement button 3 functionality here
            },
          ),
          Expanded(
            child: PropertyList(properties: properties),
          ),
        ],
      ),
    );
  }
}

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Guardados'),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Perfil'),
    );
  }
}
