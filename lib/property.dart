import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_application_1/main.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final DocumentReference propertyReference;

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
    required this.propertyReference,
  });

  factory Property.fromMap(
      Map<String, dynamic> map, DocumentReference propertyReference) {
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
      propertyReference: propertyReference,
    );
  }

  // Método buildDetailWidget a ser implementado en las subclases
  Widget buildDetailWidget(BuildContext context) {
    // Implementación por defecto o lanzar una excepción si se espera que las subclases lo implementen
    throw UnimplementedError(
        'buildDetailWidget debe ser implementado en subclases de Property.');
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
    required DocumentReference propertyReference,
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
          propertyReference: propertyReference,
        );

  factory Roomie.fromMap(
      Map<String, dynamic> map, DocumentReference propertyReference) {
    return Roomie(
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      location: map['location'] as Map<String, dynamic>,
      owner: map[
          'owner'], // Aquí deberías manejar la conversión a la referencia del documento
      price: map['price'] ?? 0,
      type: map['type'] ?? '',
      distance: map['distance'] as Map<String, dynamic>,
      features: map['features'] as Map<String, dynamic>,
      services: map['services'] as Map<String, dynamic>,
      timePeriod: map['time_period'] ?? '',
      rules: List<String>.from(map['rules'] ?? []),
      propertyReference: propertyReference,
    );
  }

  @override
  Widget buildDetailWidget(BuildContext context) {
    UserModel userModel = Provider.of<UserModel>(context);
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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 250.0,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20.0),
                  image: DecorationImage(
                    image: NetworkImage(
                      image,
                    ),
                    fit: BoxFit.cover,
                  )),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // type with first letter in uppercase
                      type[0].toUpperCase() + type.substring(1),
                      style: const TextStyle(
                          fontSize: 15.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name,
                      style: const TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.grey,
                        size: 20.0,
                      ),
                      // Sección de Tiempo a la universidad
                      Row(
                        children: [
                          Text(
                            'A ${distance['time']} de la ${distance['university']}',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ]),
                  ],
                ),
                const Spacer(),
                // Boton para guardar a favoritos centrado en la columna
                IconButton(
                  tooltip: "Agregar a favoritos",
                  icon: Icon(
                    userModel.savedProperties.contains(propertyReference)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: userModel.savedProperties.contains(propertyReference)
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 40,
                  ),
                  onPressed: () {
                    // Asegúrate de pasar 'propertyReference' a 'toggleFavorite'
                    userModel.toggleFavorite(context, propertyReference);
                  },
                ),
              ],
            ),
            // Imprimir características
            const Divider(),
            const Text(
              'Características',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.bathtub_rounded),
                const SizedBox(width: 5),
                Text('${features['bathrooms']} baños'),
                // rellenar el espacio
                const Spacer(),
                const Icon(Icons.king_bed_rounded),
                const SizedBox(width: 5),
                Text('${features['rooms']} habitaciones'),
              ],
            ),
            // Divisor
            const SizedBox(height: 8),
            const Divider(),

            // Sección de Reglas
            const Text(
              'Reglas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...rules
                .map((rule) => Text(
                      '• $rule',
                    ))
                .toList(),
            // Divisor
            const Divider(),

            // Sección de Servicios
            const Text(
              'Servicios',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),
            Column(
              children: [
                if (services.containsKey('public_transport'))
                  Row(
                    children: [
                      //icono transporte
                      const Icon(Icons.directions_bus_rounded),
                      const SizedBox(width: 5),
                      Text(services['public_transport']),
                    ],
                  ),
                if (services.containsKey('internet'))
                  Row(
                    children: [
                      //icono wifi
                      const Icon(Icons.wifi_rounded),
                      const SizedBox(width: 5),
                      Text(services['internet']),
                    ],
                  ),
                if (services.containsKey('green_areas'))
                  Row(
                    children: [
                      //icono parque
                      const Icon(Icons.park_rounded),
                      const SizedBox(width: 5),
                      Text(services['green_areas']),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 8),

            const Divider(),

            const SizedBox(height: 8),
            // Sección de Mapa
            const Text(
              'Ubicación',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.location_on_rounded),
                const SizedBox(width: 5),
                Text(location['address']),
              ],
            ),
            Center(
                child: Text(
              location['description'],
              overflow: TextOverflow.ellipsis,
            )),
            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              height: 200,
              // Apply ROUNDED EDGES using ClipRRect
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(20.0), // Adjust the radius as needed
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: initialCameraPosition,
                    zoom: 17,
                  ),
                  markers: markers,
                ),
              ),
            )
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
    required DocumentReference propertyReference,
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
          propertyReference: propertyReference,
        );

  factory Pension.fromMap(
      Map<String, dynamic> map, DocumentReference propertyReference) {
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
      availableRooms:
          List<Map<String, dynamic>>.from(map['available_rooms'] ?? []),
      propertyReference: propertyReference,
    );
  }

  @override
  Widget buildDetailWidget(BuildContext context) {
    UserModel userModel = Provider.of<UserModel>(context);
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

          Container(
            width: double.infinity,
            height: 250.0,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(20.0),
                image: DecorationImage(
                  image: NetworkImage(
                    image,
                  ),
                  fit: BoxFit.cover,
                )),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // type with first letter in uppercase
                    type[0].toUpperCase() + type.substring(1),
                    style: const TextStyle(
                        fontSize: 15.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    style: const TextStyle(
                        fontSize: 20.0, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.grey,
                      size: 20.0,
                    ),
                    // Sección de Tiempo a la universidad
                    Row(
                      children: [
                        Text(
                          'A ${distance['time']} de la ${distance['university']}',
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ]),
                ],
              ),
              const Spacer(),
              // Boton para guardar a favoritos centrado en la columna
              IconButton(
                tooltip: "Agregar a favoritos",
                icon: Icon(
                  userModel.savedProperties.contains(propertyReference)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: userModel.savedProperties.contains(propertyReference)
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 40,
                ),
                onPressed: () {
                  // Asegúrate de pasar 'propertyReference' a 'toggleFavorite'
                  userModel.toggleFavorite(context, propertyReference);
                },
              ),
            ],
          ),
          const Divider(),
          const Text(
            'Características',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.bathtub_rounded),
              const SizedBox(width: 5),
              Text('${features['bathrooms']} baños'),
              // rellenar el espacio
              const Spacer(),
              const Icon(Icons.king_bed_rounded),
              const SizedBox(width: 5),
              Text('${features['rooms']} habitaciones'),
            ],
          ),
          // Divisor
          const SizedBox(height: 8),
          const Divider(),

          // Mostrar las características de las habitaciones disponibles
          const Text(
            'Habitaciones Disponibles',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ...availableRooms.map((room) => Card(
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      width: 120,
                      height: 80,
                      // Replace the BoxDecorator with the actual room image
                      // You can use Image.network or any other method to display the image
                    ),
                    const SizedBox(width: 20),
                    Column(
                      // text ''habitacion
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // print the title with an index for each room

                        Text(
                          'Habitación ${availableRooms.indexOf(room) + 1}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            //icon for size
                            const Icon(Icons.square_foot_rounded),
                            const SizedBox(width: 5),
                            Text('${room['square_meters']} m²'),
                          ],
                        ),
                        Row(
                          children: [
                            // icon toilet
                            const Icon(Icons.bathtub_rounded),
                            const SizedBox(width: 5),
                            Text('Baño ${room['bathrooms']}'),
                          ],
                        ),
                        // Add other room information here
                      ],
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 10),
          const Divider(),

          // Sección de Servicios
          const Text(
            'Servicios',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),
          Column(
            children: [
              if (services.containsKey('public_transport'))
                Row(
                  children: [
                    //icono transporte
                    const Icon(Icons.directions_bus_rounded),
                    const SizedBox(width: 5),
                    Text(services['public_transport']),
                  ],
                ),
              if (services.containsKey('internet'))
                Row(
                  children: [
                    //icono wifi
                    const Icon(Icons.wifi_rounded),
                    const SizedBox(width: 5),
                    Text(services['internet']),
                  ],
                ),
              if (services.containsKey('green_areas'))
                Row(
                  children: [
                    //icono parque
                    const Icon(Icons.park_rounded),
                    const SizedBox(width: 5),
                    Text(services['green_areas']),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 8),

          const Divider(),

          const SizedBox(height: 8),
          // Sección de Mapa
          const Text(
            'Ubicación',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.location_on_rounded),
              const SizedBox(width: 5),
              Text(location['address']),
            ],
          ),
          Center(
              child: Text(
            location['description'],
            overflow: TextOverflow.ellipsis,
          )),
          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            height: 200,
            // Apply ROUNDED EDGES using ClipRRect
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(20.0), // Adjust the radius as needed
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: initialCameraPosition,
                  zoom: 17,
                ),
                markers: markers,
              ),
            ),
          )
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
    required DocumentReference propertyReference,
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
          propertyReference: propertyReference,
        );

  factory Departamento.fromMap(
      Map<String, dynamic> map, DocumentReference propertyReference) {
    return Departamento(
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      location: map['location'] as Map<String, dynamic>,
      owner: map[
          'owner'], // Asegúrate de que este campo se maneje correctamente como referencia
      price: map['price'] ?? 0,
      type: map['type'] ?? '',
      distance: map['distance'] as Map<String, dynamic>,
      features: map['features'] as Map<String, dynamic>,
      services: map['services'] as Map<String, dynamic>,
      timePeriod: map['time_period'] ?? '',
      commonExpenses: map['common expenses'] ?? 0,
      propertyReference: propertyReference,
    );
  }

  @override
  Widget buildDetailWidget(BuildContext context) {
    UserModel userModel = Provider.of<UserModel>(context);
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
          Container(
            width: double.infinity,
            height: 250.0,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(20.0),
                image: DecorationImage(
                  image: NetworkImage(
                    image,
                  ),
                  fit: BoxFit.cover,
                )),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 270,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // type with first letter in uppercase
                      type[0].toUpperCase() + type.substring(1),
                      style: const TextStyle(
                          fontSize: 15.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name,
                      style: const TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.clip,
                    ),
                    const SizedBox(height: 2),
                    Row(children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.grey,
                        size: 20.0,
                      ),
                      // Sección de Tiempo a la universidad
                      Row(
                        children: [
                          Text(
                            'A ${distance['time']} de la ${distance['university']}',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ]),
                  ],
                ),
              ),
              const Spacer(),
              // Boton para guardar a favoritos centrado en la columna
              IconButton(
                tooltip: "Agregar a favoritos",
                icon: Icon(
                  userModel.savedProperties.contains(propertyReference)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: userModel.savedProperties.contains(propertyReference)
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 40,
                ),
                onPressed: () {
                  // Asegúrate de pasar 'propertyReference' a 'toggleFavorite'
                  userModel.toggleFavorite(context, propertyReference);
                },
              ),
            ],
          ),
          // Imprimir características
          const Divider(),
          Row(
            children: [
              // icon money
              const Icon(FontAwesomeIcons.moneyBill),
              const SizedBox(width: 8),
              Text(
                '\$${commonExpenses.toStringAsFixed(0)} de Gastos Comunes',
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),

// Sección de Servicios
          const Text(
            'Servicios',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),
          Column(
            children: [
              if (services.containsKey('public_transport'))
                Row(
                  children: [
                    //icono transporte
                    const Icon(Icons.directions_bus_rounded),
                    const SizedBox(width: 5),
                    Text(services['public_transport']),
                  ],
                ),
              if (services.containsKey('internet'))
                Row(
                  children: [
                    //icono wifi
                    const Icon(Icons.wifi_rounded),
                    const SizedBox(width: 5),
                    Text(services['internet']),
                  ],
                ),
              if (services.containsKey('green_areas'))
                Row(
                  children: [
                    //icono parque
                    const Icon(Icons.park_rounded),
                    const SizedBox(width: 5),
                    Text(services['green_areas']),
                  ],
                ),
              if (services.containsKey('gym'))
                Row(
                  children: [
                    //icono gym
                    const Icon(Icons.fitness_center_rounded),
                    const SizedBox(width: 5),
                    // overflow text to the next line
                    SizedBox(
                      width: 250,
                      child: Text(
                        services['gym'],
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 8),

          const Divider(),

          const SizedBox(height: 8),
          // Sección de Mapa
          const Text(
            'Ubicación',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.location_on_rounded),
              const SizedBox(width: 5),
              Text(location['address']),
            ],
          ),
          Center(
              child: Text(
            location['description'],
            overflow: TextOverflow.ellipsis,
          )),
          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            height: 200,
            // Apply ROUNDED EDGES using ClipRRect
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(20.0), // Adjust the radius as needed
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: initialCameraPosition,
                  zoom: 17,
                ),
                markers: markers,
              ),
            ),
          )
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

    query = query
        .where('name', isGreaterThanOrEqualTo: searchLower)
        .where('name', isLessThan: searchUpper);
  }

  return query;
}

