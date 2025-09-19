import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class UploadService {
  final String localServerUrl = "http://localhost:5000"; // Flask server
  final String publicExtractorUrl =
      "https://api.public-extractor.com/extract"; // TODO: Replace with real API

  /// Detect if file is video based on extension
  bool isVideo(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    return ['mp4', 'mov', 'mkv', 'webm', 'avi'].contains(ext);
  }

  /// Detect if file is audio based on extension
  bool isAudio(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    return ['mp3', 'm4a', 'wav'].contains(ext);
  }

  /// Determine MIME type based on extension
  MediaType getMimeType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'mp3':
        return MediaType('audio', 'mpeg');
      case 'm4a':
        return MediaType('audio', 'mp4');
      case 'wav':
        return MediaType('audio', 'wav');
      case 'mp4':
        return MediaType('video', 'mp4');
      case 'mov':
        return MediaType('video', 'quicktime');
      case 'mkv':
        return MediaType('video', 'x-matroska');
      case 'webm':
        return MediaType('video', 'webm');
      case 'avi':
        return MediaType('video', 'x-msvideo');
      default:
        return MediaType('application', 'octet-stream');
    }
  }

  /// Upload file (audio directly, video with fallback extraction)
  Future<String?> uploadFile(Uint8List bytes, String fileName) async {
    if (isAudio(fileName)) {
      // Direct audio upload
      return await _uploadToLocalServer(bytes, fileName, getMimeType(fileName));
    } else if (isVideo(fileName)) {
      // Try local extraction first
      try {
        return await _uploadToLocalServerForExtraction(
            bytes, fileName, getMimeType(fileName));
      } catch (e) {
        print("⚠️ Local extraction failed, falling back to public API: $e");
        return await _uploadToPublicExtractor(bytes, fileName);
      }
    } else {
      throw Exception("Unsupported file type: $fileName");
    }
  }

  /// Upload to local Flask server (direct audio)
  Future<String?> _uploadToLocalServer(
      Uint8List bytes, String fileName, MediaType mimeType) async {
    final uri = Uri.parse("$localServerUrl/upload");

    final request = http.MultipartRequest("POST", uri)
      ..files.add(http.MultipartFile.fromBytes('file', bytes,
          filename: fileName, contentType: mimeType));

    final response = await request.send();
    if (response.statusCode == 200) {
      final respString = await response.stream.bytesToString();
      final jsonResp = json.decode(respString);
      return jsonResp['file_url']; // adjust based on Flask response
    } else {
      throw Exception("Local server upload failed: ${response.statusCode}");
    }
  }

  /// Upload to local Flask server for video → audio extraction
  Future<String?> _uploadToLocalServerForExtraction(
      Uint8List bytes, String fileName, MediaType mimeType) async {
    final uri = Uri.parse("$localServerUrl/extract-audio");

    final request = http.MultipartRequest("POST", uri)
      ..files.add(http.MultipartFile.fromBytes('file', bytes,
          filename: fileName, contentType: mimeType));

    final response = await request.send();
    if (response.statusCode == 200) {
      final respBytes = await response.stream.toBytes();
      // TODO: Save this as a local audio file or upload to Supabase
      print("✅ Local extraction succeeded (audio bytes length = ${respBytes.length})");
      return "local_audio_success"; // placeholder
    } else {
      throw Exception("Local extraction failed: ${response.statusCode}");
    }
  }

  /// Fallback: Public extractor API
  Future<String?> _uploadToPublicExtractor(
      Uint8List bytes, String fileName) async {
    final uri = Uri.parse(publicExtractorUrl);

    final request = http.MultipartRequest("POST", uri)
      ..files.add(http.MultipartFile.fromBytes('file', bytes,
          filename: fileName, contentType: getMimeType(fileName)));

    final response = await request.send();
    if (response.statusCode == 200) {
      final respBytes = await response.stream.toBytes();
      // TODO: Handle audio file return
      print("✅ Public extractor returned audio (length = ${respBytes.length})");
      return "public_audio_success"; // placeholder
    } else {
      throw Exception("Public extractor failed: ${response.statusCode}");
    }
  }
}
