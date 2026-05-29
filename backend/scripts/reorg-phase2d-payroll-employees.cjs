/* eslint-disable */
// Phase 2d: Split repositories/payroll/employees.repo.ts (mixed bag) into per-resource sub-files.
const fs = require("fs");
const path = require("path");

const SRC = path.resolve(__dirname, "..", "src", "repositories", "payroll", "employees.repo.ts");
const DIR = path.dirname(SRC);

const src = fs.readFileSync(SRC, "utf8");
const lines = src.split("\n");

// Header = everything before `export const payrollEmployeesRepo = {`
const objStart = lines.findIndex((l) => l.trim().startsWith("export const payrollEmployeesRepo"));
const header = lines.slice(0, objStart).join("\n");

// Find closing `};`
let objEnd = -1;
for (let i = lines.length - 1; i > objStart; i--) {
  if (lines[i].trim() === "};") { objEnd = i; break; }
}

// Method start lines (indent === 2 spaces, name followed by `:` or `(`)
const methodRe = /^ {2}([a-z]\w+)\s*[:(]/;
const methods = [];
for (let i = objStart + 1; i < objEnd; i++) {
  const m = methodRe.exec(lines[i]);
  if (m) methods.push({ name: m[1], start: i });
}
methods.forEach((m, idx) => {
  m.end = idx + 1 < methods.length ? methods[idx + 1].start - 1 : objEnd - 1;
});

// Group by prefix
function groupFor(name) {
  const n = name.toLowerCase();
  if (n.includes("employee")) return "employees";
  if (n.includes("allcontract") || n.includes("voidcontract")) return "contracts-flat";
  if (n.includes("contract")) return "contracts";
  if (n.includes("payrun")) return "pay-runs";
  if (n.includes("payslip")) return "payslips";
  if (n.includes("leaverequest")) return "leave-requests";
  if (n.includes("leavetype") || n.includes("leavebalance")) return "leave";
  if (n.includes("piecework")) return "piecework";
  if (n.includes("deduction")) return "deductions";
  if (n.includes("transaction")) return "transactions";
  return "misc";
}

const groups = {};
for (const m of methods) {
  const g = groupFor(m.name);
  (groups[g] ||= []).push(m);
}

// Strip leading comment lines for a method block (// Flat contract list etc.) and include trailing blank lines? Keep contiguous block as-is.
function methodBlock(m) {
  // Include comment lines immediately above (within same indent)
  let s = m.start;
  while (s - 1 > 0 && /^ {2}\/\//.test(lines[s - 1])) s--;
  return lines.slice(s, m.end + 1).join("\n");
}

// Emit one file per group
const groupExports = {}; // group -> object name
for (const [g, ms] of Object.entries(groups)) {
  const objName = `payroll${g.replace(/(^|-)([a-z])/g, (_, __, c) => c.toUpperCase())}Repo`;
  groupExports[g] = objName;
  const body = ms.map(methodBlock).join("\n\n");
  const content = `${header}\n\nexport const ${objName} = {\n${body}\n};\n`;
  const file = path.join(DIR, `${g}.repo.ts`);
  fs.writeFileSync(file, content, "utf8");
  console.log(`wrote ${path.basename(file)} (${ms.length} methods)`);
}

// Overwrite employees.repo.ts to keep only employees group (already wrote it above as employees.repo.ts — overwrites itself).
// We need to remove employees.repo.ts and replace barrel to compose from sub-files.
// But employees.repo.ts WAS just overwritten with only employees-group methods. That's correct.

// Update the barrel payroll.repo.ts to spread all new sub-objects
const barrelPath = path.join(DIR, "payroll.repo.ts");
const barrelSrc = fs.readFileSync(barrelPath, "utf8");
// Add imports + spread for the new sub-objects (skip employees since already there)
const newImports = Object.entries(groupExports)
  .filter(([g]) => g !== "employees")
  .map(([g, name]) => `import { ${name} } from "./${g}.repo";`)
  .join("\n");
const newSpreads = Object.entries(groupExports)
  .filter(([g]) => g !== "employees")
  .map(([, name]) => `  ...${name},`)
  .join("\n");

console.log("\n=== Add to payroll.repo.ts manually if not present ===");
console.log(newImports);
console.log("--- inside payrollRepo object: ---");
console.log(newSpreads);
