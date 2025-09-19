import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:total_recall/services/upload_service.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  String? selectedFileName;
  bool isUploading = false;
  String? uploadStatus;

  final UploadService _uploadService = UploadService();

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: kIsWeb ? FileType.media : FileType.custom,
      allowedExtensions: kIsWeb
          ? null
          : ['mp3', 'm4a', 'wav', 'mp4', 'mov', 'mkv', 'webm', 'avi'],
      withData: kIsWeb, // Needed to get bytes on web
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      setState(() {
        selectedFileName = file.name;
        uploadStatus = null;
      });

      Uint8List? fileBytes;
      if (kIsWeb) {
        fileBytes = file.bytes;
      } else {
        // Read from path on mobile/desktop
        fileBytes = await file.readStream!.fold<Uint8List>(
          Uint8List(0),
          (previous, element) => Uint8List.fromList(
            previous + element,
          ),
        );
      }

      if (fileBytes != null) {
        await uploadFile(fileBytes, file.name);
      } else {
        setState(() {
          uploadStatus = "❌ Could not read file bytes.";
        });
      }
    }
  }

  Future<void> uploadFile(Uint8List bytes, String fileName) async {
    setState(() {
      isUploading = true;
      uploadStatus = "⏳ Uploading $fileName...";
    });

    try {
      final result = await _uploadService.uploadFile(bytes, fileName);
      setState(() {
        uploadStatus = "✅ Upload successful: $result";
      });
    } catch (e) {
      setState(() {
        uploadStatus = "❌ Upload failed: $e";
      });
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload File")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: isUploading ? null : pickFile,
              child: const Text("Pick a File"),
            ),
            const SizedBox(height: 20),
            if (selectedFileName != null) Text("Selected: $selectedFileName"),
            if (isUploading) const CircularProgressIndicator(),
            if (uploadStatus != null) Text(uploadStatus!),
          ],
        ),
      ),
    );
  }
}
