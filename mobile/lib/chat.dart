import 'package:flutter/material.dart';

import 'api_service.dart';

class Chat extends StatefulWidget {
  Chat({Key key, @required this.account, @required this.user}) : super(key: key);

  final Map account;
  final String user;

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
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
    cancelChannel = await ApiService().listenToChannel(widget.account, widget.user, (messages) {
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
      await ApiService().postChatMessage(widget.account, widget.user, _messageController.text);
      _messageController.clear();
    }
  }

  Widget buildMessage(dynamic message) {
    return Row(
      mainAxisAlignment: message['userId'] == widget.account['user'] ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          child: Text(
            message['text'],
            style: TextStyle(color: message['userId'] == widget.account['user'] ? Colors.white : Colors.black),
          ),
          padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
          width: 200.0,
          decoration: BoxDecoration(
              color: message['userId'] == widget.account['user'] ? Colors.blueAccent : Colors.black12,
              borderRadius: BorderRadius.circular(8.0)),
          margin: EdgeInsets.only(bottom: 10.0, right: 10.0),
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
        title: Text("Chat with ${widget.user}"),
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
