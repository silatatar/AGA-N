import 'package:dio/dio.dart';

/// Güvenli AGAIN backend sınırı. Gizli servis anahtarları istemciye konmaz.
class AgainApi {
  AgainApi({required String baseUrl, Dio? client})
    : _dio =
          client ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 12),
              receiveTimeout: const Duration(seconds: 20),
              headers: const {'Accept': 'application/json'},
            ),
          );

  final Dio _dio;

  Future<String> sendHumaMessage({
    required String message,
    required String level,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/v1/huma/messages',
      data: {'message': message, 'level': level},
    );
    return response.data?['reply'] as String? ??
        'Hüma şu anda yanıt veremiyor. Lütfen yeniden dene.';
  }
}
