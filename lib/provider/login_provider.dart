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
      await apiData.getApi().login(nameCopy, passwordCopy);
      return LoginSuccess();
    } on TwofactorException catch (e) {
      return LoginRequire2FA();
    }
  }

  Future<LoginResultState> loginWith2FA() async {
    final apiKey = apiData.apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      return LoginFailure(Exception("no api key"));
    }
    final nameCopy = name;
    final passwordCopy = password;
    if (nameCopy == null || passwordCopy == null) {
      return LoginFailure(Exception("LoginProvider: name or password not set"));
    }
    final codeCopy = code;
    if (codeCopy == null) {
      return LoginFailure(Exception("LoginProvider: code not set"));
    }
    try {
      final result = await apiData.getApi().verity2FA(codeCopy);
      if (!result) {
        return LoginFailure(Exception("LoginProvider: invalid code"));
      }
      await apiData.getApi().login(nameCopy, passwordCopy);
      await apiData.save();
      return LoginSuccess();
    } on TwofactorException catch (e) {
      return LoginRequire2FA();
    }
  }
}

class LoginResultState {}

class LoginSuccess extends LoginResultState {}

class LoginFailure extends LoginResultState {
  final Exception exception;

  LoginFailure(this.exception);
}

class LoginRequire2FA extends LoginResultState {}
