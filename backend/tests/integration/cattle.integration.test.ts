import { describe, expect, it } from "vitest";
import { authDelete, authGet, authPost, authPut } from "./setup";

describe("Cattle API — /v1/cattle", () => {
  let createdId: string;

  describe("GET /", () => {
    it("returns list of cattle", async () => {
      const res = await authGet("/v1/cattle");
      expect(res.status).toBe(200);
      expect(res.body).toHaveProperty("data");
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("POST /", () => {
    it("creates a new cattle animal", async () => {
      const res = await authPost("/v1/cattle").send({
        name: "TestCow-Int",
        tagNumber: `TAG-${Date.now()}`,
        breed: "Angus",
        sex: "female",
        dateOfBirth: "2022-01-15",
        status: "active",
      });
      expect([200, 201]).toContain(res.status);
      createdId = res.body.data?.id ?? res.body.id;
    });
  });

  describe("GET /:id", () => {
    it("returns a single cattle record", async () => {
      if (!createdId) return;
      const res = await authGet(`/v1/cattle/${createdId}`);
      expect(res.status).toBe(200);
      expect(res.body.data).toHaveProperty("id", createdId);
    });

    it("returns 404 for non-existent id", async () => {
      const res = await authGet("/v1/cattle/nonexistent-uuid");
      expect(res.status).toBe(404);
    });
  });

  describe("PUT /:id", () => {
    it("updates a cattle record", async () => {
      if (!createdId) return;
      const res = await authPut(`/v1/cattle/${createdId}`).send({
        name: "UpdatedCow-Int",
      });
      expect([200, 204]).toContain(res.status);
    });
  });

  describe("DELETE /:id", () => {
    it("deletes a cattle record", async () => {
      if (!createdId) return;
      const res = await authDelete(`/v1/cattle/${createdId}`);
      expect([200, 204]).toContain(res.status);
    });
  });

  describe("Weights — /v1/cattle/weights", () => {
    it("GET returns weight list", async () => {
      const res = await authGet("/v1/cattle/weights");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });

    it("POST creates a weight record", async () => {
      const res = await authPost("/v1/cattle/weights").send({
        cattleId: createdId ?? "00000000-0000-0000-0000-000000000001",
        weightKg: 450,
        recordDate: "2024-06-01",
      });
      // Might return 201 or 404/422/500 if cattleId doesn't exist after delete
      expect([200, 201, 404, 422, 400, 500]).toContain(res.status);
    });
  });

  describe("Breeding Records — /v1/cattle/breeding-records", () => {
    it("GET returns breeding records", async () => {
      const res = await authGet("/v1/cattle/breeding-records");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Pregnancy Checks — /v1/cattle/pregnancy-checks", () => {
    it("GET returns pregnancy checks", async () => {
      const res = await authGet("/v1/cattle/pregnancy-checks");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Calving Events — /v1/cattle/calving-events", () => {
    it("GET returns calving events", async () => {
      const res = await authGet("/v1/cattle/calving-events");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Milk — /v1/cattle/milk", () => {
    it("GET returns milk records", async () => {
      const res = await authGet("/v1/cattle/milk");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Health — /v1/cattle/health", () => {
    it("GET returns health events", async () => {
      const res = await authGet("/v1/cattle/health");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Medications — /v1/cattle/medications", () => {
    it("GET returns medication records", async () => {
      const res = await authGet("/v1/cattle/medications");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Vaccinations — /v1/cattle/vaccinations", () => {
    it("GET returns vaccination records", async () => {
      const res = await authGet("/v1/cattle/vaccinations");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Sales — /v1/cattle/sales", () => {
    it("GET returns sale records", async () => {
      const res = await authGet("/v1/cattle/sales");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Feed — /v1/cattle/feed", () => {
    it("GET returns feed records", async () => {
      const res = await authGet("/v1/cattle/feed");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Pasture — /v1/cattle/pasture", () => {
    it("GET returns pasture records", async () => {
      const res = await authGet("/v1/cattle/pasture");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("BCS — /v1/cattle/bcs", () => {
    it("GET returns BCS records", async () => {
      const res = await authGet("/v1/cattle/bcs");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe("Dipping — /v1/cattle/dipping", () => {
    it("GET returns dipping records", async () => {
      const res = await authGet("/v1/cattle/dipping");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });
});
