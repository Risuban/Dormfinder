import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Property {
  final String name;
  final String image;
  final Map<String, dynamic> location;
  final DocumentReference owner;
  final int price;
  final String type;
  final Map<String, dynamic> distance;
  final Map<String, dynamic> features;
  final Map<String, dynamic> services;
  final String timePeriod;

  Property({
    required this.name,
    required this.image,
    required this.location,
    required this.owner,
    required this.price,
    required this.type,
    required this.distance,
    required this.features,
    required this.services,
    required this.timePeriod,
  });

  factory Property.fromMap(Map<String, dynamic> map) {
    return Property(
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      location: map['location'] as Map<String, dynamic>,
      owner: map['owner'], // Aquí asumimos que 'owner' es una DocumentReference
      price: map['price'] ?? 0,
      type: map['type'] ?? '',
      distance: map['distance'] as Map<String, dynamic>,
      features: map['features'] as Map<String, dynamic>,
      services: map['services'] as Map<String, dynamic>,
      timePeriod: map['time_period'] ?? '',
    );
  }

  // Método buildDetailWidget a ser implementado en las subclases
  Widget buildDetailWidget() {
    // Implementación por defecto o lanzar una excepción si se espera que las subclases lo implementen
    throw UnimplementedError('buildDetailWidget debe ser implementado en subclases de Property.');
  }
}



class Roomie extends Property {
  final List<String> rules;

  Roomie({
    required String name,
    required String image,
    required Map<String, dynamic> location,
    required DocumentReference owner,
    required int price,
    required String type,
    required Map<String, dynamic> distance,
    required Map<String, dynamic> features,
    required Map<String, dynamic> services,
    required String timePeriod,
    required this.rules,
  }) : super(
          name: name,
          image: image,
          location: location,
          owner: owner,
          price: price,
          type: type,
          distance: distance,
          features: features,
          services: services,
          timePeriod: timePeriod,
        );

  factory Roomie.fromMap(Map<String, dynamic> map) {
    return Roomie(
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      location: map['location'] as Map<String, dynamic>,
      owner: map['owner'], // Aquí deberías manejar la conversión a la referencia del documento
      price: map['price'] ?? 0,
      type: map['type'] ?? '',
      distance: map['distance'] as Map<String, dynamic>,
      features: map['features'] as Map<String, dynamic>,
      services: map['services'] as Map<String, dynamic>,
      timePeriod: map['time_period'] ?? '',
      rules: List<String>.from(map['rules'] ?? []),
    );
  }

