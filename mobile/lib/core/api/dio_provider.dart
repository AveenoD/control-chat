import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/api_config.dart';
import '../auth/session_provider.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<Response<dynamic>> _retry(RequestOptions options) async {
    options.extra['_retried'] = true;
    options.headers['Authorization'] = 'Bearer ${ref.read(sessionProvider).accessToken}';
    return dio.fetch(options);
  }

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = ref.read(sessionProvider).accessToken;
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final status = error.response?.statusCode;
        final path = error.requestOptions.path;
        final retried = error.requestOptions.extra['_retried'] == true;

        if (status == 401 && !path.startsWith('/auth/') && !retried) {
          final refreshed = await ref.read(sessionProvider.notifier).refreshAccessToken();
          if (refreshed) {
            try {
              return handler.resolve(await _retry(error.requestOptions));
            } catch (_) {}
          }
        }

        final isTimeout = error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.connectionTimeout;
        if (isTimeout && !retried) {
          try {
            return handler.resolve(await _retry(error.requestOptions));
          } catch (_) {}
        }

        handler.next(error);
      },
    ),
  );

  return dio;
});
