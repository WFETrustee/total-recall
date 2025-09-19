import 'package:flutter/material.dart';
import 'lib/screens/upload_screen.dart';

void main() {
  runApp(const TotalRecallApp());
}

class TotalRecallApp extends StatelessWidget {
  const TotalRecallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TotalRecall',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const UploadScreen(), 
    );
  }
}
