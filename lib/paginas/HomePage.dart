import 'dart:ffi';
import '../widgets/ProductsList.dart' as CustomProductsList;
import '../widgets/login.dart' as loguin;
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DrugStore'),
        backgroundColor: Colors.blue, // Cambiar el color del AppBar a cian
      ),
      drawer: DrawerMenu(), // Mostrar el menú
      body: CustomProductsList.ProductsList(apiUrl: 'https://pharmacylocation.azurewebsites.net/api/product'), // Mostrar la pantalla de inicio de sesión
    );
  }
}

class DrawerMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menú',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: Text('Productos'),
            onTap: () {
              Navigator.pop(context); // Cerrar el drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CustomProductsList.ProductsList(apiUrl: 'https://pharmacylocation.azurewebsites.net/api/product')),
              );
            },
          ),
          ListTile(
            title: Text('Farmacias Cercanas'),
            onTap: () {
              // Agrega aquí la navegación o acciones cuando se selecciona 'Farmacias Cercanas'
            },
          ),
          ListTile(
            title: Text('Farmacias Favoritas'),
            onTap: () {
              // Agrega aquí la navegación o acciones cuando se selecciona 'Farmacias Favoritas'
            },
          ),
          ListTile(
            title: Text('Productos Favoritos'),
            onTap: () {
              // Agrega aquí la navegación o acciones cuando se selecciona 'Productos Favoritos'
            },
          ),
          ListTile(
            title: Text('Cerrar sesion'),
            onTap: () {
              Navigator.pop(context); // Cerrar el drawer
              Navigator.pushReplacement( // Lleva al usuario a la pantalla de inicio de sesión, reemplazando la pantalla actual en el historial de rutas
                context,
                MaterialPageRoute(builder: (context) => loguin.login()),
              );
            },
          ),
        ],
      ),
    );
  }
}


class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Text(
          'DrugStore',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}