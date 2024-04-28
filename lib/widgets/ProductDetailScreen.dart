import 'dart:convert';
import 'package:flutter/material.dart';
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
    bool isOpenAllHours = pharmacy['isOpenAllHours'] ?? false;

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
            _buildDistanceInfo('A pie', Icons.directions_walk, pharmacy),
            _buildDistanceInfo('En coche', Icons.directions_car, pharmacy),
            _buildDistanceInfo('En coche con tráfico', Icons.traffic, pharmacy),
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
                    _navigateToPharmacyLocation(
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

  Widget _buildDistanceInfo(String title, IconData icon, dynamic pharmacy) {
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
        subtitle: Text(
          'Distancia: ${pharmacy['distanceInMetersWalking'] ?? 0} metros\n'
              'Tiempo estimado: ${pharmacy['estimatedTravelTimeWalking'] ?? 'No disponible'}',
          style: TextStyle(color: Colors.black),
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

  void _showModal(List<dynamic> pharmacySchedules) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: ListView.builder(
            itemCount: pharmacySchedules.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text(pharmacySchedules[index]['dayOfWeek']),
                  subtitle: Text(
                    '${pharmacySchedules[index]['openingTime']} - ${pharmacySchedules[index]['closingTime']}',
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
