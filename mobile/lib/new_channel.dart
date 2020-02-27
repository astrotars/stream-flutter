import 'package:flutter/material.dart';

import 'livestream_channel.dart';

class NewChannel extends StatefulWidget {
  NewChannel({Key key, @required this.account}) : super(key: key);

  Map account;

  @override
  _NewChannelState createState() => _NewChannelState();
}

class _NewChannelState extends State<NewChannel> {
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future _createChannel(BuildContext context) async {
    if (_messageController.text.length > 0 && RegExp(r'^[a-zA-Z0-9]+$').hasMatch(_messageController.text)) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LivestreamChat(account: widget.account, channelId: _messageController.text),
          ),
          result: true);
    } else {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Please type a channel ID. It can only contain letters and numbers with no whitespace.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create new channel"),
      ),
      body: Builder(
        builder: (context) {
          return Container(
            padding: EdgeInsets.all(12.0),
            child: Center(
              child: Column(
                children: [
                  TextField(
                    controller: _messageController,
                  ),
                  RaisedButton(
                    onPressed: () => _createChannel(context),
                    child: Text("Create Channel"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
