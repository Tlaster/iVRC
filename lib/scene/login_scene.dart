import 'package:flutter/material.dart';
import 'package:ivrc/extensions/context.dart';
import 'package:ivrc/model/api_data.dart';
import 'package:ivrc/provider/login_provider.dart';
import 'package:provider/provider.dart';

class LoginScene extends StatelessWidget {
  final String redirectUri;

  const LoginScene({Key? key, required this.redirectUri}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginProvider(context.read<ApiData>()),
      child: _LoginScene(redirectUri),
    );
  }
}

class _LoginScene extends StatelessWidget {
  final String redirectUri;
  const _LoginScene(this.redirectUri, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _LoginSceneContent(redirectUri),
      ),
    );
  }
}

class _LoginSceneContent extends StatelessWidget {
  final String redirectUri;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  _LoginSceneContent(this.redirectUri, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.read<LoginProvider>();
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (route) => MaterialPageRoute(
        settings: route,
        builder: (context) => _SignInWidget(
          userName: provider.name,
          password: provider.password,
          onUserNameChanged: (userName) => provider.name = userName,
          onPasswordChanged: (password) => provider.password = password,
          onLogin: () async {
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => const CircularProgressIndicator(),
              ),
            );
            final result = await provider.login();
            if (result is LoginSuccess) {
              Navigator.of(context).pushNamed(redirectUri);
            } else if (result is LoginFailure) {
              context.showSnack(result.exception.toString());
              navigatorKey.currentState?.pop();
            } else if (result is LoginRequire2FA) {
              navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (context) => _2FAWidget(
                    code: provider.code,
                    onLogin: () async {
                      navigatorKey.currentState?.push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const CircularProgressIndicator(),
                        ),
                      );
                      final result = await provider.loginWith2FA();
                      if (result is LoginSuccess) {
                        Navigator.of(context).pushNamed(redirectUri);
                      } else if (result is LoginFailure) {
                        context.showSnack(result.exception.toString());
                        navigatorKey.currentState?.pop();
                      }
                    },
                    onCodeEntered: (code) => provider.code = code,
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class _2FAWidget extends StatelessWidget {
  final String? code;
  final Function onLogin;
  final Function(String) onCodeEntered;
  final _formKey = GlobalKey<FormState>();

  _2FAWidget({
    Key? key,
    this.code,
    required this.onLogin,
    required this.onCodeEntered,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 16),
          TextFormField(
            initialValue: code,
            decoration: const InputDecoration(
              hintText: '两步验证代码',
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
            onChanged: (value) => onCodeEntered.call(value),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                onLogin.call();
              }
            },
            child: const Text('登录'),
          ),
        ],
      ),
    );
  }
}

class _SignInWidget extends StatelessWidget {
  final String? userName;
  final String? password;
  final Function(String) onUserNameChanged;
  final Function(String) onPasswordChanged;
  final Function onLogin;

  final _formKey = GlobalKey<FormState>();

  _SignInWidget({
    Key? key,
    this.userName,
    this.password,
    required this.onUserNameChanged,
    required this.onPasswordChanged,
    required this.onLogin,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 16),
          TextFormField(
            initialValue: userName,
            decoration: const InputDecoration(
              hintText: '用户名',
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
            onChanged: (value) => onUserNameChanged.call(value),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: password,
            onChanged: (value) => onPasswordChanged.call(value),
            decoration: const InputDecoration(
              hintText: '密码',
            ),
            obscureText: true,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                onLogin.call();
              }
            },
            child: const Text('登录'),
          ),
        ],
      ),
    );
  }
}