class PropertyList extends StatelessWidget {
  final Query query;

  const PropertyList({Key? key, required this.query}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    UserModel userModel = Provider.of<UserModel>(context);
    // Utiliza una clave única para el ListView.builder
    GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

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
              return Roomie.fromMap(data, doc.reference);
            case 'pension':
              return Pension.fromMap(data, doc.reference);
            case 'departamento':
              return Departamento.fromMap(data, doc.reference);
            default:
              return Property.fromMap(data, doc.reference);
          }
        }).toList();

        return ListView.builder(
          key: listKey, // Asigna la clave única al ListView.builder
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Card(
                  color: Theme.of(context).colorScheme.surface,
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
                        child: FadeInImage(
                          placeholder: const NetworkImage(
                            'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/Placeholder_view_vector.svg/310px-Placeholder_view_vector.svg.png',
                          ),
                          image: property.image.isNotEmpty
                              ? NetworkImage(property.image)
                              : const NetworkImage(
                                  'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/Placeholder_view_vector.svg/310px-Placeholder_view_vector.svg.png',
                                ),
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
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'A ${property.distance['time']} de ${property.distance['university']}',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                  Text(
                                    '\$${property.price.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                tooltip: "Agregar a favoritos",
                                icon: Icon(
                                  userModel.savedProperties
                                          .contains(property.propertyReference)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: userModel.savedProperties
                                          .contains(property.propertyReference)
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                ),
                                onPressed: () {
                                  // Asegúrate de pasar 'propertyReference' a 'toggleFavorite'
                                  userModel.toggleFavorite(
                                      context, property.propertyReference);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
        title: Text(
          property.name,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        child: property.buildDetailWidget(context),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).colorScheme.surface,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Precio: \$${property.price}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: ElevatedButton(
                onPressed: () => _contactOwner(property.owner),
                style: ElevatedButton.styleFrom(
                  primary:
                      Theme.of(context).primaryColor, // Color primario oscuro
                ),
                child: Text(
                  'Contactar',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _contactOwner(DocumentReference ownerReference) async {
    try {
      final ownerDoc = await ownerReference.get();
      final data = ownerDoc.data() as Map<String, dynamic>?;
      final phoneNumber = data?['phone'] as String?;
      final Uri phoneUri = Uri.parse('tel:$phoneNumber');
      launchUrl(phoneUri);
    } catch (e) {
      // Manejar cualquier error que pueda ocurrir durante la obtención del documento o el lanzamiento
    }
  }
}
