# TheStream: Building a Social Network w/ Stream and Flutter, Part 1

In this series, we'll be creating a simple video live chat social network, called TheStream, that has some of the features you'd expect: posting status updates to followers, direct messaging, and video live chat. 

In part 1, we'll be creating the ability to post an update to your followers. Stream's Activity Feed API makes it straightforward to build this sort of complex interaction. All source code for this application is available on [GitHub](https://github.com/psylinse/flutter_the_stream). This code is fully functional on both iOS and Android. 

For brevity, when we need to drop down to native code, we'll only focus on Android. You can find the corresponding iOS code to see how things are implemented. To keep things focused, we'll be showing the more important code snippets to get each pieces idea across. Often there is context around those code snippets which are important. Please refer to the full source if you're confused on how something works. Each snippet will be accompanied with a comment explaining which file and line to look at.

## Building TheStream: Activity Feeds

To build our social network we'll need both a backend and a mobile application. Most of the work is done in the mobile application, but we need the backend to securely create frontend tokens for interacting with the Stream API.

For the backend, we'll rely on [Express](https://expressjs.com/) (Node.js) leveraging Stream's [JavaScript library](https://github.com/GetStream/stream-js).

For the frontend, we'll build it with Flutter wrapping Stream's [Java](https://github.com/GetStream/stream-java) and [Swift](https://github.com/getstream/stream-swift) libraries. 

In order to post an update the app will perform these steps:

* User types their name into Flutter application to log in.
* Flutter registers user with our backend and receives a Stream Activity Feed [frontend token](https://getstream.io/blog/integrating-with-stream-backend-frontend-options/).
* User types in their post. Flutter app uses the Stream token to create a Stream activity by using Flutter's [platform channels ](https://flutter.dev/docs/development/platform-integration/platform-channels) to connect to [Stream's REST API](https://getstream.io/docs_rest/) via [Java](https://github.com/GetStream/stream-java) or [Swift](https://github.com/getstream/stream-swift).
* User views their posts. Flutter app gets their `user` activity via platform channel.

If another user wants to follow a user, the app goes through this process:
* Log in via backend (see above)
* User navigates to user list and selects a user to follow. Flutter app communicates with Stream API to create a follower relationship on their timeline.
* User views their timeline. Flutter app uses Stream API to retrieve their timeline, which is all the posts from their followers.

The code is split between the Flutter mobile application contained in the `mobile` directory and the Express backend is in the `backend` directory. See the README.md in each folder to see installing and running instructions. If you'd like to follow along with running code, make sure you get both the backend and mobile app running before continuing.

## Prerequisites

Basic knowledge of Node.js (JavaScript) and Flutter (Dart) is required to follow this tutorial. This code is intended to run locally on your machine. 

You'll need an account with [Stream](https://getstream.io/accounts/signup/) in order to follow along. Please make sure you can run a Flutter app, at least on Android. If you haven't done so, make sure you have Flutter [installed](https://flutter.dev/docs/get-started/install). If you're having issues building this project, please check if you can create run a simple Flutter application by following the instructions [here](https://flutter.dev/docs/get-started/test-drive)

Let's get to building!

## User posts a status update

### Step 1: Login
In order to communicate with Stream, we need a secure frontend token that allows our mobile application to authenticate with Stream. To do this, we'll need a backend endpoint that stores our Stream secrets and generates this token. Once we have this token, we don't need the backend to do anything else, since the mobile app has access to the full Stream API. 

We'll be building the login screen which looks like:

![](images/login.png)

To start let's layout our form in Flutter. In our `main.dart` file, we'll create a simple check for an account, and if we don't have one, show the user a login form:

```dart
// mobile/lib/main.dart:65
@override
Widget build(BuildContext context) {
  if (_account != null) {
    // ... boot app once we have logged in
  } else {
    return Scaffold(
      appBar: AppBar(
        title: Text("The Stream"),
      ),
      body: Builder(
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.all(12.0),
            child: Center(
              child: Column(
                children: [
                  TextField(
                    controller: _userController,
                  ),
                  RaisedButton(
                    onPressed: () => _login(context),
                    child: Text("Login"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
```

The `_account` variable is as simple `Map<String, String>` object which will contain the the backend `authToken` and a Stream `feedToken`. The `authToken` is used to make further requests the the backend, which we'll use later to retrieve a list of users. The `feedToken` is the Stream frontend token which allows access to the Stream API. 

In order to set the `_account` variable, we'll take the variable typed in by the user once they've pressed "Login". Here's our `_login(..)` function:

```dart
// mobile/lib/main.dart:45
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
```

We use the user's typed in name to get our credentials from the backend and store it in our `_account` variable. To do this, let's look at our implementation of `ApiService#login`:

```dart
// mobile/lib/api_service.dart:10
Future<Map> login(String user) async {
  var authResponse = await http.post('$_baseUrl/v1/users', body: {'sender': user});
  var authToken = json.decode(authResponse.body)['authToken'];
  var feedResponse = await http
      .post('$_baseUrl/v1/stream-feed-credentials', headers: {'Authorization': 'Bearer $authToken'});
  var feedToken = json.decode(feedResponse.body)['token'];

  return {'authToken': authToken, 'feedToken': feedToken};
}
```

Two things happen here. First we register a user with the backend and get an `authToken`. Using this `authToken` we ask the backend to create our Stream Activity Feed frontend token. 

The user registration endpoint simply stores the user in memory and generates a simple token for auth. This is not a real implementation and should be replaced by however authentication and user management works for your application. Because of this, we won't go into detail here (please refer to the source code if you're interested). 

For our Stream token, let's look at what the backend is doing to generate that:
```javascript
// backend/src/controllers/v1/stream-feed-credentials/stream-feed-credentials.action.js:6
exports.streamFeedCredentials = async (req, res) => {
  try {
    const data = req.body;
    const apiKey = process.env.STREAM_API_KEY;
    const apiSecret = process.env.STREAM_API_SECRET;
    const appId = process.env.STREAM_APP_ID;

    const client = stream.connect(apiKey, apiSecret, appId);

    await client.user(req.user.sender).getOrCreate({ name: req.user.sender });
    const token = client.createUserToken(req.user.sender);

    res.status(200).json({ token, apiKey, appId });
  } catch (error) {
    console.log(error);
    res.status(500).json({ error: error.message });
  }
};
```

This code uses our secret account credentials to create a Stream user and register the user's name. the `getOrCreate` call creates the user with a name. Once we've created the user, we return the necessary credentials to the mobile app.

Once we're logged in, we're ready to submit our first post!

### Step 2: 
