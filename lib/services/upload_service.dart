import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class UploadService {
  final String localUrl = 'http://192.168.1.124:5000/upload';
  final String fallbackUrl = 'https://api.totalrecall.ai/upload'; // Placeholder

  Future<bool> uploadFile(File file) async {
    try {
      final uri = Uri.parse(await _resolveUploadUrl());
      final request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        print('✅ Upload successful');
        return true;
      } else {
        print('❌ Upload failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❗ Upload error: $e');
      return false;
    }
  }

  Future<String> _resolveUploadUrl() async {
    try {
      final ping = await http.get(Uri.parse('$localUrl/ping')).timeout(Duration(seconds: 2));
      if (ping.statusCode == 200) {
        print('📡 Local server is up');
        return localUrl;
      }
    } catch (_) {
      print('🔁 Falling back to remote upload');
    }
    return fallbackUrl;
  }
}
