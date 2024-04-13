//import 'package:drugstore/widgets/login.dart';
import 'package:flutter/material.dart';

import '../widgets/ProductsList.dart';

class HomeScreen extends StatelessWidget {

  const HomeScreen({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  ProductsList(apiUrl : "https://pharmacylocation.azurewebsites.net/api/product"),
    );
  }
}
