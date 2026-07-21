import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/onboarding_screen.dart';
import 'services/watch_data_service.dart';
import 'services/ml_api_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WatchDataService()),
        Provider(create: (_) => MLApiService()),
      ],
      child: const LifeWatchApp(),
    ),
  );
}

class LifeWatchApp extends StatelessWidget {
  const LifeWatchApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeWatch ML',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.dark, 
      ),
      home: const OnboardingScreen(),
    );
  }
}
