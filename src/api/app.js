var express = require("express")
  , morgan = require("morgan")
  , bodyParser = require("body-parser")
  , cookieParser = require("cookie-parser")
  , session = require("express-session")
  , config = require("./config")
  , helpers = require("./helpers")
  , cart = require("./api/cart")
  , catalogue = require("./api/catalogue")
  , orders = require("./api/orders")
  , user = require("./api/user")
  , metrics = require("./api/metrics")
  , health = require("./api/health")
  , app = express();

app.use(helpers.rewriteSlash);
app.use(metrics);
app.use(health);
app.use(session(config.session()));

app.use(bodyParser.json());
app.use(cookieParser());
app.use(morgan(config.prod() ? "combined" : "dev", {
  // skip: () => config.test(),
}));

/* Mount API endpoints */
const api = express.Router();
api.use(health);
api.use(helpers.sessionMiddleware);
api.use(cart);
api.use(catalogue);
api.use(orders);
api.use(user);
// mount to app
app.use(api); // back-compat with weave
app.use('/api', api); // expose services as `/api/{service}`

app.disable('x-powered-by');
app.use(helpers.errorHandler);

module.exports = app;