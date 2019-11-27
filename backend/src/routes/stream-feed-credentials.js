import { wrapAsync } from "../utils/controllers";
import { requireAuthHeader } from "../controllers/v1/authenticate/authenticate.action";
import { streamFeedCredentials } from "../controllers/v1/stream-feed-credentials/stream-feed-credentials.action";

module.exports = api => {
  api.route("/v1/stream-feed-credentials").post(requireAuthHeader, wrapAsync(streamFeedCredentials));
};
