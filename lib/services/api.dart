import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:openapi/openapi.dart';

const String _baseUrl = "https://api.vrchat.cloud/api/1";

class Api {
  final Dio _dio;
  Api(String apiKey)
      : _dio = Dio(
          BaseOptions(
            baseUrl: _baseUrl,
            queryParameters: {
              apiKey: apiKey,
            },
          ),
        );

  // get cookie from dio
  List<String> getCookie() {
    return _dio.options.headers['cookie'];
  }

  // set cookie to dio
  void setCookie(List<String> cookie) {
    _dio.options.headers['cookie'] = cookie;
  }

  Future<User> login(String username, String password) async {
    final response = await _dio.get<String>(
      '/auth/user',
      options: Options(
        headers: {
          'Authorization': 'Basic ' + _authEnc(username, password),
        },
      ),
    );
    final data = response.data;
    if (data == null) {
      throw Exception('Invalid credentials');
    }
    _dio.options.headers['cookie'] =
        (_dio.options.headers['cookie'] ?? List.empty()) +
            (response.headers["set-cookie"] ?? List.empty());
    final Map<String, dynamic> json = jsonDecode(data);
    if (json.containsKey('requiresTwoFactorAuth')) {
      throw TwofactorException('Two factor authentication required');
    }
    final result = standardSerializers.fromJson(User.serializer, data);
    if (result == null) {
      throw Exception('Invalid credentials');
    } else {
      return result;
    }
  }

  Future<bool> verity2FA(String code) async {
    final response = await _dio.post<String>(
      '/auth/twofactorauth/totp/verify',
      data: {
        'code': code,
      },
    );
    final data = response.data;
    if (data == null) {
      throw Exception('Invalid credentials');
    }
    _dio.options.headers['cookie'] =
        (_dio.options.headers['cookie'] ?? List.empty()) +
            (response.headers["set-cookie"] ?? List.empty());
    final Map<String, dynamic> json = jsonDecode(data);
    if (json.containsKey('verified')) {
      return json['verified'] as bool;
    } else {
      throw Exception('Invalid credentials');
    }
  }

  String _authEnc(String name, String password) {
    final nameEnc = Uri.encodeComponent(name);
    final passwordEnc = Uri.encodeComponent(password);
    return base64.encode(utf8.encode("$nameEnc:$passwordEnc"));
  }
}

class TwofactorException implements Exception {
  final String message;
  TwofactorException(this.message);
}
