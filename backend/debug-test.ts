import { randomUUID } from "crypto";
import request from "supertest";
import { buildApp } from "./src/app";
import { pool } from "./src/config/database";

async function main() {
  const app = buildApp();

  // Register
  const email = `debug-${Date.now()}@test.com`;
  const reg = await request(app).post("/v1/auth/register").send({
    firstName: "Debug",
    lastName: "User",
    email,
    password: "TestPass1234",
  });
  console.log("Register:", reg.status);

  const token = reg.body.data?.accessToken;
  if (!token) {
    console.log("No token:", JSON.stringify(reg.body));
    process.exit(1);
  }

  // Decode token to get owner ID
  const payload = JSON.parse(
    Buffer.from(token.split(".")[1], "base64url").toString(),
  );
  console.log("Token payload:", JSON.stringify(payload));

  // Activate modules
  const conn = await pool.getConnection();
  const [moduleRows] = await conn.execute(
    "SELECT id, slug FROM modules WHERE is_active = 1",
  );
  console.log(
    "Available modules:",
    (moduleRows as any[]).map((m: any) => m.slug),
  );

  for (const mod of moduleRows as any[]) {
    await conn.execute(
      `INSERT INTO farm_module_activations (id, farm_owner_id, module_id, is_active, activated_at, created_at)
       VALUES (?, ?, ?, 1, NOW(), NOW())
       ON DUPLICATE KEY UPDATE is_active = 1`,
      [randomUUID(), payload.sub, mod.id],
    );
  }
  conn.release();

  // Re-login to get token with modules
  const login = await request(app).post("/v1/auth/login").send({
    email,
    password: "TestPass1234",
  });
  const newToken = login.body.data?.accessToken;
  console.log("Login:", login.status);

  const newPayload = JSON.parse(
    Buffer.from(newToken.split(".")[1], "base64url").toString(),
  );
  console.log("New token modules:", newPayload.modules);

  // Try cattle
  const cattle = await request(app)
    .get("/v1/cattle")
    .set("Authorization", `Bearer ${newToken}`);
  console.log("Cattle:", cattle.status, JSON.stringify(cattle.body).slice(0, 500));

  // Try goats
  const goats = await request(app)
    .get("/v1/goats/weights")
    .set("Authorization", `Bearer ${newToken}`);
  console.log("Goats:", goats.status, JSON.stringify(goats.body).slice(0, 500));

  // Try payroll
  const payroll = await request(app)
    .get("/v1/payroll/employees")
    .set("Authorization", `Bearer ${newToken}`);
  console.log("Payroll:", payroll.status, JSON.stringify(payroll.body).slice(0, 500));

  await pool.end();
  process.exit(0);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
