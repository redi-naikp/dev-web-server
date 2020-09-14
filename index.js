const express = require("express");
const morgan = require("morgan");

const app = express();
const port = process.env.PORT || 8000;

app.use(morgan("combined"));

app.get("/", (req, res) => {
  res.send("Hello Team, All the best");
});

app.listen(port, () => console.log(`Hello Core Processing Team ${port}!`));
