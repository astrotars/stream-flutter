import 'package:flutter/material.dart';

import 'stream_service.dart';

class NewActivity extends StatefulWidget {
  NewActivity({Key key, @required this.user, @required this.streamToken}) : super(key: key);

  final String user;
  final String streamToken;

  @override
  _NewActivityState createState() => _NewActivityState();
}

class _NewActivityState extends State<NewActivity> {
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future _postMessage(BuildContext context) async {
    if (_messageController.text.length > 0) {
      await StreamService().postMessage(widget.user, widget.streamToken, _messageController.text);
      Navigator.pop(context);
    } else {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Please type a message'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Post Message"),
      ),
      body: Builder(
        builder: (context) {
          return Center(
            child: Column(
              children: [
                Text("User"),
                TextField(
                  controller: _messageController,
                ),
                MaterialButton(
                  onPressed: () => _postMessage(context),
                  child: Text("Post"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
