> **_This API is not meant for production as there is no auth in place. Please
> use carefully in testing and development environments only!_**

## Getting Started

Create account an account with Stream.

Create a `.env` file within the main directory with the
following environment variables found on https://getstream.io/dashboard

```
NODE_ENV=production
PORT=8080

STREAM_APP_ID=<YOUR_STREAM_APP_ID>
STREAM_API_KEY=<YOUR_API_KEY>
STREAM_API_SECRET=<YOUR_API_SECRET>
```

> Note: You can reference `.env.example`.

To spin this up, clone it and run `yarn install` within the `backend` directory,
then run `yarn start`.

