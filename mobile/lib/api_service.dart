import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const platform = const MethodChannel('io.getstream/backend');

  Future<Map> login(String user) async {
    var authResponse = await http.post('https://4999aa14.ngrok.io/v1/authenticate', body: {'sender': user});
    var authToken = json.decode(authResponse.body)['authToken'];
    var feedResponse = await http
        .post('https://4999aa14.ngrok.io/v1/stream-feed-credentials', headers: {'Authorization': 'Bearer $authToken'});
    var feedToken = json.decode(feedResponse.body)['token'];

    return {'authToken': authToken, 'feedToken': feedToken};
  }

  Future<bool> postMessage(Map account, String message) async {
    return await platform.invokeMethod<bool>('postMessage', {'user': account['user'], 'token': account['feedToken'], 'message': message});
  }

  Future<dynamic> getActivities(Map account) async {
    var result = await platform.invokeMethod<String>('getActivities', {'user': account['user'], 'token': 'feedToken'});
    return json.decode(result);
  }

  Future<dynamic> getTimeline(Map account) async {
    var result = await platform.invokeMethod<String>('getTimeline', {'user': account['user'], 'token': account['feedToken']});
    return json.decode(result);
  }

  Future<bool> follow(Map account, String userToFollow) async {
    return await platform.invokeMethod<bool>('follow', {'user': account['user'], 'token': account['feedToken'], 'userToFollow': userToFollow});
  }
}
