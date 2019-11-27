import { authenticate, users } from "../controllers/v1/authenticate/authenticate.action";

import { wrapAsync } from "../utils/controllers";

module.exports = api => {
  api.route("/v1/authenticate").post(wrapAsync(authenticate));
  api.route("/v1/users").get(wrapAsync(users));
};
