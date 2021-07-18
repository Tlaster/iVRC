import 'package:flutter/material.dart';
import 'package:ivrc/model/api_data.dart';
import 'package:ivrc/scene/home_scene.dart';
import 'package:ivrc/scene/load_config_scene.dart';
import 'package:ivrc/scene/login_scene.dart';

Route? generateRoute(RouteSettings settings, ApiData apiData) {
  if (!apiData.isConfigSet()) {
    return MaterialPageRoute(
      builder: (_) => LoadConfigScene(
        redirectUri: settings.name!.toLowerCase().startsWith('/init')
            ? "/"
            : settings.name ?? "/",
      ),
      settings: RouteSettings(name: "/init", arguments: settings.arguments),
    );
  }
  if (!apiData.isLoggedIn()) {
    return MaterialPageRoute(
      builder: (_) => LoginScene(
        redirectUri: settings.name!.toLowerCase().startsWith('/login')
            ? "/"
            : settings.name ?? "/",
      ),
      settings: RouteSettings(name: "/login", arguments: settings.arguments),
    );
  }

  return MaterialPageRoute(
    builder: (_) => const HomeScene(),
    settings: settings,
  );
}
