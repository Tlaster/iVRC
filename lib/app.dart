import 'package:flutter/material.dart';
import 'package:ivrc/model/api_data.dart';
import 'package:ivrc/route/route.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  const App({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final apiData = context.read<ApiData>();
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) => generateRoute(settings, apiData),
    );
  }
}
