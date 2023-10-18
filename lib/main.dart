import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

// Mock data: List of properties
final List<Property> mockProperties = [
  Property(
    name: 'Casa Hermosa',
    info1: '2 habitaciones, 1 baño',
    info2: 'Cerca del parque',
    price: 120000.0,
    imageUrl: 'https://via.placeholder.com/150',
  ),
  Property(
    name: 'Apartamento Centrico',
    info1: '3 habitaciones, 2 baños',
    info2: 'Vista a la ciudad',
    price: 175000.0,
    imageUrl: 'https://via.placeholder.com/150',
  ),
  // Add more mock properties as needed
];

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

  const PropertyList({Key? key, required this.properties}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: properties.length,
      itemBuilder: (context, index) {
        final property = properties[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PropertyDetailsScreen(property: property),
              ),
            );
          },
          child: Card(
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
        ));
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

class PropertyDetailsScreen extends StatelessWidget {
  final Property property;

  PropertyDetailsScreen({required this.property});

  @override
  Widget build(BuildContext context) {
    // Mock owner data
    var owner = {
      'phone': '123-456-7890',
      'whatsapp': 'https://wa.me/1234567890', // this should be a real whatsapp link
      'email': 'owner@example.com',
      'name': 'John Doe'
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalles de propiedades',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Image.network(property.imageUrl), // display the image
            Text(property.name),
            Text(property.info1),
            Text(property.info2),
            Text('\$${property.price.toStringAsFixed(2)}'),
            // Your other property details here...

            // Property attributes table
            DataTable(
              columns: const [
                DataColumn(label: Text('Attribute')),
                DataColumn(label: Text('Value')),
              ],
              rows: [
                DataRow(cells: [
                  DataCell(Text('Location')),
                  DataCell(Text('Google Maps Link')), // this should be a real link
                ]),
                // Other attributes here...
              ],
            ),

            // Owner info table
            DataTable(
              columns: const [
                DataColumn(label: Text('Contact')),
                DataColumn(label: Text('Value')),
              ],
              rows: [
                DataRow(cells: [
                  DataCell(Text('Phone')),
                  DataCell(Text(owner['phone']!)),
                ]),
                DataRow(cells: [
                  DataCell(Text('WhatsApp')),
                  DataCell(Text(owner['whatsapp']!)),
                ]),
                DataRow(cells: [
                  DataCell(Text('Email')),
                  DataCell(Text(owner['email']!)),
                ]),
                DataRow(cells: [
                  DataCell(Text('Name')),
                  DataCell(Text(owner['name']!)),
                ]),
                // Other contact info here...
              ],
            ),
            // Inside your PropertyDetailsScreen Widget
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OwnerDetailsScreen(
                      ownerName:'John Doe',  // replace with actual owner name
                      ownerProperties: mockProperties,  // replace with actual list of owner's properties
                      // pass other owner info here
                    ),
                  ),
                );
              },
              child: Text('More Info'),
            ),

            
          ],
        ),
      ),
    );
  }
}

class OwnerDetailsScreen extends StatelessWidget {
  final String ownerName;
  final List<Property> ownerProperties;

  // Add more parameters as needed for the owner's contact information
  OwnerDetailsScreen({
    required this.ownerName,
    required this.ownerProperties,
    // other owner info here
  });

    var owner = {
      'phone': '123-456-7890',
      'whatsapp': 'https://wa.me/1234567890', // this should be a real whatsapp link
      'email': 'owner@example.com',
      'name': 'John Doe'
    };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$ownerName',  // This displays the owner's name
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black), // to change the back button color
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
                        DataTable(
              columns: const [
                DataColumn(label: Text('Contact')),
                DataColumn(label: Text('Value')),
              ],
              rows: [
                DataRow(cells: [
                  DataCell(Text('Phone')),
                  DataCell(Text(owner['phone']!)),
                ]),
                DataRow(cells: [
                  DataCell(Text('WhatsApp')),
                  DataCell(Text(owner['whatsapp']!)),
                ]),
                DataRow(cells: [
                  DataCell(Text('Email')),
                  DataCell(Text(owner['email']!)),
                ]),
                DataRow(cells: [
                  DataCell(Text('Name')),
                  DataCell(Text(owner['name']!)),
                ]),
                // Other contact info here...
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Properties',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: PropertyList(properties: ownerProperties),  // Reusing the PropertyList widget
            ),
          ],
        ),
      ),
    );
  }
}
