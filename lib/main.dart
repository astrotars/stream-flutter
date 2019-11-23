import 'package:flutter/material.dart';
import 'package:flutter_the_stream/users.dart';

import 'home.dart';
import 'new_activity.dart';
import 'people.dart';
import 'profile.dart';
import 'stream_service.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Stream',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'The Stream'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final _userController = TextEditingController();
  String _user;
  String _streamToken;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future _login(BuildContext context) async {
    if (users.contains(_userController.text)) {
      String token = await StreamService().getToken(_userController.text);
      setState(() {
        _user = _userController.text;
        _streamToken = token;
      });
    } else {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid User'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user != null && _streamToken != null) {
      var body;
      if (_selectedIndex == 0) {
        body = Home(user: _user, streamToken: _streamToken);
      } else if (_selectedIndex == 1) {
        body = Profile(user: _user, streamToken: _streamToken);
      } else {
        body = People(user: _user, streamToken: _streamToken);
      }

      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: body,
        floatingActionButton: _selectedIndex == 1
            ? Builder(
                builder: (context) {
                  return FloatingActionButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => NewActivity(user: _user, streamToken: _streamToken)),
                      );

                      Scaffold.of(context)..showSnackBar(SnackBar(content: Text('Message Posted. Pull to refresh.')));
                    },
                    tooltip: 'Increment',
                    child: Icon(Icons.add),
                  );
                },
              )
            : null,
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: Text('Home'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              title: Text('Profile'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              title: Text('People'),
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text("Login"),
        ),
        body: Builder(builder: (BuildContext context) {
          return Center(
            child: Column(
              children: [
                Text("User"),
                TextField(
                  controller: _userController,
                ),
                MaterialButton(
                  onPressed: () => _login(context),
                  child: Text("Login"),
                ),
              ],
            ),
          );
        }),
      );
    }
  }
}
