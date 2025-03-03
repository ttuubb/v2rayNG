import 'dart:io';
import 'package:http/http.dart' as http;

abstract class ApiService {
  Future<String> fetchSubscription(String url);
  Future<bool> testConnection(String address, int port);
}

class ApiServiceImpl implements ApiService {
  final http.Client _client = http.Client();

  @override
  Future<String> fetchSubscription(String url) async {
    try {
      final response = await _client.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to fetch subscription: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<bool> testConnection(String address, int port) async {
    try {
      final socket = await Socket.connect(address, port, timeout: Duration(seconds: 5));
      await socket.close();
      return true;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _client.close();
  }
}