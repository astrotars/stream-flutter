import 'package:flutter/material.dart';

import 'api_service.dart';
import 'users.dart';

class People extends StatefulWidget {
  People({Key key, @required this.account}) : super(key: key);

  final Map account;

  @override
  _PeopleState createState() => _PeopleState();
}

class _PeopleState extends State<People> {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => ListView(
        children: users
            .where((u) => u != widget.account['user'])
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
      ),
    );
  }
}
