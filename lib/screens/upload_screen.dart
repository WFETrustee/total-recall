import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  String? selectedFileName;
  bool isUploading = false;
  String? uploadStatus;

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'm4a', 'wav', 'mp4', 'mov', 'mkv', 'webm', 'avi'],
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;

      setState(() {
        selectedFileName = file.name;
        isUploading = true;
        uploadStatus = null;
      });

      try {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('http://192.168.1.124:5000/upload'),
        );
        request.files.add(await http.MultipartFile.fromPath('file', file.path!));

        final response = await request.send();

        if (response.statusCode == 200) {
          final body = await response.stream.bytesToString();
          final json = jsonDecode(body);
          setState(() => uploadStatus = '✅ Uploaded: ${json['filename']}');
        } else {
          setState(() => uploadStatus = '❌ Failed with code: ${response.statusCode}');
        }
      } catch (e) {
        setState(() => uploadStatus = '❌ Error: $e');
      } finally {
        setState(() => isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Recording')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: isUploading ? null : pickFile,
              icon: const Icon(Icons.upload_file),
              label: const Text('Select File'),
            ),
            const SizedBox(height: 20),
            if (selectedFileName != null)
              Text(
                'Selected: $selectedFileName',
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 10),
            if (isUploading) const CircularProgressIndicator(),
            if (uploadStatus != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  uploadStatus!,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
