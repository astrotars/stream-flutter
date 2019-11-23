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
  Future<List<dynamic>> _activities;

  @override
  void initState() {
    super.initState();
    _activities = _getTimeline();
  }

  Future<List<dynamic>> _getTimeline() async {
    return await StreamService().getTimeline(widget.user, widget.streamToken);
  }

  Future _refreshActivities() async {
    setState(() {
      _activities = _getTimeline();
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _activities,
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        return Container(
          child: Center(
            child: RefreshIndicator(
              onRefresh: _refreshActivities,
              child: ListView(
                children: snapshot.data
                  .map((activity) => ListTile(
                  title: Text(activity['message']),
                  subtitle: Text(activity['actor']),
                ))
                  .toList(),
              ),
            ),
          ),
        );
      });
  }
}
