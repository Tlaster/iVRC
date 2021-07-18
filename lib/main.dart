import 'package:flutter/material.dart';
import 'package:ivrc/app.dart';
import 'package:ivrc/model/api_data.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final initialData = ApiData();
  await initialData.tryLoadToken();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ApiData>(create: (_) => initialData),
      ],
      child: const App(),
    ),
  );
}
