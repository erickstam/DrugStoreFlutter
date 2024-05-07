import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../Helpers/PharmacyHelper.dart';
import '../Manager/ApiManager.dart'; // Asegúrate de importar correctamente el PharmacyHelper

class Pharmacynearbylist extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PharmacynearbylistState();
  }
}

class _PharmacynearbylistState extends State<Pharmacynearbylist> {
  final PharmacyHelper _pharmacyHelper = PharmacyHelper(apiManager: ApiManager()); // Reemplaza ApiManager() con tu implementación real

  @override
  void initState() {
    super.initState();
    _fetchNearbyPharmacies(); // Llama a la función para obtener las farmacias cercanas
  }

  Future<dynamic> _fetchNearbyPharmacies() async {
    try {
      // Obtener la ubicación actual del dispositivo usando Geolocator
      Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Llamar al método fetchNearbyPharmacies del PharmacyHelper
      return await _pharmacyHelper.fetchNearbyPharmacies(
        'https://pharmacylocation.azurewebsites.net/api/pharmacy',
        currentPosition.latitude,
        currentPosition.longitude,
      );


    } catch (e) {
      print('Error fetching nearby pharmacies: $e');
      // Maneja el error apropiadamente, por ejemplo, mostrando un mensaje de error al usuario.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Farmacias Cercanas'),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _pharmacyHelper.buildNearbyPharmaciesWidget(_fetchNearbyPharmacies(), context),
            ],
          ),
        ),
      ),
    );
  }
}
