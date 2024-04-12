import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPagina extends StatefulWidget{
  const MapPagina({super.key});

  @override
  State<MapPagina> createState() => _MapPaginaState();
}

class _MapPaginaState extends State<MapPagina>{
  static const LatLng _pGooglePlex = LatLng(37.4223, -122.0848);
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _pGooglePlex,
          zoom: 13,
        ),
      ),
    );
  }
}