import 'package:flutter/material.dart';
import 'package:openapi/openapi.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _tokenKey = 'token';

class ApiData extends ChangeNotifier {
  Config? _config;
  String? _accessToken;

  //update config
  void setConfig(Config config) {
    _config = config;
  }

  Future<void> setToken(String token) async {
    _accessToken = token;
  }

  //check if current config is not null
  bool isConfigSet() => _config != null;
  //check if current token is not null
  bool isLoggedIn() => _accessToken != null;
  //get the current token
  String? getToken() => _accessToken;
  // get the current config
  Config? getConfig() => _config;
  // get api key
  String? get apiKey => _config?.apiKey;
  //save the current token to shared preferences
  Future<void> saveToken(String? token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString(_tokenKey, token);
    } else {
      await prefs.remove(_tokenKey);
    }
    _accessToken = token;
  }

  Future<void> tryLoadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_tokenKey)) {
      final token = prefs.getString(_tokenKey);
      _accessToken = token;
    } else {
      _accessToken = null;
    }
  }
}
