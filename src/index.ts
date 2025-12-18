import express from "express";

const app = express();
const port = 3000;

app.get("/", (_req, res) => {
  res.send("🚀 RPi Node + TypeScript helyi starter fut!");
});

app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
