import { wrapAsync } from "../utils/controllers";
import { requireAuthHeader } from "../controllers/v1/users/users.action";
import { streamChatCredentials } from "../controllers/v1/stream-chat-credentials/stream-chat-credentials.action";

module.exports = api => {
  api.route("/v1/stream-chat-credentials").post(requireAuthHeader, wrapAsync(streamChatCredentials));
};
