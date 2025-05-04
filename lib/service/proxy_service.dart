import 'package:http/http.dart' as http;
import 'dart:convert';

class ProxyService {
  final String proxyURL = "http://localhost:5000/maps";

  Future<void> fetchPlaces(String path) async {
    final response = await http.get(Uri.parse("$proxyURL?path=$path"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);
    } else {
      throw Exception("Failed to fetch data from proxy");
    }
  }
}