 @override
Widget buildDetailWidget() {
  LatLng initialCameraPosition = LatLng(
    location['gps'].latitude, // Asumiendo que 'gps' es un objeto LatLng
    location['gps'].longitude,
  );

  Set<Marker> markers = {
    Marker(
      markerId: const MarkerId('propertyLocation'),
      position: initialCameraPosition,
      infoWindow: const InfoWindow(title: 'Ubicación de la Propiedad'),
    ),
  };

  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // CarouselSlider para las imágenes
          CarouselSlider(
            options: CarouselOptions(
              aspectRatio: 2.0,
              enlargeCenterPage: true,
              enableInfiniteScroll: false,
              initialPage: 0,
              autoPlay: true,
            ),
            items: [
              Image.network(
                image.isNotEmpty ? image : 'web/assets/yoshi_waton.jpg',
                fit: BoxFit.cover,
                width: 1000.0,
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          // Sección de Precio
          Text(
            'Precio: \$${price.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),

          // Divisor
          const Divider(),

          // Sección de Descripción
          Text(
            'Descripción: ${location['description']}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),

          // Divisor
          const Divider(),

          // Sección de Tiempo a la universidad
          Text(
            'Tiempo a la universidad: ${distance['time']}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),

          // Divisor
          const Divider(),

          // Sección de Reglas
          Text(
            'Reglas:',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ...rules.map((rule) => Text('• $rule')).toList(),
          const SizedBox(height: 10),

          // Divisor
          const Divider(),

          // Sección de Servicios
          Text(
            'Servicios:',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text('Transporte público: ${services['public_transport']}'),
          Text('Áreas verdes: ${services['green_areas']}'),
          // ...añade aquí más campos si son necesarios...
          SizedBox(height: 20),
          // Widget de Google Maps
          SizedBox(
            height: 200,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: initialCameraPosition,
                zoom: 17,
              ),
              markers: markers,
            ),
          ),
        ],
      ),
    ),
  );
}
}

class Pension extends Property {
  final List<Map<String, dynamic>> availableRooms;

  Pension({
    required String name,
    required String image,
    required Map<String, dynamic> location,
    required DocumentReference owner,
    required int price,
    required String type,
    required Map<String, dynamic> distance,
    required Map<String, dynamic> features,
    required Map<String, dynamic> services,
    required String timePeriod,
    required this.availableRooms,
  }) : super(
          name: name,
          image: image,
          location: location,
          owner: owner,
          price: price,
          type: type,
          distance: distance,
          features: features,
          services: services,
          timePeriod: timePeriod,
        );

  factory Pension.fromMap(Map<String, dynamic> map) {
    return Pension(
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      location: map['location'] ?? {},
      owner: map['owner'],
      price: map['price'] ?? 0,
      type: map['type'] ?? '',
      distance: map['distance'] ?? {},
      features: map['features'] ?? {},
      services: map['services'] ?? {},
      timePeriod: map['time_period'] ?? '',
      availableRooms: List<Map<String, dynamic>>.from(map['available_rooms'] ?? []),
    );
  }

@override
Widget buildDetailWidget() {
    LatLng initialCameraPosition = LatLng(
    location['gps'].latitude, // Asumiendo que 'gps' es un objeto LatLng
    location['gps'].longitude,
  );

  Set<Marker> markers = {
    Marker(
      markerId: const MarkerId('propertyLocation'),
      position: initialCameraPosition,
      infoWindow: const InfoWindow(title: 'Ubicación de la Propiedad'),
    ),
  };
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mostrar el nombre
        Text(
          name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
  
        // Mostrar la imagen
        Image.network(
          image,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 200.0,
        ),
        const SizedBox(height: 10),
  
        // Mostrar el precio
        Text(
          'Precio: \$${price.toStringAsFixed(0)}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
  
        const Divider(),
  
        // Mostrar las características de las habitaciones disponibles
        const Text(
          'Habitaciones Disponibles:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ...availableRooms.map((room) => Text('Habitación: ${room['square_meters']} m², Baño: ${room['bathrooms']}')),
        const SizedBox(height: 10),
  
        const Divider(),
  
        // Mostrar la distancia a la universidad
        Text(
          'Distancia a la universidad: ${distance['time']}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 10),
  
        const Divider(),
  
        // Mostrar servicios
        const Text(
          'Servicios:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text('Internet: ${services['internet']}'),
        Text('Transporte Público: ${services['public_transport']}'),
        // ... otros servicios ...
  
        const SizedBox(height: 10),
  
        const Divider(),
  
        // Mostrar la descripción
        const Text(
          'Descripción:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(location['description']),
        const Divider(),
        // Widget de Google Maps
        SizedBox(
          height: 200,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialCameraPosition,
              zoom: 17,
            ),
            markers: markers,
          ),
        ),
      ],
    ),
  );
}
}


class Departamento extends Property {
  final int commonExpenses;

  Departamento({
    required String name,
    required String image,
    required Map<String, dynamic> location,
    required DocumentReference owner,
    required int price,
    required String type,
    required Map<String, dynamic> distance,
    required Map<String, dynamic> features,
    required Map<String, dynamic> services,
    required String timePeriod,
    required this.commonExpenses,
  }) : super(
          name: name,
          image: image,
          location: location,
          owner: owner,
          price: price,
          type: type,
          distance: distance,
          features: features,
          services: services,
          timePeriod: timePeriod,
        );

  factory Departamento.fromMap(Map<String, dynamic> map) {
    return Departamento(
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      location: map['location'] as Map<String, dynamic>,
      owner: map['owner'], // Asegúrate de que este campo se maneje correctamente como referencia
      price: map['price'] ?? 0,
      type: map['type'] ?? '',
      distance: map['distance'] as Map<String, dynamic>,
      features: map['features'] as Map<String, dynamic>,
      services: map['services'] as Map<String, dynamic>,
      timePeriod: map['time_period'] ?? '',
      commonExpenses: map['common expenses'] ?? 0,
    );
  }

@override
Widget buildDetailWidget() {
    LatLng initialCameraPosition = LatLng(
    location['gps'].latitude, // Asumiendo que 'gps' es un objeto LatLng
    location['gps'].longitude,
  );

  Set<Marker> markers = {
    Marker(
      markerId: const MarkerId('propertyLocation'),
      position: initialCameraPosition,
      infoWindow: const InfoWindow(title: 'Ubicación de la Propiedad'),
    ),
  };
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Image.network(
          image,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 200.0, // Ajusta según sea necesario
        ),
        const SizedBox(height: 8),
  
        const Divider(),
  
        Text(
          'Precio: \$${price.toStringAsFixed(0)}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
  
        const Divider(),
  
        Text(
          'Gastos comunes: \$${commonExpenses.toStringAsFixed(0)}',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 8),
  
        const Divider(),
  
        Text(
          'Ubicación: ${location['address']}',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 8),
  
        const Divider(),
  
        Text(
          'Descripción: ${location['description']}',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 8),
  
        const Divider(),
  
        // Aquí puedes agregar más detalles como características y servicios
        // Por ejemplo:
        Text(
          'Características:',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text('Baños: ${features['bathrooms']}'),
        Text('Habitaciones: ${features['rooms']}'),
        // ... más características y servicios ...
                // Widget de Google Maps
                        const Divider(),
          SizedBox(
            height: 200,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: initialCameraPosition,
                zoom: 17,
              ),
              markers: markers,
            ),
          ),
        // ... más campos si son necesarios ...
      ],
    ),
  );
}
}

