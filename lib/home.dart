import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  Home({Key key, this.user, this.streamToken}) : super(key: key);

  final String user;
  final String streamToken;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Text("${widget.streamToken}");
  }
}
