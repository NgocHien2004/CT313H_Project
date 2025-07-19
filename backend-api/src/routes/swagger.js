const express = require("express");
const router = express.Router();
const swaggerUi = require("swagger-ui-express");
const fs = require("fs");
const path = require("path");

const swaggerDocument = JSON.parse(
  fs.readFileSync(path.join(__dirname, "../../doc/openapiSpec.json"), "utf8")
);

router.use("/", swaggerUi.serve, swaggerUi.setup(swaggerDocument));

module.exports = router;
