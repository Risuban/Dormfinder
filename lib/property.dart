import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Property {
  final String name;
  final String info1;
  final String info2;
  final int price;
  final String imageUrl;
  final String? distance; // Make distance nullable
  final GeoPoint? geoPoint; // Make geoPoint nullable

  Property({
    required this.name,
    required this.info1,
    required this.info2,
    required this.price,
    required this.imageUrl,
    this.distance, // Use nullable types
    this.geoPoint, // Use nullable types
  });

  factory Property.fromMap(Map<String, dynamic> map) {
    return Property(
      name: map['name'] ?? '', // Provide a default value if 'name' is missing
      info1:
          map['info1'] ?? '', // Provide a default value if 'info1' is missing
      info2:
          map['info2'] ?? '', // Provide a default value if 'info2' is missing
      price: (map['price'] as num?)?.toInt() ??
          0, // Provide a default value for price
      imageUrl: map['imageUrl'] ??
          '', // Provide a default value if 'imageUrl' is missing
      distance: map['distance'], // Allow null for distance
      geoPoint: map['geopoint'], // Allow null for geoPoint
    );
  }
}

class PropertyList extends StatelessWidget {
  const PropertyList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('properties').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data?.docs.isEmpty == true) {
          return const Center(child: Text('No data available'));
        }

        final List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
        final List<Property> properties = documents
            .map((doc) => Property.fromMap(doc.data() as Map<String, dynamic>))
            .toList();

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
                    borderRadius:
                        BorderRadius.circular(8.0), // Adjusted border radius
                  ),
                  elevation: 4, // Added elevation for a card-like appearance
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft:
                              Radius.circular(8.0), // Adjusted border radius
                          topRight:
                              Radius.circular(8.0), // Adjusted border radius
                        ),
                        child: Image.network(
                          property.imageUrl,
                          width: double.infinity,
                          height: 150.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(
                            8.0), // Added padding to the content
                        child: ListTile(
                          title: Text(
                            property.name,
                            style: const TextStyle(
                              fontSize: 18.0, // Increased font size
                              fontWeight: FontWeight.bold, // Bold text
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                property.info1,
                                style: const TextStyle(
                                  fontSize: 14.0, // Adjusted font size
                                ),
                              ),
                              Text(
                                property.info2,
                                style: const TextStyle(
                                  fontSize: 14.0, // Adjusted font size
                                ),
                              ),
                              Text(
                                '\$${property.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 16.0, // Increased font size
                                  fontWeight: FontWeight.bold, // Bold text
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ));
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
    // Create a LatLng for the initial camera position
    LatLng? initialCameraPosition;
    // Default coordinates
    const defaultLatitude = -33.4523759;
    const defaultLongitude = -70.6662541;
    if (property.geoPoint != null) {
      initialCameraPosition = LatLng(
        property.geoPoint!.latitude,
        property.geoPoint!.longitude,
      );
    } else {
      // Handle the case where geoPoint is null, or provide a default LatLng.
      // For example, using the coordinates of a default location:
      initialCameraPosition = const LatLng(defaultLatitude, defaultLongitude);
    }

    // Create a Set of markers (if needed)
    Set<Marker> markers;

    // ignore: unnecessary_null_comparison
    if (initialCameraPosition != null) {
      markers = {
        Marker(
          markerId: const MarkerId('propertyLocation'),
          position: initialCameraPosition,
          infoWindow: const InfoWindow(title: 'Property Location'),
        ),
      };
    } else {
      // Handle the case where initialCameraPosition is null or provide a default marker location.
      // For example, using the coordinates of a default location:
      markers = {
        const Marker(
          markerId: MarkerId('defaultLocation'),
          position: LatLng(defaultLatitude, defaultLongitude),
          infoWindow: InfoWindow(title: 'Default Location'),
        ),
      };
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalles de propiedades',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              CarouselSlider(
                options: CarouselOptions(
                  aspectRatio: 2.0,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: false,
                  initialPage: 0,
                  autoPlay: true,
                ),
                items: [
                  Image.network(property.imageUrl,
                      fit: BoxFit.cover, width: 1000.0)
                ],
              ),
              ListTile(
                title: Text(
                  property.name,
                  style: const TextStyle(
                    fontSize: 25.0, // Increased font size
                    fontWeight: FontWeight.bold, // Bold text
                  ),
                ),
                subtitle: const Text('PLACEHOLDER DISTANCIA'),
                trailing: IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {},
                  iconSize: 35.0,
                ),
              ),

              const Divider(),

              // 'Caracteristicas' as a title and a two column bullet list below with caracteristicas
              const Text(
                'Caracteristicas',
                style: TextStyle(
                  fontSize: 20.0, // Increased font size
                  fontWeight: FontWeight.bold, // Bold text
                ),
              ),

              // Round user image to the right and name to the left
              Row(
                children: [
                  // Image with rounded corners
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                        50.0), // You can adjust the radius as needed
                    child: const Icon(
                      Icons.person,
                      size: 60,
                    ),
                  ),
                  const SizedBox(
                      width: 16.0), // Add spacing between the image and text
                  // Text widget
                  const Expanded(
                    child: Text(
                      'NAME PLACEHOLDER',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                ],
              ),

              const Divider(),
              Text(property.info1),
              Text(property.info2),
              Text('\$${property.price.toStringAsFixed(0)}'),

              // Google Maps widget
              SizedBox(
                height: 200, // Adjust the height as needed
                child: GoogleMap(
                  // ignore: unnecessary_null_comparison
                  initialCameraPosition: initialCameraPosition != null
                      ? CameraPosition(
                          target: initialCameraPosition,
                          zoom: 17, // Adjust the initial zoom level as needed
                        )
                      : const CameraPosition(
                          target: LatLng(defaultLatitude,
                              defaultLongitude), // Provide default coordinates
                          zoom: 11, // Default zoom level
                        ),
                  markers: markers, // Add your markers
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
