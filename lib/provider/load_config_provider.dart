import 'package:flutter/foundation.dart';
import 'package:ivrc/model/api_data.dart';
import 'package:ivrc/repository/config_repository.dart';
import 'package:openapi/openapi.dart';

class LoadConfigProvider extends ChangeNotifier {
  final ApiData _apiData;

  LoadConfigProvider(
    this._apiData,
  );

  Stream<Config> get loadStream => Stream.fromFuture(init());

  Future<Config> init() async {
    final result = await ConfigRepository().getConfig();
    if (result != null) {
      _apiData.setConfig(result);
      return result;
    } else {
      throw Exception("can not fetch config");
    }
  }
}
