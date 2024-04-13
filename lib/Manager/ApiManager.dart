import 'dart:convert';
import 'dart:io';

enum HttpMethod { GET, POST, PUT, DELETE, PATCH }

class ApiManager {
  Future<dynamic> fetchDataFromApi({
    required String url,
    required HttpMethod method,
    Map<String, dynamic>? body,
  }) async {
    HttpClient httpClient = HttpClient();
    late HttpClientRequest request;

    try {
      switch (method) {
        case HttpMethod.GET:
          request = await httpClient.getUrl(Uri.parse(url));
          break;
        case HttpMethod.POST:
          request = await httpClient.postUrl(Uri.parse(url));
          break;
        case HttpMethod.PUT:
          request = await httpClient.putUrl(Uri.parse(url));
          break;
        case HttpMethod.DELETE:
          request = await httpClient.deleteUrl(Uri.parse(url));
          break;
        case HttpMethod.PATCH:
          request = await httpClient.patchUrl(Uri.parse(url));
          break;
      }

      if (body != null) {
        request.headers.set('content-type', 'application/json');
        request.add(utf8.encode(jsonEncode(body)));
      }

      HttpClientResponse response = await request.close();

      if (response.statusCode == 200) {
        // Si la petición fue exitosa, leer la respuesta y devolver los datos
        String responseBody = await response.transform(utf8.decoder).join();
        return jsonDecode(responseBody);
      } else {
        // Si la petición falló, lanzar una excepción
        throw Exception('Failed to load data from API. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Si ocurre un error durante la solicitud, lanzar una excepción
      throw Exception('Failed to load data from API: $e');
    } finally {
      httpClient.close();
    }
  }
}