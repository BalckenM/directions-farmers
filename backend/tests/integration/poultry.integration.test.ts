import { describe, expect, it } from "vitest";
import { authDelete, authGet, authPost } from "./setup";

describe("Poultry API — /v1/poultry", () => {
  let flockId: string;

  describe("Flocks — /v1/poultry/flocks", () => {
    it("GET returns flocks list", async () => {
      const res = await authGet("/v1/poultry/flocks");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });

    it("POST creates a new flock", async () => {
      const res = await authPost("/v1/poultry/flocks").send({
        flockName: `TestFlock-${Date.now()}`,
        species: "layer",
        breed: "Rhode Island Red",
        startDate: "2024-03-01",
        initialCount: 50,
      });
      expect([200, 201]).toContain(res.status);
      flockId = res.body.data?.id;
    });

    it("GET /:id returns a single flock", async () => {
      if (!flockId) return;
      const res = await authGet(`/v1/poultry/flocks/${flockId}`);
      expect(res.status).toBe(200);
    });

    it("DELETE /:id removes flock", async () => {
      if (!flockId) return;
      const res = await authDelete(`/v1/poultry/flocks/${flockId}`);
      expect([200, 204]).toContain(res.status);
    });
  });

  describe("Daily Records — /v1/poultry/daily-records", () => {
    it("GET returns daily records", async () => {
      const res = await authGet("/v1/poultry/daily-records");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Vaccination Schedules — /v1/poultry/vaccination-schedules", () => {
    it("GET returns vaccination schedules", async () => {
      const res = await authGet("/v1/poultry/vaccination-schedules");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Feed Phases — /v1/poultry/feed-phases", () => {
    it("GET returns feed phases", async () => {
      const res = await authGet("/v1/poultry/feed-phases");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Harvest Records — /v1/poultry/harvest-records", () => {
    it("GET returns harvest records", async () => {
      const res = await authGet("/v1/poultry/harvest-records");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Medication Logs — /v1/poultry/medication-logs", () => {
    it("GET returns medication logs", async () => {
      const res = await authGet("/v1/poultry/medication-logs");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Disease Events — /v1/poultry/disease-events", () => {
    it("GET returns disease events", async () => {
      const res = await authGet("/v1/poultry/disease-events");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Environment Readings — /v1/poultry/environment-readings", () => {
    it("GET returns environment readings", async () => {
      const res = await authGet("/v1/poultry/environment-readings");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Inventory — /v1/poultry/inventory-items", () => {
    it("GET returns inventory items", async () => {
      const res = await authGet("/v1/poultry/inventory-items");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Egg Sales — /v1/poultry/egg-sales", () => {
    it("GET returns egg sales", async () => {
      const res = await authGet("/v1/poultry/egg-sales");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Chick Sales — /v1/poultry/chick-sales", () => {
    it("GET returns chick sales", async () => {
      const res = await authGet("/v1/poultry/chick-sales");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });
});
