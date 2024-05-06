import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../Helpers/PharmacyHelper.dart';
import '../Manager/ApiManager.dart';

class ProductDetailScreen extends StatefulWidget {
  final dynamic item;

  ProductDetailScreen({required this.item});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<dynamic> futureNearbyPharmacies;
  final ApiManager apiManager = ApiManager();
  final PharmacyHelper pharmacyHelper = PharmacyHelper(apiManager: ApiManager());

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
        futureNearbyPharmacies = pharmacyHelper.fetchNearbyPharmacies(
          'https://pharmacylocation.azurewebsites.net/api/pharmacy/products/${widget.item['id']}',
          position.latitude,
          position.longitude,
        );
      });
    } catch (e) {
      setState(() {
        futureNearbyPharmacies = Future.error('Failed to get location: $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.item['description']['name'],
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
              pharmacyHelper.buildNearbyPharmaciesWidget(futureNearbyPharmacies, context),
            ],
          ),
        ),
      ),
    );
  }
}
