import { wrapAsync } from "../utils/controllers";
import { requireAuthHeader } from "../controllers/v1/authenticate/authenticate.action";
import { streamCredentials } from "../controllers/v1/stream-credentials/stream-credentials.action";

module.exports = api => {
  api.route("/v1/stream-credentials").post(requireAuthHeader, wrapAsync(streamCredentials));
};
