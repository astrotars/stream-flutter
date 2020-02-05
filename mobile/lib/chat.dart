import 'package:flutter/material.dart';

class Chat extends StatefulWidget {
  Chat({Key key, @required this.account, @required this.user}) : super(key: key);

  final Map account;
  final String user;

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future _postMessage(BuildContext context) async {
//    if (_messageController.text.length > 0) {
//      await ApiService().postMessage(widget.account, _messageController.text);
//      Navigator.pop(context, true);
//    } else {
//      Scaffold.of(context).showSnackBar(
//        SnackBar(
//          content: Text('Please type a message'),
//        ),
//      );
//    }
  }

  Widget buildMessage(String user, String message) {
    return Row(
        mainAxisAlignment: user == widget.account['user'] ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            child: Text(
              message,
              style: TextStyle(color: user == widget.account['user'] ? Colors.white : Colors.black),
            ),
            padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
            width: 200.0,
            decoration: BoxDecoration(color: user == widget.account['user'] ? Colors.blueAccent : Colors.black12, borderRadius: BorderRadius.circular(8.0)),
            margin: EdgeInsets.only(bottom: 10.0, right: 10.0),
          )
        ]);
  }

  Widget buildMessages() {
    return Flexible(
      child: ListView(
        padding: EdgeInsets.all(10.0),
        reverse: true,
        children: [
          buildMessage(widget.account['user'], 'some message'),
          buildMessage(widget.user, 'another message'),
          buildMessage(widget.user, 'another message 5555 '),
          buildMessage(widget.user, 'another message 5555 '),
          buildMessage(widget.user, 'another message 5555 '),
          buildMessage(widget.user, 'another message 5555 '),
          buildMessage(widget.user, 'another message 5555 '),
          buildMessage(widget.user, 'another message 5555 '),
          buildMessage(widget.user, 'another message 5555 '),
          buildMessage(widget.user, 'another message 5555 '),
          buildMessage(widget.user, 'another message 5555 '),
          buildMessage(widget.user, 'another message 5555 '),
          buildMessage(widget.user, 'another message 5555 '),
          buildMessage(widget.user, 'another message 5555 '),
          buildMessage(widget.user, 'another message 5555 '),
          buildMessage(widget.user, 'another message 5555 '),
          buildMessage(widget.user, 'another message 5555 '),
          buildMessage(widget.user, 'another message 5555 '),
          buildMessage(widget.user, 'another message 5555 '),
          buildMessage(widget.user, 'another message 5555 '),
          buildMessage(widget.user, 'another message 5555 '),
          buildMessage(widget.user, 'another message 5555 '),
          buildMessage(widget.account['user'], 'response'),
        ],
      ),
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: false
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
              color: Colors.white.withOpacity(0.8),
            )
          : Container(),
    );
  }

  Widget buildInput() {
    return Container(
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
                onPressed: () => 0,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.blueGrey, width: 0.5)), color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat: ${widget.user}"),
      ),
      body: Builder(
        builder: (context) {
          return Stack(children: [
            Column(children: [
              buildMessages(),
              buildInput(),
            ]),
            buildLoading(),
          ]);
        },
      ),
    );
  }
}
