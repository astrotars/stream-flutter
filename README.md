# Stream Flutter: Building a Social Network with Stream and Flutter
## Part 3: Group Chat

The third part of our series we're building group chat into our social application. This allows users to chat with multiple people at the same time. We leverage [Stream Chat](https://getstream.io/chat/) to do the heavy lifting. This post assumes you've gone through [part 1](https://github.com/nparsons08/stream-flutter/tree/1-social) and [part 2](https://github.com/nparsons08/stream-flutter/tree/2-messaging). 

Using our code from part 2, we only focus on the Flutter application, since our backend gives us everything we need already. To recap, the backend generates a frontend token for Stream Chat which allows the Flutter application to communicate directly with the Stream Chat API. Also, since we have direct messaging implemented, there's no additional libraries. The previously installed Stream Chat [Android](https://github.com/GetStream/stream-chat-android) and [Swift](https://github.com/GetStream/stream-chat-swift) libraries are all we need.

The app goes through these steps to enable group chat:

* User navigates to a list of chat channels they can join. To start there will be none, so they must create the first one.
* The user hits "Create Chat Channel" and generates a chat channel with an id. 
* The mobile app queries the channel for previous messages and indicates to Stream that we'd like to watch this channel for new messages. The mobile app listens for new messages.
* The user creates a new message and sends it to the Stream Chat API. Stream broadcasts this message to all users watching that channel. 
* When the message is broadcast, including messages the user created, the mobile application consumes the event and displays the message.

We rely on Stream's Android/Swift libraries to do most of the work communicating with the API. This is done by leveraging Flutter's (Swift/Kotlin) [Platform Channels](https://flutter.dev/docs/development/platform-integration/platform-channels) to communicate with native code (Kotlin/Swift). If you'd like to follow along, make sure you get both the backend and mobile app running part 2 before continuing.

## Prerequisites

Basic knowledge of [Node.js](https://nodejs.org/en/) (JavaScript), [Flutter](https://flutter.dev/) ([Dart](https://dart.dev/)), and [Kotlin](https://kotlinlang.org/), is required to follow this tutorial. Knowledge of Swift is useful if you want to browse the iOS impelementation. This code is intended to run locally on your machine. 

If you'd like to follow along, you'll need an account with [Stream](https://getstream.io/accounts/signup/). Please make sure you can run a Flutter app, at least on Android. If you haven't done so, make sure you have Flutter [installed](https://flutter.dev/docs/get-started/install). If you're having issues building this project, please check if you can create run a simple application by following the instructions [here](https://flutter.dev/docs/get-started/test-drive).

Once you have an account with Stream, you need to set up a development app (see [part 1](https://github.com/nparsons08/stream-flutter/tree/1-social)):

![](images/create-app.png)

You'll need to add the credentials from the Stream app to the source code for it to work. See both the `mobile` and `backend` READMEs. 

Let's get to building!


## User creates a chat room

## User sends a message

## User views messages



