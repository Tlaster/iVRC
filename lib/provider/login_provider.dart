import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ivrc/model/api_data.dart';
import 'package:ivrc/services/api.dart';

class LoginProvider extends ChangeNotifier {
  final ApiData apiData;
  String? name;
  String? password;
  String? code;

  LoginProvider(this.apiData);

  Future<LoginResultState> login() async {
    final apiKey = apiData.apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      return LoginFailure(Exception("no api key"));
    }
    final nameCopy = name;
    final passwordCopy = password;
    if (nameCopy == null || passwordCopy == null) {
      return LoginFailure(Exception("LoginProvider: name or password not set"));
    }
    try {
      final data = await Api().login(nameCopy, passwordCopy, apiKey);
      return LoginSuccess();
    } on TwofactorException catch (e) {
      return LoginRequire2FA();
    }
  }

  Future<LoginResultState> loginWith2FA() async {
    final nameCopy = name;
    final passwordCopy = password;
    final codeCopy = code;
    if (nameCopy == null || passwordCopy == null || codeCopy == null) {
      return LoginFailure(
          Exception("LoginProvider: name or password or code not set"));
    }
    final auth = _authEnc(nameCopy, passwordCopy);
    return LoginFailure(Exception("LoginProvider: 2FA not supported"));
  }

  String _authEnc(String nameCopy, String passwordCopy) {
    final nameEnc = Uri.encodeComponent(nameCopy);
    final passwordEnc = Uri.encodeComponent(passwordCopy);
    return base64.encode(utf8.encode("$nameEnc:$passwordEnc"));
  }
}

class LoginResultState {}

class LoginSuccess extends LoginResultState {}

class LoginFailure extends LoginResultState {
  final Exception exception;

  LoginFailure(this.exception);
}

class LoginRequire2FA extends LoginResultState {}
