import { describe, expect, it } from "vitest";
import { authGet } from "./setup";

describe("Goat API — /v1/goats", () => {
  describe("Weights — /v1/goats/weights", () => {
    it("GET returns weight records", async () => {
      const res = await authGet("/v1/goats/weights");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Matings — /v1/goats/matings", () => {
    it("GET returns mating records", async () => {
      const res = await authGet("/v1/goats/matings");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Pregnancy Checks — /v1/goats/pregnancy-checks", () => {
    it("GET returns pregnancy checks", async () => {
      const res = await authGet("/v1/goats/pregnancy-checks");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Kidding — /v1/goats/kidding", () => {
    it("GET returns kidding events", async () => {
      const res = await authGet("/v1/goats/kidding");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Milk — /v1/goats/milk", () => {
    it("GET returns milk records", async () => {
      const res = await authGet("/v1/goats/milk");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Shearing — /v1/goats/shearing", () => {
    it("GET returns shearing records", async () => {
      const res = await authGet("/v1/goats/shearing");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Health — /v1/goats/health", () => {
    it("GET returns health events", async () => {
      const res = await authGet("/v1/goats/health");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Medications — /v1/goats/medications", () => {
    it("GET returns medication records", async () => {
      const res = await authGet("/v1/goats/medications");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Vaccinations — /v1/goats/vaccinations", () => {
    it("GET returns vaccination records", async () => {
      const res = await authGet("/v1/goats/vaccinations");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Sales — /v1/goats/sales", () => {
    it("GET returns sale records", async () => {
      const res = await authGet("/v1/goats/sales");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Feed — /v1/goats/feed", () => {
    it("GET returns feed records", async () => {
      const res = await authGet("/v1/goats/feed");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Pasture — /v1/goats/pasture", () => {
    it("GET returns pasture records", async () => {
      const res = await authGet("/v1/goats/pasture");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("BCS — /v1/goats/bcs", () => {
    it("GET returns body condition score records", async () => {
      const res = await authGet("/v1/goats/bcs");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("FAMACHA — /v1/goats/famacha", () => {
    it("GET returns FAMACHA records", async () => {
      const res = await authGet("/v1/goats/famacha");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });
});
