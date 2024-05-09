import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Helpers/Enums.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class PharmacyDetailScreen extends StatelessWidget {
  final dynamic pharmacyData;

  PharmacyDetailScreen({required this.pharmacyData});

  @override
  Widget build(BuildContext context) {
    String pharmacyName = pharmacyData['pharmacyOutput']['description']['name'];
    String description = pharmacyData['pharmacyOutput']['description']['description'];
    double latitude = pharmacyData['pharmacyOutput']['location']['latitude'];
    double longitude = pharmacyData['pharmacyOutput']['location']['longitude'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de la Farmacia'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                pharmacyName,
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.0),
              Text(
                description,
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 24.0),
              Container(
                height: 300, // Altura fija del mapa
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(latitude, longitude),
                      zoom: 15,
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
              SizedBox(height: 24.0),
              _buildMapSection('Ruta a Pie', pharmacyData, TransportType.Walk),
              SizedBox(height: 16.0),
              _buildMapSection('Ruta con el tráfico actual', pharmacyData, TransportType.DriveWithTraffic),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapSection(String title, dynamic pharmacy, TransportType transportType) {
    double pharmacyLatitude = pharmacy['pharmacyOutput']['location']['latitude'];
    double pharmacyLongitude = pharmacy['pharmacyOutput']['location']['longitude'];

    return FutureBuilder<List<LatLng>>(
      future: _getPolylineCoordinates(pharmacy, transportType),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<LatLng>? polylineCoordinates = snapshot.data;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Container(
                height: 300, // Altura fija del mapa en esta sección
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(pharmacyLatitude, pharmacyLongitude),
                      zoom: 12,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId('pharmacy'),
                        position: LatLng(pharmacyLatitude, pharmacyLongitude),
                      ),
                    },
                    polylines: {
                      Polyline(
                        polylineId: PolylineId('route'),
                        color: Colors.blue,
                        width: 5,
                        points: polylineCoordinates!,
                      ),
                    },
                  ),
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                'Tiempo estimado: ${_getTravelTime(pharmacy, transportType)}',
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          );
        }
      },
    );
  }

  Future<List<LatLng>> _getPolylineCoordinates(dynamic pharmacy, TransportType transportType) async {
    double pharmacyLatitude = pharmacy['pharmacyOutput']['location']['latitude'];
    double pharmacyLongitude = pharmacy['pharmacyOutput']['location']['longitude'];

    Position? currentPosition;
    try {
      currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error obtaining current position: $e');
      return []; // Retorna una lista vacía si no se puede obtener la posición actual
    }

    String accessToken = '';
    String apiUrl = 'api.mapbox.com';
    String directionsType;

    switch (transportType) {
      case TransportType.Drive:
        directionsType = 'driving';
        break;
      case TransportType.Walk:
        directionsType = 'walking';
        break;
      case TransportType.DriveWithTraffic:
        directionsType = 'driving-traffic';
        break;
      default:
        directionsType = 'driving';
        break;
    }

    String path = '/directions/v5/mapbox/$directionsType/' +
        '${currentPosition.longitude},${currentPosition.latitude};' +
        '${pharmacyLongitude},${pharmacyLatitude}';

    Map<String, String> queryParams = {
      'alternatives': 'false',
      'continue_straight': 'false',
      'geometries': 'polyline',
      'overview': 'simplified',
      'steps': 'true',
      'access_token': accessToken,
    };

    Uri uri = Uri.https(apiUrl, path, queryParams);

    var response = await http.get(uri);

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      String? encodedGeometry = data['routes'][0]['geometry'];

      List<PointLatLng> polylinePoints = PolylinePoints().decodePolyline(encodedGeometry!);

      List<LatLng> polylineCoordinates = [];
      for (PointLatLng point in polylinePoints) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }

      return polylineCoordinates;
    } else {
      print('Request failed with status: ${response.statusCode}');
      return [];
    }
  }

  String _getTravelTime(dynamic pharmacy, TransportType transportType) {

    String travelTimeText = "";

    switch (transportType) {
      case TransportType.Drive:
        travelTimeText = pharmacy['estimatedTravelTimeDriving'] ?? 'No disponible';
        break;
      case TransportType.Walk:
        travelTimeText = pharmacy['estimatedTravelTimeWalking'] ?? 'No disponible';
        break;
      case TransportType.DriveWithTraffic:
        travelTimeText = pharmacy['estimatedTravelTimeDrivingTraffic'] ?? 'No disponible';
        break;
    }

    return travelTimeText;
  }
}
