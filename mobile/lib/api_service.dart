import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const platform = const MethodChannel('io.getstream/backend');
  static const _baseUrl = 'https://f48f0281.ngrok.io';

  Future<Map> login(String user) async {
    var authResponse = await http.post('$_baseUrl/v1/users', body: {'sender': user});
    var authToken = json.decode(authResponse.body)['authToken'];
    var feedResponse =
        await http.post('$_baseUrl/v1/stream-feed-credentials', headers: {'Authorization': 'Bearer $authToken'});
    var feedToken = json.decode(feedResponse.body)['token'];

    return {'authToken': authToken, 'feedToken': feedToken};
  }

  Future<List> users(Map account) async {
    var response = await http.get('$_baseUrl/v1/users', headers: {'Authorization': 'Bearer ${account['authToken']}'});
    return json.decode(response.body)['users'];
  }

  Future<bool> postMessage(Map account, String message) async {
    return await platform.invokeMethod<bool>(
        'postMessage', {'user': account['user'], 'token': account['feedToken'], 'message': message});
  }

  Future<dynamic> getActivities(Map account) async {
    var result =
        await platform.invokeMethod<String>('getActivities', {'user': account['user'], 'token': account['feedToken']});
    return json.decode(result);
  }

  Future<dynamic> getTimeline(Map account) async {
    var result =
        await platform.invokeMethod<String>('getTimeline', {'user': account['user'], 'token': account['feedToken']});
    return json.decode(result);
  }

  Future<bool> follow(Map account, String userToFollow) async {
    return await platform.invokeMethod<bool>(
        'follow', {'user': account['user'], 'token': account['feedToken'], 'userToFollow': userToFollow});
  }
}
