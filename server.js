const express = require("express");
const mongoose = require("mongoose");
const dotenv = require("dotenv");

dotenv.config();

const app = express();

app.use(express.json());

mongoose
  .connect(process.env.MONGO_URI)
  .then(() => console.log("MongoDB connected"))
  .catch((err) => {
    console.error("MongoDB connection error:", err.message);
    process.exit(1);
  });

app.use("/api/auth", require("./routes/auth"));
app.use("/api/outpass", require("./routes/outpass"));
app.use("/api/student", require("./routes/student"));
app.use("/api/notifications", require("./routes/notification"));


app.get("/test", (req, res) => {
  res.send("Running successful");
});

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
