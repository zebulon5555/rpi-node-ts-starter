import assert from "node:assert/strict";
import { once } from "node:events";
import test from "node:test";
import { app } from "./app";

async function request(path: string) {
  const server = app.listen(0, "127.0.0.1");
  await once(server, "listening");
  const address = server.address();
  assert.ok(address && typeof address !== "string");

  try {
    return await fetch(`http://127.0.0.1:${address.port}${path}`);
  } finally {
    server.close();
    await once(server, "close");
  }
}

test("health endpoint reports ready", async () => {
  const response = await request("/health");
  assert.equal(response.status, 200);
  assert.deepEqual(await response.json(), { status: "ok" });
});

test("root endpoint provides the starter page", async () => {
  const response = await request("/");
  assert.equal(response.status, 200);
  assert.match(await response.text(), /RPi Node \+ TypeScript/);
});
