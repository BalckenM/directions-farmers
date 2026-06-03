const mysql = require("mysql2/promise");
const OID = "1244ea30-ac19-4fc9-b4a1-7a87b678060d";
async function main() {
  const conn = await mysql.createConnection(
    "mysql://punfrohs_d4-farming:Ze3g5cJC3xbA4T8AuGC4@148.251.246.72:3306/punfrohs_d4-farming",
  );
  const q = async (sql, label) => {
    try {
      const [r] = await conn.execute(sql, [OID]);
      console.log(
        label + ":",
        JSON.stringify(r.map((x) => Object.values(x)[0])),
      );
    } catch (e) {
      console.log(label + ": ERROR " + e.message);
    }
  };
  await q(
    "SELECT DISTINCT status FROM payroll_employees WHERE farm_owner_id=?",
    "emp.status",
  );
  await q(
    "SELECT DISTINCT engagement_type FROM payroll_employees WHERE farm_owner_id=?",
    "emp.engagementType",
  );
  await q(
    "SELECT DISTINCT disbursement_method FROM payroll_employees WHERE farm_owner_id=?",
    "emp.disbursementMethod",
  );
  await q(
    "SELECT DISTINCT type FROM payroll_contracts WHERE farm_owner_id=?",
    "contract.type",
  );
  await q(
    "SELECT DISTINCT status FROM payroll_contracts WHERE farm_owner_id=?",
    "contract.status",
  );
  await q(
    "SELECT DISTINCT type FROM payroll_deduction_rules WHERE farm_owner_id=?",
    "deduction.type",
  );
  await q(
    "SELECT DISTINCT calculation_method FROM payroll_deduction_rules WHERE farm_owner_id=?",
    "deduction.calcMethod",
  );
  await q(
    "SELECT DISTINCT status FROM payroll_pay_runs WHERE farm_owner_id=?",
    "payrun.status",
  );
  await q(
    "SELECT DISTINCT frequency FROM payroll_pay_groups WHERE farm_owner_id=?",
    "paygroup.frequency",
  );
  await q(
    "SELECT DISTINCT status FROM payroll_leave_requests WHERE farm_owner_id=?",
    "leave.status",
  );
  await q(
    "SELECT DISTINCT type FROM payroll_incidents WHERE farm_owner_id=?",
    "incident.type",
  );
  await q(
    "SELECT DISTINCT status FROM payroll_incidents WHERE farm_owner_id=?",
    "incident.status",
  );
  await q(
    "SELECT DISTINCT status FROM payroll_transactions WHERE farm_owner_id=?",
    "transaction.status",
  );
  await q(
    "SELECT DISTINCT channel FROM payroll_communications WHERE farm_owner_id=?",
    "comms.channel",
  );
  await q(
    "SELECT DISTINCT severity FROM payroll_compliance_alerts WHERE farm_owner_id=?",
    "compliance.severity",
  );
  await conn.end();
}
main().catch((e) => console.error(e.message));
