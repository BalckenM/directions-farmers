import { describe, expect, it } from "vitest";
import { authDelete, authGet, authPost, authPut } from "./setup";

describe("Crop API — /v1/crop", () => {
  let fieldId: string;
  let seasonId: string;
  let planId: string;

  describe("Categories — /v1/crop/categories", () => {
    it("GET returns crop categories", async () => {
      const res = await authGet("/v1/crop/categories");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Crops — /v1/crop/crops", () => {
    it("GET returns crops list", async () => {
      const res = await authGet("/v1/crop/crops");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Fields — /v1/crop/fields", () => {
    it("GET returns fields list", async () => {
      const res = await authGet("/v1/crop/fields");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });

    it("POST creates a field", async () => {
      const res = await authPost("/v1/crop/fields").send({
        name: `TestField-${Date.now()}`,
        areaHectares: 5.5,
        soilType: "loam",
        irrigationType: "drip",
      });
      expect([200, 201]).toContain(res.status);
      fieldId = res.body.data?.id;
    });

    it("GET /:id returns single field", async () => {
      if (!fieldId) return;
      const res = await authGet(`/v1/crop/fields/${fieldId}`);
      expect(res.status).toBe(200);
    });

    it("PUT /:id updates a field", async () => {
      if (!fieldId) return;
      const res = await authPut(`/v1/crop/fields/${fieldId}`).send({
        name: "UpdatedField",
        areaHectares: 6.0,
      });
      expect([200, 204]).toContain(res.status);
    });

    it("DELETE /:id removes a field", async () => {
      if (!fieldId) return;
      const res = await authDelete(`/v1/crop/fields/${fieldId}`);
      expect([200, 204]).toContain(res.status);
    });
  });

  describe("Seasons — /v1/crop/seasons", () => {
    it("GET returns seasons", async () => {
      const res = await authGet("/v1/crop/seasons");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });

    it("POST creates a season", async () => {
      const res = await authPost("/v1/crop/seasons").send({
        name: `Season-${Date.now()}`,
        startDate: "2024-09-01",
        endDate: "2025-03-31",
      });
      expect([200, 201]).toContain(res.status);
      seasonId = res.body.data?.id;
    });

    it("DELETE /:id removes season", async () => {
      if (!seasonId) return;
      const res = await authDelete(`/v1/crop/seasons/${seasonId}`);
      expect([200, 204]).toContain(res.status);
    });
  });

  describe("Planting Plans — /v1/crop/planting-plans", () => {
    it("GET returns planting plans", async () => {
      const res = await authGet("/v1/crop/planting-plans");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Tasks — /v1/crop/tasks", () => {
    it("GET returns tasks", async () => {
      const res = await authGet("/v1/crop/tasks");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Pest Observations — /v1/crop/pest-observations", () => {
    it("GET returns pest observations", async () => {
      const res = await authGet("/v1/crop/pest-observations");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Spray Records — /v1/crop/spray-records", () => {
    it("GET returns spray records", async () => {
      const res = await authGet("/v1/crop/spray-records");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Expenses — /v1/crop/expenses", () => {
    it("GET returns expenses", async () => {
      const res = await authGet("/v1/crop/expenses");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Harvest Records — /v1/crop/harvest-records", () => {
    it("GET returns harvest records", async () => {
      const res = await authGet("/v1/crop/harvest-records");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Calendar Events — /v1/crop/calendar-events", () => {
    it("GET returns calendar events", async () => {
      const res = await authGet("/v1/crop/calendar-events");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Sales — /v1/crop/sales", () => {
    it("GET returns sales", async () => {
      const res = await authGet("/v1/crop/sales");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Advisory Content — /v1/crop/advisory-content", () => {
    it("GET returns advisory content", async () => {
      const res = await authGet("/v1/crop/advisory-content");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });
});
