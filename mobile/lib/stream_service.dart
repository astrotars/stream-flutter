import 'dart:convert';

import 'package:flutter/services.dart';

class StreamService {
  static const platform = const MethodChannel('io.getstream/backend');

  // todo: better description.
  // For simplicity, we're creating the token in the client. This is insecure!
  // This should be a call to a secure API.
  Future<String> getToken(String user) async {
    return await platform.invokeMethod('getToken', user);
  }

  Future<bool> postMessage(String user, String token, String message) async {
    return await platform.invokeMethod<bool>('postMessage', {'user': user, 'token': token, 'message': message});
  }

  Future<dynamic> getActivities(String user, String token) async {
    var result = await platform.invokeMethod<String>('getActivities', {'user': user, 'token': token});
    return json.decode(result);
  }

  Future<dynamic> getTimeline(String user, String token) async {
    var result = await platform.invokeMethod<String>('getTimeline', {'user': user, 'token': token});
    return json.decode(result);
  }

  Future<bool> follow(String user, String token, String userToFollow) async {
    return await platform.invokeMethod<bool>('follow', {'user': user, 'token': token, 'userToFollow': userToFollow});
  }
}
