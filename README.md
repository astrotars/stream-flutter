# TheStream: Building a Social Network w/ Stream Activity Feed and Flutter, Part 1

In this series, we'll be creating a simple video live chat social network, called TheStream, that has some of the features you'd expect: posting updates to followers, direct messaging, and video live chat. 

In part 1, we'll be creating the ability to post an update to your followers.

## Building TheStream: Activity Feeds

To build our social network we'll need both a backend and a mobile application. Most of the work is done in the mobile application, but we need the backend to securely create frontend tokens for interacting with the Stream API.

For the backend, we'll rely on NodeJS leveraging Stream's [JavaScript library](https://github.com/GetStream/stream-js).

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


