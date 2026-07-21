import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class MLApiService {
  final Dio _dio = Dio();
  // TODO: Replace with your actual ML API Endpoint
  final String _apiUrl = "https://your-ml-api.com/predict";

  Future<Map<String, dynamic>?> sendDataForPrediction(Map<String, dynamic> watchData) async {
    try {
      final response = await _dio.post(
        _apiUrl,
        data: watchData,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        debugPrint("API Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("API Exception: $e");
      return null;
    }
  }
}
