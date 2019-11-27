import { authenticate } from "../controllers/v1/authenticate";

import { wrapAsync } from "../utils/controllers";

module.exports = api => {
  api.route("/v1/authenticate").post(wrapAsync(authenticate));
};