Query buildPropertyQuery({
  required bool showPensiones,
  required bool showRoomies,
  required bool showArriendos,
  required String searchText,
}) {
  Query query = FirebaseFirestore.instance.collection('properties');

  // Filtrar por tipo
  if (showPensiones || showRoomies || showArriendos) {
    List<String> types = [];
    if (showPensiones) types.add('pension');
    if (showRoomies) types.add('roomie');
    if (showArriendos) types.add('departamento');
    query = query.where('type', whereIn: types);
  }

  if (searchText.isNotEmpty) {
    // Implementa la lógica de búsqueda de subcadenas aquí
    String searchLower = searchText.toLowerCase();
    String searchUpper = searchText.toLowerCase().replaceRange(
      searchText.length - 1,
      searchText.length,
      String.fromCharCode(searchText.codeUnitAt(searchText.length - 1) + 1),
    );

    query = query.where('name', isGreaterThanOrEqualTo: searchLower)
                 .where('name', isLessThan: searchUpper);
  }

  return query;
}


class PropertyList extends StatelessWidget {
  final Query query;
  // final bool showPensiones;
  // final bool showRoomies;
  // final bool showArriendos;
  // final String searchText;



  const PropertyList({
    super.key,
    // required this.showPensiones,
    // required this.showRoomies,
    // required this.showArriendos,
    // required this.searchText,
    required this.query

  });
  


  
  @override
  Widget build(BuildContext context) {

    return StreamBuilder(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data?.docs.isEmpty == true) {
          return const Center(child: Text('No data available'));
        }

        final List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
        final List<Property> properties = documents.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        switch (data['type']) {
          case 'roomie':
            return Roomie.fromMap(data);
          case 'pension':
            return Pension.fromMap(data);
          case 'departamento':
            return Departamento.fromMap(data);
          default:
            return Property.fromMap(data); // O manejar de alguna manera si el tipo no es reconocido
        }
}).toList();
        return ListView.builder(
          itemCount: properties.length,
          itemBuilder: (context, index) {
            final property = properties[index];
            return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PropertyDetailsScreen(property: property),
                    ),
                  );
                },
child: Card(
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 4,
      child: Column(
        children: [
ClipRRect(
  borderRadius: const BorderRadius.only(
    topLeft: Radius.circular(8.0),
    topRight: Radius.circular(8.0),
  ),
  child: property.image.isNotEmpty 
    ? Image.network(
        property.image,
        width: double.infinity,
        height: 150.0,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'web\asset\yoshi_waton.jpg', // Ruta a tu imagen placeholder local
            width: double.infinity,
            height: 150.0,
            fit: BoxFit.cover,
          );
        },
      )
    : Image.asset(
        'web/assets/yoshi_waton.jpg', // Ruta a tu imagen placeholder local
        width: double.infinity,
        height: 150.0,
        fit: BoxFit.cover,
      ),
),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(
                property.name,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // Asumiendo que distance es un mapa con la clave 'time'
                    'Tiempo a la universidad: ${property.distance['time'] ?? 'No disponible'}',
                    style: const TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                  Text(
                    '\$${property.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
);
          },
        );
      },
    );
  }
}


class PropertyDetailsScreen extends StatelessWidget {
  final Property property;

  const PropertyDetailsScreen({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(property.name),
      ),
      body: SingleChildScrollView(
        child: property.buildDetailWidget(),
      ),
    );
  }
}