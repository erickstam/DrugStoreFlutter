import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../Manager/ApiManager.dart';
import 'Enums.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:url_launcher/url_launcher.dart';

class PharmacyHelper {
  final ApiManager apiManager;

  PharmacyHelper({required this.apiManager});

  Future<dynamic> fetchNearbyPharmacies(String apiUrl, double latitude, double longitude) async {
    try {
      String url = '$apiUrl?latitude=$latitude&longitude=$longitude';
      return await apiManager.fetchDataFromApi(
        url: url,
        method: HttpMethod.GET,
        body: null,
      );
    } catch (e) {
      throw Exception('Failed to load nearby pharmacies: $e');
    }
  }

  Widget buildNearbyPharmaciesWidget(
      Future<dynamic> futureNearbyPharmacies, BuildContext context) {
    return FutureBuilder(
      future: futureNearbyPharmacies,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return _buildNearbyPharmacies(snapshot.data, context);
        }
      },
    );
  }

  Widget _buildNearbyPharmacies(dynamic data, BuildContext context) {
    final List<dynamic> nearbyPharmacies = data;

    return Column(
      children: [
        for (var pharmacy in nearbyPharmacies)
          _buildPharmacyCard(pharmacy, context),
      ],
    );
  }

  Widget _buildPharmacyCard(dynamic pharmacy, BuildContext context) {
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
            _buildDistanceInfo('A pie', Icons.directions_walk, pharmacy, TransportType.Walk,context),
            _buildDistanceInfo('En coche promedio', Icons.directions_car, pharmacy, TransportType.Drive,context),
            _buildDistanceInfo('En coche con tráfico actual', Icons.traffic, pharmacy, TransportType.DriveWithTraffic,context),
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
                      _showModal( pharmacy['pharmacyOutput']['description']['name'],pharmacy['pharmacyOutput']['pharmacySchedules'], context);
                    },
                    child: Text('Horarios'),
                  ),
                ElevatedButton(
                  onPressed: () {
                    _showMapModal(
                      pharmacy['pharmacyOutput']['description']['name'],
                      pharmacy['pharmacyOutput']['location']['latitude'],
                      pharmacy['pharmacyOutput']['location']['longitude'],
                      context,
                    );
                  },
                  child: Text('Ubicación'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistanceInfo(String title, IconData icon, dynamic pharmacy, TransportType transportType, BuildContext context) {
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
        trailing: ElevatedButton(
          onPressed: () {
            _showRoute(
              title + " a "+ pharmacy['pharmacyOutput']['description']['name'],
              pharmacy['pharmacyOutput']['location']['latitude'],
              pharmacy['pharmacyOutput']['location']['longitude'],
              transportType,
              context,
            );
          },
          style: ElevatedButton.styleFrom(
          ),
          child: Text('Ver Ruta'),
        ),
        onTap: () {
          // Implementar acción si es necesario
        },
      ),
    );
  }


  void _showRoute(String pharmacyName, double pharmacyLatitude, double pharmacyLongitude, TransportType transportType, BuildContext context) async {
    try {
      // Obtener la posición actual del usuario
      Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Configurar la solicitud a la API de Mapbox Directions
      String accessToken = '';
      String apiUrl = 'api.mapbox.com';
      String directionsType;

      // Determinar el tipo de direcciones según el tipo de transporte seleccionado
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
          directionsType = 'driving'; // Valor predeterminado si el tipo de transporte no está definido correctamente
          break;
      }

      String path = '/directions/v5/mapbox/$directionsType/' +
          '${currentPosition.longitude},${currentPosition.latitude};' +
          '${pharmacyLongitude},${pharmacyLatitude}';

      // Parámetros de la solicitud
      Map<String, String> queryParams = {
        'alternatives': 'false',
        'continue_straight': 'false',
        'geometries': 'polyline',
        'overview': 'simplified',
        'steps': 'true',
        'access_token': accessToken,
      };

      // Construir la URL completa con parámetros de consulta
      Uri uri = Uri.https(apiUrl, path, queryParams);

      // Realizar la solicitud HTTP
      var response = await http.get(uri);

      if (response.statusCode == 200) {
        // Procesar la respuesta exitosa
        Map<String, dynamic> data = jsonDecode(response.body);

        // Obtener la geometría codificada de la ruta
        String encodedGeometry = data['routes'][0]['geometry'];

        // Decodificar la geometría usando flutter_polyline_points
        List<PointLatLng> polylinePoints = PolylinePoints().decodePolyline(encodedGeometry);

        // Convertir los puntos decodificados a LatLng para usarlos en la ruta del mapa
        List<LatLng> polylineCoordinates = [];
        for (PointLatLng point in polylinePoints) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }

        // Mostrar la ruta en un modal bottom sheet con GoogleMap y diseño personalizado
        showModalBottomSheet(
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          backgroundColor: Colors.white,
          builder: (BuildContext context) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Stack(
                children: [
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          pharmacyName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(currentPosition.latitude, currentPosition.longitude),
                              zoom: 14,
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
                                points: polylineCoordinates,
                              ),
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          onPressed: () {
                            launchGoogleMaps(
                              currentPosition.latitude,
                              currentPosition.longitude,
                              pharmacyLatitude,
                              pharmacyLongitude,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.map, color: Colors.white), // Icono de Google Maps
                              SizedBox(width: 8),
                              Text(
                                'Abrir en Google Maps',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        margin: EdgeInsets.all(16.0),
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.red[700],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      } else {
        throw Exception('Failed to load route. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      // Manejar cualquier error que pueda ocurrir durante la solicitud de la ruta
    }
  }

  static Future<void> launchGoogleMaps(double startLat, double startLng, double destLat, double destLng) async {
    final url = 'https://www.google.com/maps/dir/?api=1&origin=$startLat,$startLng&destination=$destLat,$destLng';

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrlString(url);
      } else {
        throw 'No se pudo lanzar $url';
      }
    } catch (e) {
      print('Error al lanzar Google Maps: $e');
    }
  }
  void _showMapModal(String pharmacyName, double latitude, double longitude, BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          pharmacyName,
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                      ),
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
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    margin: EdgeInsets.all(16.0),
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.red[700],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showModal(String pharmacyName, List<dynamic>? pharmacySchedules, BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        'Horarios de $pharmacyName', // Concatenar el nombre de la farmacia
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red[700],
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: pharmacySchedules?.length ?? 0,
                  itemBuilder: (context, index) {
                    final schedule = pharmacySchedules![index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200], // Color gris claro para el card
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[700]!), // Borde gris oscuro
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
              ),
            ],
          ),
        );
      },
    );
  }


}
