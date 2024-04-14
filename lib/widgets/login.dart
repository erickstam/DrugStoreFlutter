import 'dart:ffi';
import '../paginas/HomePage.dart' as homePage;

import 'package:flutter/material.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  @override
  Widget build(BuildContext context) {

    final GlobalKey<FormState> _formularioEstado = GlobalKey<FormState>();

    return Container(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formularioEstado,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centra los elementos verticalmente
          children: [
            Container(
              margin: EdgeInsets.only(top: 20.0), // Ajusta el valor del margen según tus necesidades
              child: Image.asset(
                'assets/login.png',
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey),
              ),
              child: TextFormField(
                validator: (value) {
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: 'Usuario',
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 20), // Espacio entre los campos de entrada
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey),
              ),
              child: TextFormField(
                obscureText: true,
                validator: (value) {
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: 'Contraseña',
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 20), // Espacio entre los campos de entrada y el botón
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  //al presionar loguear te lleva a esta parte
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => homePage.HomePage(),
                    ),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.cyan), // Color de fondo
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // Color del texto
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Radio de esquinas
                    ),
                  ),
                ),
                child: Text('Iniciar sesion'),
              ),
            ),


            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.white), // Fondo blanco
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.cyan), // Texto cian
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Esquinas redondeadas
                      side: BorderSide(color: Colors.cyan, width: 1), // Borde blanco de grosor 2
                    ),
                  ),
                ),
                child: Text('Registrarse'),
              ),
            ),

          ],
        ),
      ),
    );


  }
}
