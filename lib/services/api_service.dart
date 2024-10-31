import 'package:http/http.dart' as http;
import 'package:learning_management_system/services/storage_service.dart';

class ApiService {
  final String baseUrl = 'http://160.30.168.228:8080/it4788';
  final StorageService _storageService = StorageService();

  Future<http.Response> get(String endpoint) async {
    final token = await _storageService.getToken();
    return await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  // Similarly, implement post, put, delete methods...
}
