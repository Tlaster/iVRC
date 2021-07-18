import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:openapi/openapi.dart';

const String _baseUrl = "https://api.vrchat.cloud/api/1";

class Api {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
    ),
  );

  Future<User> login(String username, String password, String apiKey) async {
    final response = await _dio.get<String>(
      'auth/user',
      queryParameters: {
        apiKey: apiKey,
      },
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
