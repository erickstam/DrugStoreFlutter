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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nombre: ${widget.item['description']['name']}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Descripción: ${widget.item['description']['description']}',
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: FutureBuilder(
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
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyPharmacies(dynamic data) {
    final List<dynamic> nearbyPharmacies = data;

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Farmacias Cercanas:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            for (var pharmacy in nearbyPharmacies)
              _buildPharmacyCard(pharmacy),
          ],
        ),
      ),
    );
  }

  Widget _buildPharmacyCard(dynamic pharmacy) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        title: Text(
          pharmacy['pharmacyOutput']['description']['name'],
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Text(
              'Distancia a pie: ${pharmacy['distanceInMetersWalking']} metros',
            ),
            Text(
              'Tiempo estimado a pie: ${pharmacy['estimatedTravelTimeWalking']}',
            ),
            Text(
              'Distancia en coche: ${pharmacy['distanceInMetersDriving']} metros',
            ),
            Text(
              'Tiempo estimado en coche: ${pharmacy['estimatedTravelTimeDriving']}',
            ),
            Text(
              'Distancia en coche (tráfico): ${pharmacy['distanceInMetersDrivingTraffic']} metros',
            ),
            Text(
              'Tiempo estimado en coche (tráfico): ${pharmacy['estimatedTravelTimeDrivingTraffic']}',
            ),
            Text(
              'Stock disponible: ${pharmacy['stock']}',
            ),
          ],
        ),
        onTap: () {
          _navigateToPharmacyLocation(
              pharmacy['pharmacyOutput']['location']['latitude'],
              pharmacy['pharmacyOutput']['location']['longitude']);
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
