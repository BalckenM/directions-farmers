const mysql = require("mysql2/promise");
require("dotenv").config();

(async () => {
  const conn = await mysql.createConnection(process.env.DATABASE_URL);
  const [tables] = await conn.execute("SHOW TABLES LIKE 'goat%'");
  for (const t of tables) {
    const tname = Object.values(t)[0];
    const [cols] = await conn.execute("DESCRIBE `" + tname + "`");
    console.log(tname + ": " + cols.map((r) => r.Field).join(", "));
  }
  await conn.end();
})().catch((e) => {
  console.error(e.message);
  process.exit(1);
});
