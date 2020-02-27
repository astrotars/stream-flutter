import 'package:flutter/material.dart';

import 'api_service.dart';
import 'livestream_channel.dart';
import 'new_channel.dart';

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

        var tiles = [
          ListTile(
            title: Center(
              child: RaisedButton(
                child: Text("Create New Channel"),
                onPressed: () async {
                  var channelCreated = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => NewChannel(account: widget.account)),
                  );

                  if (channelCreated != null) {
                    setState(() {
                      _channels = ApiService().channels();
                    });
                  }
                },
              ),
            ),
          )
        ];

        tiles.addAll(
          snapshot.data
              .map((channel) => ListTile(
                    title: Text(channel),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LivestreamChat(account: widget.account, channelId: channel),
                        ),
                      );
                    },
                  ))
              .toList(),
        );

        return RefreshIndicator(
          onRefresh: _refreshChannels,
          child: ListView(
            children: tiles,
          ),
        );
      },
    );
  }
}
