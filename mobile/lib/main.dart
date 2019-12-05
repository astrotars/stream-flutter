import 'package:flutter/material.dart';

import 'api_service.dart';
import 'home.dart';
import 'new_activity.dart';
import 'people.dart';
import 'profile.dart';

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
  Map<String, String> _account;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future _login(BuildContext context) async {
    if (_userController.text.length > 0) {
      var creds = await ApiService().login(_userController.text);
      setState(() {
        _account = {
          'user': _userController.text,
          'authToken': creds['authToken'],
          'feedToken': creds['feedToken'],
        };
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
    if (_account != null) {
      var body;
      if (_selectedIndex == 0) {
        body = Home(account: _account);
      } else if (_selectedIndex == 1) {
        body = Profile(account: _account);
      } else {
        body = People(account: _account);
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
                      var messagePosted = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => NewActivity(account: _account)),
                      );

                      if (messagePosted != null) {
                        Scaffold.of(context)..showSnackBar(SnackBar(content: Text('Message Posted. Pull to refresh.')));
                      }
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
          return Container(
            padding: EdgeInsets.all(12.0),
            child: Center(
              child: Column(
                children: [
                  TextField(
                    controller: _userController,
                  ),
                  MaterialButton(
                    onPressed: () => _login(context),
                    child: Text("Login"),
                  ),
                ],
              ),
            ),
          );
        }),
      );
    }
  }
}
