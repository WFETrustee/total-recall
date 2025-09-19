import 'package:flutter/material.dart';
import 'package:total_recall/screens/upload_screen.dart';

// If you have services like:
// import 'package:total_recall/services/db_service.dart';
// import 'package:total_recall/services/settings_service.dart';

class AppBooter extends StatelessWidget {
  const AppBooter({super.key});

  // This method could initialize services or state before main UI loads
  Future<void> _initializeApp() async {
    // Add future boot logic here
    // await SettingsService.init();
    // await DBService.init();
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate load
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        } else if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: Text('❌ Startup failed: ${snapshot.error}')),
            ),
          );
        }

        // When initialization is done, load the app
        return const MaterialApp(
          title: 'Total Recall',
          home: UploadScreen(),
        );
      },
    );
  }
}
