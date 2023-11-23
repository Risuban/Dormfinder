import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_application_1/main.dart';
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
                FadeInImage(
                  placeholder: const NetworkImage(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/Placeholder_view_vector.svg/310px-Placeholder_view_vector.svg.png',
                  ), // Imagen gris como placeholder
                  image: image.isNotEmpty
                      ? NetworkImage(image)
                      : const NetworkImage(
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/Placeholder_view_vector.svg/310px-Placeholder_view_vector.svg.png',
                        ), // Imagen gris como placeholder
                  width: double.infinity,
                  height: 150.0,
                  fit: BoxFit.cover,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style:
                  const TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
            ),
            Text(
              '\$ $price',
              style:
                  const TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
            ),
            
            const SizedBox(height: 10),

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
            const Text(
              'Reglas:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...rules.map((rule) => Text('• $rule')).toList(),
            const SizedBox(height: 10),

            // Divisor
            const Divider(),

            // Sección de Servicios
            const Text(
              'Servicios:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('Transporte público: ${services['public_transport']}'),
            Text('Áreas verdes: ${services['green_areas']}'),
            // ...añade aquí más campos si son necesarios...
            const SizedBox(height: 20),
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
            IconButton(
              icon: Icon(
                userModel.savedProperties.contains(propertyReference)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: Colors.red,
              ),
              onPressed: () {
                // Asegúrate de pasar 'propertyReference' a 'toggleFavorite'
                userModel.toggleFavorite(context, propertyReference);
              },
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
          Text(
            name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Mostrar la imagen
          FadeInImage(
            placeholder: const NetworkImage(
              'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/Placeholder_view_vector.svg/310px-Placeholder_view_vector.svg.png',
            ), // Imagen gris como placeholder
            image: image.isNotEmpty
                ? NetworkImage(image)
                : const NetworkImage(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/Placeholder_view_vector.svg/310px-Placeholder_view_vector.svg.png',
                  ), // Imagen gris como placeholder
            width: double.infinity,
            height: 150.0,
            fit: BoxFit.cover,
          ),

          const SizedBox(height: 10),

          // Mostrar el precio
            Text(
              '\$ $price',
              style:
                  const TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
            ),
          // Mostrar las características de las habitaciones disponibles
          const Text(
            'Habitaciones Disponibles:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ...availableRooms.map((room) => Text(
              'Habitación: ${room['square_meters']} m², Baño: ${room['bathrooms']}')),
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
          IconButton(
            icon: Icon(
              userModel.savedProperties.contains(propertyReference)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: () {
              // Llama al método y proporciona el BuildContext
              userModel.toggleFavorite(context, propertyReference);
            },
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
          Text(
            name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
                      Text(
              '\$ $price',
              style:
                  const TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
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
          const Text(
            'Características:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
          IconButton(
            icon: Icon(
              userModel.savedProperties.contains(propertyReference)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              // Llama al método y proporciona el BuildContext
              userModel.toggleFavorite(context, propertyReference);
            },
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
                            style:  TextStyle(
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
                                    style:  TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                  Text(
                                    '\$${property.price.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface,
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
                                  color:  userModel.savedProperties
                                          .contains(property.propertyReference) ?  Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant ,
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
        title: Text(property.name),
      ),
      body: SingleChildScrollView(
        child: property.buildDetailWidget(context),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text("Llamar"),
        tooltip: "Contactarse con Arrendatario",
        foregroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () => _contactOwner(property.owner),
        icon: const Icon(Icons.phone),
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
