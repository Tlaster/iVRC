import 'package:flutter/material.dart';
import 'package:ivrc/model/api_data.dart';
import 'package:ivrc/provider/load_config_provider.dart';
import 'package:openapi/openapi.dart';
import 'package:provider/provider.dart';

class LoadConfigScene extends StatelessWidget {
  final String redirectUri;
  const LoadConfigScene({
    Key? key,
    required this.redirectUri,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoadConfigProvider(
        context.read<ApiData>(),
      ),
      child: _LoadConfigSceneContent(
        redirectUri: redirectUri,
      ),
    );
  }
}

class _LoadConfigSceneContent extends StatelessWidget {
  final String redirectUri;
  const _LoadConfigSceneContent({Key? key, required this.redirectUri})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.read<LoadConfigProvider>();
    return Scaffold(
      body: Center(
        child: StreamBuilder<Config>(
          stream: provider.loadStream,
          builder: (BuildContext context, AsyncSnapshot<Config> snapshot) {
            if (snapshot.hasError) {
              return Column(
                children: [
                  const Text('Loading config failed'),
                  Text(snapshot.error.toString()),
                ],
              );
            } else if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            } else {
              Navigator.of(context).pushReplacementNamed(redirectUri);
              return const Text("success");
            }
          },
        ),
      ),
    );
  }
}
