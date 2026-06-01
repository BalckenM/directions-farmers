/**
 * Integration test setup — uses the REAL Express app + REAL database.
 * No mocks. Supertest sends actual HTTP requests through the middleware stack.
 *
 * Requirements:
 *   - DATABASE_URL pointing to a seeded database
 *   - All env vars properly set (uses backend/.env)
 */
import { randomUUID } from "crypto";
import { type Application } from "express";
import request from "supertest";
import { afterAll, beforeAll } from "vitest";
import { buildApp } from "../../src/app";
import { pool } from "../../src/config/database";

export let app: Application;
export let token: string; // access token for authenticated requests
export let refreshToken: string;
export let testOwnerId: string;

// Test user credentials
const TEST_EMAIL = `integration-test-${Date.now()}@4dfarmer.app`;
const TEST_PASSWORD = "TestPass123!";
const TEST_FIRST_NAME = "Integration";
const TEST_LAST_NAME = "Tester";

beforeAll(async () => {
  app = buildApp();

  // Register a test user
  const registerRes = await request(app).post("/v1/auth/register").send({
    firstName: TEST_FIRST_NAME,
    lastName: TEST_LAST_NAME,
    email: TEST_EMAIL,
    password: TEST_PASSWORD,
  });

  if (registerRes.status !== 201 && registerRes.status !== 200) {
    throw new Error(
      `Registration failed (${registerRes.status}): ${JSON.stringify(registerRes.body)}`,
    );
  }

  token = registerRes.body.data?.accessToken ?? registerRes.body.accessToken;
  refreshToken =
    registerRes.body.data?.refreshToken ?? registerRes.body.refreshToken;

  if (!token) {
    throw new Error(
      `No access token in register response: ${JSON.stringify(registerRes.body)}`,
    );
  }

  // Decode owner ID from JWT
  const payload = JSON.parse(
    Buffer.from(token.split(".")[1], "base64url").toString(),
  );
  testOwnerId = payload.sub;

  // Activate ALL modules for this test user so every route is accessible
  const conn = await pool.getConnection();
  try {
    // Get real module IDs from the modules table
    const [moduleRows] = await conn.execute(
      "SELECT id, slug FROM modules WHERE is_active = 1",
    );

    for (const mod of moduleRows as Array<{ id: string; slug: string }>) {
      await conn.execute(
        `INSERT INTO farm_module_activations (id, farm_owner_id, module_id, is_active, activated_at, created_at)
         VALUES (?, ?, ?, 1, NOW(), NOW())
         ON DUPLICATE KEY UPDATE is_active = 1`,
        [randomUUID(), testOwnerId, mod.id],
      );
    }
  } finally {
    conn.release();
  }

  // Re-login to get a fresh token that includes all modules in the payload
  const loginRes = await request(app).post("/v1/auth/login").send({
    email: TEST_EMAIL,
    password: TEST_PASSWORD,
  });

  if (loginRes.status === 200 || loginRes.status === 201) {
    token = loginRes.body.data?.accessToken ?? loginRes.body.accessToken;
    refreshToken =
      loginRes.body.data?.refreshToken ?? loginRes.body.refreshToken;
  }
}, 30000);

afterAll(async () => {
  // Clean up test user module activations
  try {
    const conn = await pool.getConnection();
    try {
      await conn.execute(
        "DELETE FROM farm_module_activations WHERE farm_owner_id = ?",
        [testOwnerId],
      );
    } finally {
      conn.release();
    }
  } catch {
    // ignore cleanup errors
  }
  await pool.end();
}, 10000);

/** Helper to make authenticated GET request */
export function authGet(path: string) {
  return request(app).get(path).set("Authorization", `Bearer ${token}`);
}

/** Helper to make authenticated POST request */
export function authPost(path: string) {
  return request(app).post(path).set("Authorization", `Bearer ${token}`);
}

/** Helper to make authenticated PUT request */
export function authPut(path: string) {
  return request(app).put(path).set("Authorization", `Bearer ${token}`);
}

/** Helper to make authenticated PATCH request */
export function authPatch(path: string) {
  return request(app).patch(path).set("Authorization", `Bearer ${token}`);
}

/** Helper to make authenticated DELETE request */
export function authDelete(path: string) {
  return request(app).delete(path).set("Authorization", `Bearer ${token}`);
}
