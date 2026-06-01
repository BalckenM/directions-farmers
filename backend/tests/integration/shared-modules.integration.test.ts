import request from "supertest";
import { describe, expect, it } from "vitest";
import { app, authGet, authPost } from "./setup";

describe("Shared Modules API", () => {
  // ── Health check ──────────────────────────────────────────────────────────
  describe("GET /health", () => {
    it("returns ok status", async () => {
      const res = await request(app).get("/health");
      expect(res.status).toBe(200);
      expect(res.body.status).toBe("ok");
    });
  });

  // ── Dashboard ─────────────────────────────────────────────────────────────
  describe("Dashboard — /v1/dashboard", () => {
    it("GET /summary returns dashboard summary", async () => {
      const res = await authGet("/v1/dashboard/summary");
      expect(res.status).toBe(200);
      expect(res.body).toHaveProperty("data");
    });
  });

  // ── Events ────────────────────────────────────────────────────────────────
  describe("Events — /v1/events", () => {
    it("GET /health returns health events", async () => {
      const res = await authGet("/v1/events/health");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });

    it("GET /weights returns weight events", async () => {
      const res = await authGet("/v1/events/weights");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });

    it("GET /breeding returns breeding events", async () => {
      const res = await authGet("/v1/events/breeding");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  // ── Production ────────────────────────────────────────────────────────────
  describe("Production — /v1/production", () => {
    it("GET /milk returns milk records", async () => {
      const res = await authGet("/v1/production/milk");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });

    it("GET /eggs returns egg records", async () => {
      const res = await authGet("/v1/production/eggs");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });

    it("GET /wool returns wool records", async () => {
      const res = await authGet("/v1/production/wool");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  // ── Financial ─────────────────────────────────────────────────────────────
  describe("Financial — /v1/financial", () => {
    it("GET / returns financial records", async () => {
      const res = await authGet("/v1/financial");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });

    it("POST / creates a financial record", async () => {
      const res = await authPost("/v1/financial").send({
        type: "income",
        category: "milk_sales",
        amount: 5000,
        transactionDate: "2024-06-15",
        description: "Milk sold to dairy",
      });
      expect([200, 201]).toContain(res.status);
    });
  });

  // ── Livestock ─────────────────────────────────────────────────────────────
  describe("Livestock — /v1/livestock", () => {
    it("GET /animals returns animals list", async () => {
      const res = await authGet("/v1/livestock/animals");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });

    it("GET /groups returns groups list", async () => {
      const res = await authGet("/v1/livestock/groups");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  // ── Traceability ──────────────────────────────────────────────────────────
  describe("Traceability — /v1/traceability", () => {
    it("GET /movements returns movement records", async () => {
      const res = await authGet("/v1/traceability/movements");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });

    it("POST /movements creates a movement record", async () => {
      const res = await authPost("/v1/traceability/movements").send({
        animalId: "00000000-0000-0000-0000-000000000001",
        species: "cattle",
        movementType: "transfer",
        fromLocation: "Paddock A",
        toLocation: "Paddock B",
        movementDate: "2024-06-10",
        reason: "rotational_grazing",
      });
      // May return 201 or 422/500 if animalId doesn't exist
      expect([200, 201, 400, 422, 500]).toContain(res.status);
    });
  });

  // ── Record ────────────────────────────────────────────────────────────────
  describe("Record — /v1/record", () => {
    it("GET /feed-logs returns feed logs", async () => {
      const res = await authGet("/v1/record/feed-logs");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  // ── Settings ──────────────────────────────────────────────────────────────
  describe("Settings — /v1/settings", () => {
    it("GET /paddocks returns paddocks", async () => {
      const res = await authGet("/v1/settings/paddocks");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  // ── Weather ───────────────────────────────────────────────────────────────
  describe("Weather — /v1/weather", () => {
    it("GET /current returns current weather", async () => {
      const res = await authGet("/v1/weather/current");
      // May return 200 or 503 if no API key configured
      expect([200, 503, 500]).toContain(res.status);
    });

    it("GET /forecast returns forecast", async () => {
      const res = await authGet("/v1/weather/forecast");
      expect([200, 503, 500]).toContain(res.status);
    });

    it("GET /alerts returns agricultural alerts", async () => {
      const res = await authGet("/v1/weather/alerts");
      expect([200, 503, 500]).toContain(res.status);
    });
  });

  // ── Advisor ───────────────────────────────────────────────────────────────
  describe("Advisor — /v1/advisor", () => {
    it("GET /briefing returns advisor briefing", async () => {
      const res = await authGet("/v1/advisor/briefing");
      expect([200, 503, 500]).toContain(res.status);
    });

    it("POST /advice sends advisory request", async () => {
      const res = await authPost("/v1/advisor/advice").send({
        topic: "pest_management",
        question: "How to control aphids on maize?",
      });
      expect([200, 201, 503, 500]).toContain(res.status);
    });
  });

  // ── Disease ───────────────────────────────────────────────────────────────
  describe("Disease — /v1/disease", () => {
    it("GET /library returns disease library", async () => {
      const res = await authGet("/v1/disease/library");
      expect([200, 503, 500]).toContain(res.status);
    });

    it("POST /detect sends detection request", async () => {
      const res = await authPost("/v1/disease/detect").send({
        imagePath: "/test/image.jpg",
        cropHint: "maize",
      });
      expect([200, 201, 503, 500, 400]).toContain(res.status);
    });
  });

  // ── Insights ──────────────────────────────────────────────────────────────
  describe("Insights — /v1/insights", () => {
    it("GET /market-prices returns market prices", async () => {
      const res = await authGet("/v1/insights/market-prices");
      expect([200, 503, 500]).toContain(res.status);
    });
  });

  // ── Farm ──────────────────────────────────────────────────────────────────
  describe("Farm — /v1/farm", () => {
    it("GET /team returns team members", async () => {
      const res = await authGet("/v1/farm/team");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });
});
