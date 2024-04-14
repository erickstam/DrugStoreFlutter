import 'dart:convert';
import 'package:flutter/material.dart';
import '../Manager/ApiManager.dart';
class ProductsList extends StatefulWidget {
  final String apiUrl;

  ProductsList({required this.apiUrl});

  @override
  _ProductsListState createState() => _ProductsListState();
}

class _ProductsListState extends State<ProductsList> {
  late Future<dynamic> futureData;
  final ApiManager apiManager = ApiManager(); // Instancia de ApiManager

  @override
  void initState() {
    super.initState();
    futureData = fetchData();
  }

  Future<dynamic> fetchData() async {
    try {
      // Llama al método fetchDataFromApi de ApiManager con la URL y el método GET
      return await apiManager.fetchDataFromApi(
        url: widget.apiUrl,
        method: HttpMethod.GET,
        body: null, // No hay datos para enviar en el cuerpo
      );
    } catch (e) {
      // Si ocurre un error, muestra el mensaje de error
      throw Exception('Failed to load data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          // Si la petición fue exitosa, renderiza los datos
          return _buildProductsList(snapshot.data);
        }
      },
    );
  }

  Widget _buildProductsList(dynamic data) {
    // Obtener la lista de elementos del JSON
    final List<dynamic> items = data['items'];

    return Container(
      color: Colors.grey[200], // Color de fondo gris
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          // Obtener el elemento actual
          final item = items[index];

          // Obtener la descripción del elemento
          final Map<String, dynamic> description = item['description'];

          // Obtener la categoría de salidas
          final List<dynamic> categoryOutputs = item['categoryOutputs'];

          return GestureDetector(
            onTap: () {
              // Navegar a la pantalla de detalle del producto
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(item: item),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.all(10), // Margen para separar los Cards
              child: Card(
                color: Colors.grey[400], // Color de fondo del Card
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Imagen del artículo
                      Container(
                        width: MediaQuery.of(context).size.width * 0.25, // 25% del ancho de la pantalla
                        margin: EdgeInsets.only(right: 8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0), // Bordes ovalados
                          color: Colors.grey[700], // Color de fondo gris oscuro
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0), // Bordes ovalados
                          child: item['urlImage'] != null
                              ? Image.network(
                            item['urlImage'],
                            fit: BoxFit.cover, // Ajustar la imagen sin deformarla
                          )
                              : Container(), // No mostrar nada si no hay una imagen
                        ),
                      ),
                      // Descripción del artículo
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nombre del artículo
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                '${description['name']}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            // Descripción del artículo
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text('Descripción: ${description['description']}'),
                            ),
                            // Categorías de salidas
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                'Categorías:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            // Lista de categorías de salidas
                            Wrap(
                              spacing: 8.0, // Espaciado entre las categorías
                              children: categoryOutputs.map<Widget>((category) {
                                final categoryDescription = category['description'];
                                return Container(
                                  padding: EdgeInsets.all(6),
                                  margin: EdgeInsets.only(bottom: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300], // Color de fondo gris claro
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(categoryDescription['name']),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProductDetailScreen extends StatelessWidget {
  final dynamic item;

  ProductDetailScreen({required this.item});

  @override
  Widget build(BuildContext context) {
    // Obtener la descripción del artículo
    final Map<String, dynamic> description = item['description'];

    // Obtener la categoría de salidas
    final List<dynamic> categoryOutputs = item['categoryOutputs'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Producto'),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.grey[200], // Color de fondo gris
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre del artículo
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  '${description['name']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              // Descripción del artículo
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text('Descripción: ${description['description']}'),
              ),
              // URL de la imagen del artículo (solo se muestra si hay una URL)
              if (item['urlImage'] != null)
                Container(
                  height: 300, // Altura más grande para la imagen
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0), // Bordes ovalados
                    color: Colors.grey[700], // Color de fondo gris oscuro
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0), // Bordes ovalados
                    child: Image.network(
                      item['urlImage'],
                      fit: BoxFit.cover, // Ajustar la imagen sin deformarla
                    ),
                  ),
                ),
              // Categorías de salidas
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Categorías:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              // Lista de categorías de salidas
              Wrap(
                spacing: 8.0, // Espaciado entre las categorías
                children: categoryOutputs.map<Widget>((category) {
                  final categoryDescription = category['description'];
                  return Container(
                    padding: EdgeInsets.all(6),
                    margin: EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[300], // Color de fondo gris claro
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(categoryDescription['name']),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}