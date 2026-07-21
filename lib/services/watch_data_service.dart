import 'package:flutter/foundation.dart';

class WatchDataService extends ChangeNotifier {
  bool _isAuthorized = false;
  List<Map<String, dynamic>> _healthData = [];
  
  bool get isAuthorized => _isAuthorized;
  List<Map<String, dynamic>> get healthData => _healthData;

  Future<void> authorize() async {
    // Mock authorization
    await Future.delayed(const Duration(seconds: 1));
    _isAuthorized = true;
    notifyListeners();
  }

  Future<void> fetchRecentData() async {
    if (!_isAuthorized) return;

    // Mock fetching data
    await Future.delayed(const Duration(seconds: 1));
    
    _healthData = [
      {"type": "HEART_RATE", "value": 75},
      {"type": "STEPS", "value": 5200},
    ];
    notifyListeners();
  }
}
