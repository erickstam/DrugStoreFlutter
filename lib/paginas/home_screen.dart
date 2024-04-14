
import 'package:drugstore/widgets/login.dart';
import 'package:flutter/material.dart';

import '../widgets/ProductsList.dart';

class Login extends StatelessWidget {

  const Login({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const login(),
    );
  }
}
