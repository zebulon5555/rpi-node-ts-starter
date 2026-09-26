import express from "express";

export const app = express();

app.get("/", (_req, res) => {
  res.send("🚀 RPi Node + TypeScript helyi starter fut!");
});

app.get("/health", (_req, res) => {
  res.status(200).json({ status: "ok" });
});
