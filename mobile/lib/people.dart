import 'package:flutter/material.dart';

import 'stream_service.dart';
import 'users.dart';

class People extends StatefulWidget {
  People({Key key, @required this.user, @required this.streamToken}) : super(key: key);

  final String user;
  final String streamToken;

  @override
  _PeopleState createState() => _PeopleState();
}

class _PeopleState extends State<People> {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => ListView(
        children: users
            .where((u) => u != widget.user)
            .map((u) => ListTile(
                  title: Text(u),
                  onTap: () {
                    showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(content: Text("Select an action"), actions: [
                        FlatButton(
                          child: const Text('Unfollow'),
                          onPressed: () {
                            Navigator.pop(context, "Unfollowed");
                          },
                        ),
                        FlatButton(
                          child: const Text('Follow'),
                          onPressed: () async {
                            var result = await StreamService().follow(widget.user, widget.streamToken, u);
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
      ),
    );
  }
}
