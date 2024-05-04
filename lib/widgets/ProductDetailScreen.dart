import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Helpers/Enums.dart';
import '../Manager/ApiManager.dart';
import 'package:geolocator/geolocator.dart';

class ProductDetailScreen extends StatefulWidget {
  final dynamic item;

  ProductDetailScreen({required this.item});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<dynamic> futureNearbyPharmacies;
  final ApiManager apiManager = ApiManager();

  @override
  void initState() {
    super.initState();
    _getLocationAndFetchData();
  }

  void _getLocationAndFetchData() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        futureNearbyPharmacies = fetchNearbyPharmacies(
            position.latitude, position.longitude);
      });
    } catch (e) {
      setState(() {
        futureNearbyPharmacies = Future.error('Failed to get location: $e');
      });
    }
  }

  Future<dynamic> fetchNearbyPharmacies(
      double latitude, double longitude) async {
    try {
      String apiUrl =
          'https://pharmacylocation.azurewebsites.net/api/pharmacy/products/${widget.item['id']}?latitude=$latitude&longitude=$longitude';

      return await apiManager.fetchDataFromApi(
        url: apiUrl,
        method: HttpMethod.GET,
        body: null,
      );
    } catch (e) {
      throw Exception('Failed to load nearby pharmacies: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Producto'),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nombre: ${widget.item['description']['name']}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 8),
              if (widget.item['urlImage'] != null)
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[700]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      widget.item['urlImage'],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              SizedBox(height: 8),
              Text(
                'Descripción: ${widget.item['description']['description']}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Farmacias Cercanas:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              FutureBuilder(
                future: futureNearbyPharmacies,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    return _buildNearbyPharmacies(snapshot.data);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNearbyPharmacies(dynamic data) {
    final List<dynamic> nearbyPharmacies = data;

    return Column(
      children: [
        for (var pharmacy in nearbyPharmacies)
          _buildPharmacyCard(pharmacy),
      ],
    );
  }

  Widget _buildPharmacyCard(dynamic pharmacy) {
    bool isOpenAllHours = pharmacy['pharmacyOutput']['isOpenAllHours'] ?? false;

    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pharmacy['pharmacyOutput']['description']['name'],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _buildDistanceInfo('A pie', Icons.directions_walk, pharmacy, TransportType.Walk),
            _buildDistanceInfo('En coche', Icons.directions_car, pharmacy,TransportType.Drive),
            _buildDistanceInfo('En coche con tráfico', Icons.traffic, pharmacy,TransportType.DriveWithTraffic),
            SizedBox(height: 8),
            Text(
              'Stock disponible: ${pharmacy['stock'] ?? 0}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isOpenAllHours)
                  Text(
                    'Abierto 24/7',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  )
                else if (pharmacy['pharmacyOutput']['pharmacySchedules'] != null &&
                    (pharmacy['pharmacyOutput']['pharmacySchedules'] as List).isNotEmpty)
                  ElevatedButton(
                    onPressed: () {
                      _showModal(pharmacy['pharmacyOutput']['pharmacySchedules']);
                    },
                    child: Text('Ver horarios'),
                  ),
                TextButton(
                  onPressed: () {
                    _showMapModal(
                      pharmacy['pharmacyOutput']['location']['latitude'],
                      pharmacy['pharmacyOutput']['location']['longitude'],
                    );
                  },
                  child: Text('Ver en mapa'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistanceInfo(String title, IconData icon, dynamic pharmacy, TransportType transportType) {
    String distanceText;
    String travelTimeText;

    switch (transportType) {
      case TransportType.Drive:
        distanceText = 'Distancia: ${pharmacy['distanceInMetersDriving'] ?? 0} metros';
        travelTimeText = 'Tiempo estimado: ${pharmacy['estimatedTravelTimeDriving'] ?? 'No disponible'}';
        break;
      case TransportType.Walk:
        distanceText = 'Distancia: ${pharmacy['distanceInMetersWalking'] ?? 0} metros';
        travelTimeText = 'Tiempo estimado: ${pharmacy['estimatedTravelTimeWalking'] ?? 'No disponible'}';
        break;
      case TransportType.DriveWithTraffic:
        distanceText = 'Distancia: ${pharmacy['distanceInMetersDrivingTraffic'] ?? 0} metros';
        travelTimeText = 'Tiempo estimado: ${pharmacy['estimatedTravelTimeDrivingTraffic'] ?? 'No disponible'}';
        break;
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.black,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              distanceText,
              style: TextStyle(color: Colors.black),
            ),
            Text(
              travelTimeText,
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
        onTap: () {
          // Implementar acción si es necesario
        },
      ),
    );
  }

  void _navigateToPharmacyLocation(double latitude, double longitude) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PharmacyLocationScreen(
          latitude: latitude,
          longitude: longitude,
        ),
      ),
    );
  }

  void _showMapModal(double latitude, double longitude) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(latitude, longitude),
                      zoom: 14,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId('pharmacy'),
                        position: LatLng(latitude, longitude),
                      ),
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cerrar'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showModal(List<dynamic>? pharmacySchedules) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: ListView.builder(
            itemCount: pharmacySchedules?.length ?? 0,
            itemBuilder: (context, index) {
              final schedule = pharmacySchedules![index];
              return Card(
                color: Colors.grey[200], // Color gris claro para el card
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.grey[700]!), // Borde gris oscuro
                ),
                child: ListTile(
                  title: Text(
                    schedule['day'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Horario: ${schedule['openingTime'] ?? ''} - ${schedule['closingTime'] ?? ''}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Abre: ${schedule['openingTime'] ?? ''}',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      Text(
                        'Cierra: ${schedule['closingTime'] ?? ''}',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }


}

class PharmacyLocationScreen extends StatelessWidget {
  final double latitude;
  final double longitude;

  PharmacyLocationScreen({required this.latitude, required this.longitude});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ubicación de la Farmacia'),
      ),
      body: Center(
        child: Text(
          'Latitud: $latitude, Longitud: $longitude',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
