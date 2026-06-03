import { buildApp } from "./app";
import { pool } from "./config/database";
import "./config/env"; // validate env vars first
import { env } from "./config/env";
import { closeRedis } from "./lib/redis";

async function start() {
  // Verify DB is reachable before accepting traffic
  const conn = await pool.getConnection();
  conn.release();
  const app = buildApp();
  const server = app.listen(env.PORT, () => {
    console.log(`Server listening on port ${env.PORT}`);
  });

  // Graceful shutdown
  const shutdown = async () => {
    console.log("Shutting down...");
    server.close();
    await closeRedis();
    await pool.end();
    process.exit(0);
  };
  process.on("SIGTERM", shutdown);
  process.on("SIGINT", shutdown);
}

start().catch((err) => {
  console.error("Failed to start server:", err);
  process.exit(1);
});
