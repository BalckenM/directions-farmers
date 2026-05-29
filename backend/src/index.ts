import { buildApp } from "./app";
import "./config/env"; // validate env vars first
import { env } from "./config/env";
import { pool } from "./config/database";

async function start() {
  // Verify DB is reachable before accepting traffic
  const conn = await pool.getConnection();
  conn.release();

  const app = buildApp();
  app.listen(env.PORT, () => {
    console.log(`Server listening on port ${env.PORT}`);
  });
}

start().catch((err) => {
  console.error("Failed to start server:", err);
  process.exit(1);
});
