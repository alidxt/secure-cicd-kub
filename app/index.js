const express = require("express");
const app = express();

app.get("/", (req, res) => {
  res.json({ message: "Secure CI/CD K8s Demo Working 🚀" });
});

app.listen(3000, () => console.log("App running on port 3000"));
