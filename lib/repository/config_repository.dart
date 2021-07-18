import 'package:openapi/openapi.dart';

class ConfigRepository {
  Future<Config?> getConfig() async {
    final response = await Openapi().getSystemApi().getConfig();
    return response.data;
  }
}
