# Stream Flutter: Building a Social Network with Stream and Flutter
## Part 3: Group Chat

The third part of our series we're building group chat into our social application. This allows users to chat with multiple people at the same time. We leverage [Stream Chat](https://getstream.io/chat/) to do the heavy lifting. This post assumes you've gone through [part 1](https://github.com/nparsons08/stream-flutter/tree/1-social) and [part 2](https://github.com/nparsons08/stream-flutter/tree/2-messaging). 

Using our code from part 2, we only focus on the Flutter application, since our backend gives us everything we need already. To recap, the backend generates a frontend token for Stream Chat which allows the Flutter application to communicate directly with the Stream Chat API. Also, since we have direct messaging implemented, there's no additional libraries. The previously installed Stream Chat [Android](https://github.com/GetStream/stream-chat-android) and [Swift](https://github.com/GetStream/stream-chat-swift) libraries are all we need.

The app goes through these steps to enable group chat:

* User navigates to a list of chat channels they can join. To start there will be none, so they must create the first one.
* The user hits "Create Chat Channel" and generates a chat channel with a name. 


