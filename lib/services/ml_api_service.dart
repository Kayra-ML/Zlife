import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class MLApiService {
  final Dio _dio = Dio();
  // iOS Simülatörü için localhost 127.0.0.1'dir. Gerçek cihazda PC'nin yerel IP'si gerekir.
  final String _apiUrl = "http://127.0.0.1:8000/api/health-data";

  Future<Map<String, dynamic>?> sendDataForPrediction(Map<String, dynamic> watchData) async {
    try {
      // FastAPI'nin beklediği formata dönüştür
      final payload = {
        "user_id": watchData["user_id"] ?? "zlife_ios_user",
        "overall_sleep_score": watchData["overall_sleep_score"] ?? 85,
        "deep_sleep_in_minutes": watchData["deep_sleep_in_minutes"] ?? 90,
        "resting_heart_rate": watchData["resting_heart_rate"] ?? 65,
        "restlessness": watchData["restlessness"] ?? 0.1,
        "timestamp": DateTime.now().toIso8601String()
      };

      final response = await _dio.post(
        _apiUrl,
        data: payload,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => true, // Hata kodlarında da response body'yi okumak için
        ),
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
