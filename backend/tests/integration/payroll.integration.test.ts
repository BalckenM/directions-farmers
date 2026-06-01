import { describe, expect, it } from "vitest";
import { authGet, authPatch, authPost } from "./setup";

describe("Payroll API — /v1/payroll", () => {
  let employeeId: string;
  let payGroupId: string;

  describe("Employees — /v1/payroll/employees", () => {
    it("GET returns employees list", async () => {
      const res = await authGet("/v1/payroll/employees");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body)).toBe(true);
    });

    it("POST creates an employee", async () => {
      const res = await authPost("/v1/payroll/employees").send({
        employeeNumber: `EMP-${Date.now()}`,
        firstName: "PayTest",
        lastName: "Worker",
        startDate: "2024-01-15",
      });
      expect([200, 201]).toContain(res.status);
      employeeId = res.body.data?.id;
    });

    it("GET /:id returns single employee", async () => {
      if (!employeeId) return;
      const res = await authGet(`/v1/payroll/employees/${employeeId}`);
      expect(res.status).toBe(200);
    });

    it("PATCH /:id/terminate terminates an employee", async () => {
      if (!employeeId) return;
      const res = await authPatch(
        `/v1/payroll/employees/${employeeId}/terminate`,
      ).send({
        reason: "end_of_contract",
        effectiveDate: "2024-12-31",
      });
      expect([200, 204]).toContain(res.status);
    });
  });

  describe("Contracts — /v1/payroll/contracts", () => {
    it("GET returns contracts list", async () => {
      const res = await authGet("/v1/payroll/contracts");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body)).toBe(true);
    });
  });

  describe("Pay Groups — /v1/payroll/pay-groups", () => {
    it("GET returns pay groups", async () => {
      const res = await authGet("/v1/payroll/pay-groups");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body)).toBe(true);
      if (res.body.length > 0) {
        payGroupId = res.body[0].id;
      }
    });
  });

  describe("Pay Structures — /v1/payroll/pay-structures", () => {
    it("GET returns pay structures", async () => {
      const res = await authGet("/v1/payroll/pay-structures");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body)).toBe(true);
    });
  });

  describe("Pay Runs — /v1/payroll/pay-runs", () => {
    it("GET returns pay runs", async () => {
      const res = await authGet("/v1/payroll/pay-runs");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body)).toBe(true);
    });
  });

  describe("Payslips — /v1/payroll/payslips", () => {
    it("GET returns payslips", async () => {
      const res = await authGet("/v1/payroll/payslips");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body)).toBe(true);
    });
  });

  describe("Deductions — /v1/payroll/deductions", () => {
    it("GET returns deductions", async () => {
      const res = await authGet("/v1/payroll/deductions");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body)).toBe(true);
    });
  });

  describe("Deduction Rules — /v1/payroll/deduction-rules", () => {
    it("GET returns deduction rules", async () => {
      const res = await authGet("/v1/payroll/deduction-rules");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body)).toBe(true);
    });
  });

  describe("Garnishee Orders — /v1/payroll/garnishee-orders", () => {
    it("GET returns garnishee orders", async () => {
      const res = await authGet("/v1/payroll/garnishee-orders");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body)).toBe(true);
    });
  });

  describe("Transactions — /v1/payroll/transactions", () => {
    it("GET returns transactions", async () => {
      const res = await authGet("/v1/payroll/transactions");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body)).toBe(true);
    });
  });

  describe("Leave — /v1/payroll/leave-*", () => {
    it("GET /leave-requests returns leave requests", async () => {
      const res = await authGet("/v1/payroll/leave-requests");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body)).toBe(true);
    });

    it("GET /leave-types returns leave types", async () => {
      const res = await authGet("/v1/payroll/leave-types");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body)).toBe(true);
    });

    it("GET /leave-balances returns leave balances", async () => {
      const res = await authGet("/v1/payroll/leave-balances");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body)).toBe(true);
    });
  });

  describe("Piecework — /v1/payroll/piecework-logs", () => {
    it("GET returns piecework logs", async () => {
      const res = await authGet("/v1/payroll/piecework-logs");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body)).toBe(true);
    });
  });

  describe("Compliance Alerts — /v1/payroll/compliance-alerts", () => {
    it("GET returns compliance alerts", async () => {
      const res = await authGet("/v1/payroll/compliance-alerts");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body)).toBe(true);
    });
  });

  describe("Audit Log — /v1/payroll/audit-log", () => {
    it("GET returns audit log entries", async () => {
      const res = await authGet("/v1/payroll/audit-log");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body)).toBe(true);
    });
  });

  describe("Incidents — /v1/payroll/incidents", () => {
    it("GET returns incidents", async () => {
      const res = await authGet("/v1/payroll/incidents");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body)).toBe(true);
    });
  });

  describe("Communications — /v1/payroll/communications", () => {
    it("GET returns communications", async () => {
      const res = await authGet("/v1/payroll/communications");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body)).toBe(true);
    });
  });

  describe("Shifts — /v1/payroll/shifts", () => {
    it("GET returns shifts", async () => {
      const res = await authGet("/v1/payroll/shifts");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body)).toBe(true);
    });
  });

  describe("Task Assignments — /v1/payroll/task-assignments", () => {
    it("GET returns task assignments", async () => {
      const res = await authGet("/v1/payroll/task-assignments");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body)).toBe(true);
    });
  });

  describe("Attendance — /v1/payroll/attendance", () => {
    it("GET returns attendance records", async () => {
      const res = await authGet("/v1/payroll/attendance");
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body)).toBe(true);
    });
  });

  describe("Employer Config — /v1/payroll/employer-config", () => {
    it("GET returns employer configuration", async () => {
      const res = await authGet("/v1/payroll/employer-config");
      expect(res.status).toBe(200);
      expect(res.body).toBeDefined();
    });
  });
});
