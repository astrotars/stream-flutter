import 'package:flutter/services.dart';

class StreamBackend {
  static const platform = const MethodChannel('io.getstream/backend');

  Future<String> getToken(String user) async {
    final String token = await platform.invokeMethod('getToken', user);

    return token;
  }
}
