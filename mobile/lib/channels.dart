import 'package:flutter/material.dart';

import 'api_service.dart';
import 'chat.dart';

class Channels extends StatefulWidget {
  Channels({Key key, @required this.account}) : super(key: key);

  final Map account;

  @override
  _ChannelsState createState() => _ChannelsState();
}

class _ChannelsState extends State<Channels> {
  Future<List<dynamic>> _channels;

  @override
  void initState() {
    super.initState();
    _channels = ApiService().channels();
  }

  Future _refreshChannels() async {
    setState(() {
      _channels = ApiService().channels();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _channels,
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: _refreshChannels,
          child: ListView(
            children: snapshot.data
                .map((channel) =>
                ListTile(
                  title: Text(channel),
                  onTap: () {},
                ))
                .toList(),
          ),
        );
      },
    );
  }
}
