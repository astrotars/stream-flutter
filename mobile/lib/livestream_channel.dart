import 'package:flutter/material.dart';

import 'api_service.dart';

class LivestreamChat extends StatefulWidget {
  LivestreamChat({Key key, @required this.account, @required this.channelId}) : super(key: key);

  final Map account;
  final String channelId;

  @override
  _LivestreamChatState createState() => _LivestreamChatState();
}

class _LivestreamChatState extends State<LivestreamChat> {
  final _messageController = TextEditingController();
  List<dynamic> _messages;
  CancelListening cancelChannel;

  @override
  void initState() {
    _setupChannel();
    super.initState();
  }

  @override
  void dispose() {
    cancelChannel();
    super.dispose();
  }

  Future _setupChannel() async {
    cancelChannel = await ApiService().listenToChannel(widget.channelId, (messages) {
      setState(() {
        var prevMessages = [];
        if (_messages != null) {
          prevMessages = _messages;
        }
        _messages = prevMessages + messages;
      });
    });
  }

  Future _postMessage() async {
    if (_messageController.text.length > 0) {
      await ApiService().postChannelMessage(widget.channelId, _messageController.text);
      _messageController.clear();
    }
  }

  Widget buildMessage(dynamic message) {
    var isMyMessage = message['userId'] == widget.account['user'];
    return Row(
      mainAxisAlignment: isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Text(
                message['text'],
                style: TextStyle(color: isMyMessage ? Colors.white : Colors.black),
              ),
              padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
              width: 200.0,
              decoration: BoxDecoration(
                  color: isMyMessage ? Colors.blueAccent : Colors.black12, borderRadius: BorderRadius.circular(8.0)),
              margin: EdgeInsets.only(right: 10.0),
            ),
            Container(
              margin: EdgeInsets.only(left: 15.0, top: 5.0, bottom: 10.0),
              child: isMyMessage
                  ? null
                  : Text(
                      message['userId'],
                      style: TextStyle(color: Colors.black54, fontSize: 10.0),
                    ),
            ),
          ],
        )
      ],
    );
  }

  Widget buildMessages() {
    return Flexible(
      child: ListView(
        padding: EdgeInsets.all(10.0),
        reverse: true,
        children: _messages.reversed.map<Widget>(buildMessage).toList(),
      ),
    );
  }

  Widget buildInput(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Row(
        children: <Widget>[
          // Edit text
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                style: TextStyle(fontSize: 15.0),
                controller: _messageController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),

          // Button send message
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: _postMessage,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration:
          BoxDecoration(border: Border(top: BorderSide(color: Colors.blueGrey, width: 0.5)), color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.channelId),
      ),
      body: Builder(
        builder: (context) {
          if (_messages == null) {
            return Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              buildMessages(),
              buildInput(context),
            ],
          );
        },
      ),
    );
  }
}
