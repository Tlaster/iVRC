import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ivrc/services/api.dart';
import 'package:openapi/openapi.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _tokenKey = 'token';

class ApiData extends ChangeNotifier {
  Config? _config;
  Api? _api;
  String? _token;

  //update config
  Future<void> setConfig(Config config) async {
    _config = config;
    final apiKey = _config?.apiKey;
    if (apiKey != null) {
      final token = await loadToken();
      final api = Api(apiKey);
      if (token != null) {
        api.setCookie(jsonDecode(token));
      }
      _api = api;
      _token = token;
    }
  }

  //get api
  Api getApi() => _api!;
  bool isLoggedIn() => _token != null;
  //check if current config is not null
  bool isConfigSet() => _config != null;
  // get the current config
  Config? getConfig() => _config;
  // get api key
  String? get apiKey => _config?.apiKey;

  Future<void> save() async {
    await saveToken(jsonEncode(getApi().getCookie()));
  }

  //save the current token to shared preferences
  Future<void> saveToken(String? token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString(_tokenKey, token);
    } else {
      await prefs.remove(_tokenKey);
    }
    _token = token;
  }

  Future<String?> loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_tokenKey)) {
      final token = prefs.getString(_tokenKey);
      return token;
    } else {
      return null;
    }
  }
}
