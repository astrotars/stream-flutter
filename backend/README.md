# Stream Encrypted Chat w/ Virgil Boilerplate API

> **_This API is not meant for production as there is no auth in place. Please
> use carefully in testing and development environments only!_**

## Getting Started

Create account an account with Stream and Virgil. With Virgil you need to create
a new Application and create new App Keys within that Application.

Create a `.env` file within the main directory with the
following environment variables found on https://getstream.io/dashboard and
https://dashboard.virgilsecurity.com/apps/<your_virgil_app_id>/keys:

```
NODE_ENV=production
PORT=8080

STREAM_API_KEY=<YOUR_API_KEY>
STREAM_API_SECRET=<YOUR_API_SECRET>
VIRGIL_APP_ID=<YOUR_VIRGIL_APP_ID>
VIRGIL_KEY_ID=<YOUR_VIRGIL_KEY_ID>
VIRGIL_PRIVATE_KEY=<YOUR_VIRGIL_PRIVATE_KEY>
```

> Note: You can reference `.env.example`.

To spin this up, clone it and run `yarn install` within the `backend` directory,
then run `yarn start`.

