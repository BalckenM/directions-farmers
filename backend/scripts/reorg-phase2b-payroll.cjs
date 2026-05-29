/* eslint-disable */
// Phase 2b: Split payroll monoliths and goat validator by single-line `// Section` markers.
const fs = require("fs");
const path = require("path");

const ROOT = path.resolve(__dirname, "..", "src");

const SLUGS = {
  Employees: "employees",
  Contracts: "contracts",
  "Pay runs": "pay-runs",
  Payslips: "payslips",
  "Payslips (raw array for Flutter compat)": "payslips",
  Leave: "leave",
  "Leave requests": "leave",
  "Deduction rules": "deductions",
  "Contracts flat list": "contracts-flat",
  "Pay groups": "pay-groups",
  "Pay structures": "pay-structures",
  "Leave balances": "leave-balances",
  "Leave balances (read-only list for farm)": "leave-balances",
  "Compliance alerts": "compliance",
  "Audit log": "audit",
  Communications: "communications",
};

const TARGETS = [
  {
    file: "services/payroll/payroll.service.ts",
    objectName: "payrollService",
    subPrefix: "payroll",
    kind: "service",
    implicitFirstSection: "Employees",
  },
  {
    file: "controllers/payroll/payroll.controller.ts",
    objectName: "payrollController",
    subPrefix: "payroll",
    kind: "controller",
    implicitFirstSection: "Employees",
  },
  {
    file: "repositories/payroll/payroll.repo.ts",
    objectName: "payrollRepo",
    subPrefix: "payroll",
    kind: "repo",
    implicitFirstSection: "Employees",
  },
];

function toPascal(slug) {
  return slug
    .split("-")
    .map((s) => s.charAt(0).toUpperCase() + s.slice(1))
    .join("");
}
function capitalize(s) {
  return s.charAt(0).toUpperCase() + s.slice(1);
}

function splitFile(target) {
  const fullPath = path.join(ROOT, target.file);
  const src = fs.readFileSync(fullPath, "utf8");
  const lines = src.split("\n");

  const startRe = new RegExp(`^export const ${target.objectName}\\s*=\\s*\\{`);
  const startIdx = lines.findIndex((l) => startRe.test(l));
  if (startIdx === -1) {
    console.warn(`[skip] cannot find object opening in ${target.file}`);
    return;
  }
  let endIdx = -1;
  for (let i = startIdx + 1; i < lines.length; i++) {
    if (/^\};?\s*$/.test(lines[i])) {
      endIdx = i;
      break;
    }
  }
  if (endIdx === -1) return;

  const headerText = lines.slice(0, startIdx).join("\n").trimEnd();
  const bodyLines = lines.slice(startIdx + 1, endIdx);

  // Single-line `//` markers: must be a comment alone on a line, content not starting with `─` or `=`
  const sectionRe = /^\s*\/\/\s+([A-Za-z][A-Za-z0-9 ()\-]*?)\s*$/;
  const sections = [];
  let current = null;

  // If implicitFirstSection set, seed it
  if (target.implicitFirstSection) {
    const slug = SLUGS[target.implicitFirstSection];
    if (slug) current = { name: target.implicitFirstSection, slug, lines: [] };
  }

  for (const line of bodyLines) {
    const m = sectionRe.exec(line);
    if (m) {
      const name = m[1].trim();
      const slug = SLUGS[name];
      if (!slug) {
        // unknown comment — keep as body content of current section
        if (current) current.lines.push(line);
        continue;
      }
      if (current) sections.push(current);
      current = { name, slug, lines: [] };
    } else if (current) {
      current.lines.push(line);
    }
  }
  if (current) sections.push(current);

  // Merge any sections with the same slug (e.g., contracts + contracts-flat aren't merged; but Payslips appears once)
  // Actually contracts-flat is intentionally separate. Keep as-is.

  if (sections.length === 0) {
    console.warn(`[skip] no sections in ${target.file}`);
    return;
  }

  const dir = path.dirname(fullPath);
  const subObjectNames = [];
  for (const sec of sections) {
    const subName = `${target.subPrefix}${toPascal(sec.slug)}${capitalize(target.kind)}`;
    subObjectNames.push({ slug: sec.slug, name: subName });

    const bodyText = sec.lines.join("\n").trimEnd();
    const usesOriginal = new RegExp(`\\b${target.objectName}\\.`).test(bodyText);
    const barrelName = path.basename(fullPath, ".ts");
    const lazyImport = usesOriginal
      ? `\nimport { ${target.objectName} } from "./${barrelName}";\n`
      : "";

    const ext = target.kind === "repo" ? "repo" : target.kind;
    const outPath = path.join(dir, `${sec.slug}.${ext}.ts`);
    const content = `${headerText}\n${lazyImport}\nexport const ${subName} = {\n${bodyText}\n};\n`;
    fs.writeFileSync(outPath, content + "\n", "utf8");
    console.log(`  wrote ${path.relative(ROOT, outPath)}`);
  }

  // Barrel
  const ext = target.kind === "repo" ? "repo" : target.kind;
  const imports = subObjectNames
    .map((s) => `import { ${s.name} } from "./${s.slug}.${ext}";`)
    .join("\n");
  const spreads = subObjectNames.map((s) => `  ...${s.name},`).join("\n");
  const barrel = `${imports}\n\nexport const ${target.objectName} = {\n${spreads}\n};\n`;
  fs.writeFileSync(fullPath, barrel, "utf8");
  console.log(`  barrel  ${path.relative(ROOT, fullPath)}`);
}

for (const t of TARGETS) {
  console.log(`\n=== Splitting ${t.file} ===`);
  try {
    splitFile(t);
  } catch (e) {
    console.error(`  ERROR: ${e.message}`);
  }
}
console.log("\nDone.");
