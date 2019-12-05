import 'package:flutter/material.dart';

import 'api_service.dart';

class People extends StatefulWidget {
  People({Key key, @required this.account}) : super(key: key);

  final Map account;

  @override
  _PeopleState createState() => _PeopleState();
}

class _PeopleState extends State<People> {
  Future<List> _users;

  @override
  void initState() {
    super.initState();
    _users = ApiService().users(widget.account);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
      future: _users,
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: snapshot.data
              .where((u) => u != widget.account['user'])
              .map((u) => ListTile(
                    title: Text(u),
                    onTap: () {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(content: Text("Click to follow"), actions: [
                          FlatButton(
                            child: const Text('Follow'),
                            onPressed: () async {
                              var result = await ApiService().follow(widget.account, u);
                              Navigator.pop(context, "Followed");
                            },
                          )
                        ]),
                      ).then<void>((String message) {
                        // The value passed to Navigator.pop() or null.
                        if (message != null) {
                          Scaffold.of(context)
                            ..removeCurrentSnackBar()
                            ..showSnackBar(SnackBar(
                              content: Text(message),
                            ));
                        }
                      });
                    },
                  ))
              .toList(),
        );
      },
    );
  }
}
