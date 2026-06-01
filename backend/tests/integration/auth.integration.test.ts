import request from "supertest";
import { describe, expect, it } from "vitest";
import { app, authGet, refreshToken } from "./setup";

describe("Auth API — /v1/auth", () => {
  describe("POST /register", () => {
    it("registers a new user and returns tokens", async () => {
      const res = await request(app).post("/v1/auth/register").send({
        firstName: "New",
        lastName: "User",
        email: `new-user-${Date.now()}@test.com`,
        password: "SecurePass1!",
      });
      expect(res.status).toBe(201);
      expect(res.body.data).toHaveProperty("accessToken");
      expect(res.body.data).toHaveProperty("refreshToken");
    });

    it("returns 422 for missing required fields", async () => {
      const res = await request(app).post("/v1/auth/register").send({
        email: "bad@test.com",
      });
      expect(res.status).toBe(422);
    });

    it("returns 409 for duplicate email", async () => {
      const email = `dup-${Date.now()}@test.com`;
      await request(app).post("/v1/auth/register").send({
        firstName: "Dup",
        lastName: "User",
        email,
        password: "SecurePass1!",
      });
      const res = await request(app).post("/v1/auth/register").send({
        firstName: "Dup",
        lastName: "User",
        email,
        password: "SecurePass1!",
      });
      expect(res.status).toBe(409);
    });
  });

  describe("POST /login", () => {
    it("returns tokens for valid credentials", async () => {
      const email = `login-test-${Date.now()}@test.com`;
      await request(app).post("/v1/auth/register").send({
        firstName: "Login",
        lastName: "Tester",
        email,
        password: "SecurePass1!",
      });
      const res = await request(app).post("/v1/auth/login").send({
        email,
        password: "SecurePass1!",
      });
      expect(res.status).toBe(200);
      expect(res.body.data.accessToken).toBeTruthy();
    });

    it("returns 401 for invalid password", async () => {
      const email = `login-bad-${Date.now()}@test.com`;
      await request(app).post("/v1/auth/register").send({
        firstName: "Bad",
        lastName: "Login",
        email,
        password: "SecurePass1!",
      });
      const res = await request(app).post("/v1/auth/login").send({
        email,
        password: "WrongPassword!",
      });
      expect(res.status).toBe(401);
    });
  });

  describe("POST /refresh", () => {
    it("returns new tokens for a valid refresh token", async () => {
      const res = await request(app).post("/v1/auth/refresh").send({
        refreshToken,
      });
      expect(res.status).toBe(200);
      expect(res.body.data.accessToken).toBeTruthy();
    });

    it("returns 401 for invalid refresh token", async () => {
      const res = await request(app).post("/v1/auth/refresh").send({
        refreshToken: "invalid-token",
      });
      expect(res.status).toBe(401);
    });
  });

  describe("GET /me", () => {
    it("returns current user with valid token", async () => {
      const res = await authGet("/v1/auth/me");
      expect(res.status).toBe(200);
      expect(res.body.data).toHaveProperty("email");
    });

    it("returns 401 without token", async () => {
      const res = await request(app).get("/v1/auth/me");
      expect(res.status).toBe(401);
    });
  });

  describe("POST /forgot-password", () => {
    it("returns 200 even for non-existent email (no leak)", async () => {
      const res = await request(app).post("/v1/auth/forgot-password").send({
        email: "nonexistent@test.com",
      });
      // Should return 200/204 regardless to not leak user existence
      expect([200, 204]).toContain(res.status);
    });
  });
});
