const mysql = require("mysql2/promise");
require("dotenv").config();

(async () => {
  const conn = await mysql.createConnection(process.env.DATABASE_URL);

  // 1. Applied migrations
  const [appliedRows] = await conn.execute(
    "SELECT name, applied_at FROM schema_migrations ORDER BY name",
  );
  console.log("\n=== APPLIED MIGRATIONS ===");
  appliedRows.forEach((r) => console.log(" APPLIED:", r.name));

  // 2. All tables in DB
  const [tableRows] = await conn.execute(
    "SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() ORDER BY TABLE_NAME",
  );
  console.log("\n=== ALL TABLES IN DB ===");
  tableRows.forEach((r) => console.log(" TABLE:", r.TABLE_NAME));

  // 3. Column details for every table
  const [colRows] = await conn.execute(`
    SELECT TABLE_NAME, COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_DEFAULT, EXTRA
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
    ORDER BY TABLE_NAME, ORDINAL_POSITION
  `);
  console.log("\n=== ALL COLUMNS BY TABLE ===");
  let lastTable = "";
  colRows.forEach((r) => {
    if (r.TABLE_NAME !== lastTable) {
      console.log("\n  [" + r.TABLE_NAME + "]");
      lastTable = r.TABLE_NAME;
    }
    const nullable = r.IS_NULLABLE === "YES" ? " NULL" : " NOT NULL";
    const def = r.COLUMN_DEFAULT !== null ? " DEFAULT " + r.COLUMN_DEFAULT : "";
    const extra = r.EXTRA ? " " + r.EXTRA : "";
    console.log(
      "    " + r.COLUMN_NAME + ": " + r.COLUMN_TYPE + nullable + def + extra,
    );
  });

  await conn.end();
})().catch((e) => {
  console.error("ERROR:", e.message);
  process.exit(1);
});
