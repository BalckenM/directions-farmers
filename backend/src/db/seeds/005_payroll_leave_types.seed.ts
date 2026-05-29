import { sql } from "drizzle-orm";
import { db } from "../../config/database";

/**
 * Seed: payroll_leave_types
 *
 * Inserts the four SA BCEA standard leave types using the exact same
 * ids, codes, and values defined in the Dart mock data source
 * (payroll_mock_data_source.dart → _seedLeaveTypes()).
 *
 * farm_owner_id = 'system' marks these as installation-level templates.
 * When a new farm owner registers the onboarding flow can copy these
 * rows (or the API can fall back to them when the farm owner has no
 * custom leave types defined yet).
 *
 * Idempotent: ON DUPLICATE KEY UPDATE fires on the fixed primary-key id,
 * so re-running the seed only refreshes the field values — it never
 * inserts duplicates.
 *
 * Leave types (BCEA 2024/2025):
 *   ANNUAL     — 15 working days per year             (paid)
 *   SICK       — 30 days in a 36-month cycle (BCEA s22)  (paid)
 *   MATERNITY  — 4 consecutive months         (BCEA s25) (unpaid)
 *   FAMILY     — 3 days per year              (BCEA s27) (paid)
 */

const now = new Date().toISOString().slice(0, 19).replace("T", " ");

const leaveTypes: Array<{
  id: string;
  code: string;
  name: string;
  accrualDaysPerYear: number;
  isPaid: boolean;
  requiresApproval: boolean;
  colorHex: string;
  description: string | null;
}> = [
  {
    id: "lt_annual",
    code: "ANNUAL",
    name: "Annual Leave",
    accrualDaysPerYear: 15,
    isPaid: true,
    requiresApproval: true,
    colorHex: "#2E7D32",
    description: null,
  },
  {
    id: "lt_sick",
    code: "SICK",
    name: "Sick Leave",
    accrualDaysPerYear: 30,
    isPaid: true,
    requiresApproval: false,
    colorHex: "#F57F17",
    description: "30 days in a 36-month cycle (BCEA s22)",
  },
  {
    id: "lt_maternity",
    code: "MATERNITY",
    name: "Maternity Leave",
    accrualDaysPerYear: 120,
    isPaid: false,
    requiresApproval: true,
    colorHex: "#9C27B0",
    description: "4 consecutive months — unpaid (BCEA s25)",
  },
  {
    id: "lt_family",
    code: "FAMILY",
    name: "Family Responsibility",
    accrualDaysPerYear: 3,
    isPaid: true,
    requiresApproval: true,
    colorHex: "#1565C0",
    description: "3 days per year (BCEA s27)",
  },
];

export async function runPayrollLeaveTypesSeed(): Promise<void> {
  for (const lt of leaveTypes) {
    await db.execute(sql`
      INSERT INTO payroll_leave_types
        (id, farm_owner_id, code, name, accrual_days_per_year,
         is_paid, requires_approval, color_hex, description, created_at)
      VALUES
        (${lt.id}, 'system', ${lt.code}, ${lt.name}, ${lt.accrualDaysPerYear},
         ${lt.isPaid}, ${lt.requiresApproval}, ${lt.colorHex}, ${lt.description}, ${now})
      ON DUPLICATE KEY UPDATE
        code               = VALUES(code),
        name               = VALUES(name),
        accrual_days_per_year = VALUES(accrual_days_per_year),
        is_paid            = VALUES(is_paid),
        requires_approval  = VALUES(requires_approval),
        color_hex          = VALUES(color_hex),
        description        = VALUES(description)
    `);
  }
  console.log(`payroll_leave_types seeded (${leaveTypes.length} types)`);
}
