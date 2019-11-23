import 'package:flutter/material.dart';

import 'stream_service.dart';

class Home extends StatefulWidget {
  Home({Key key, this.user, this.streamToken}) : super(key: key);

  final String user;
  final String streamToken;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<dynamic> _activities;

  @override
  void initState() {
    super.initState();
    _getActivities();
  }

  Future<void> _getActivities() async {
    var activities = await StreamService().getActivities(widget.user, widget.streamToken);
    setState(() {
      _activities = activities;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_activities != null) {
      return ListView(
        children: _activities
            .map(
              (a) => ListTile(title: Text(a['message'])),
            )
            .toList(),
      );
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }
}
