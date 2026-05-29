/* eslint-disable */
// Phase 2c: Extract shared SELECT projections from repo sub-files into a per-module _projections.ts.
const fs = require("fs");
const path = require("path");

const ROOT = path.resolve(__dirname, "..", "src");

const MODULES = [
  { dir: "repositories/goat" },
  { dir: "repositories/cattle" },
];

const START_MARK = "// ── SELECT projections";
// End is either `// ── Repository` (goat) or `// ─────...` separator line (cattle)
const END_REGEXES = [/^\/\/ ── Repository/, /^\/\/ ───+\s*$/];

function findEnd(lines, startIdx) {
  for (let i = startIdx + 1; i < lines.length; i++) {
    const t = lines[i].trim();
    if (END_REGEXES.some((r) => r.test(t))) return i;
  }
  return -1;
}

for (const mod of MODULES) {
  const modDir = path.join(ROOT, mod.dir);
  const files = fs.readdirSync(modDir).filter((f) => f.endsWith(".repo.ts"));
  if (files.length === 0) continue;

  // Pick the first non-barrel sub-file to extract projections from
  const sample = files.find(
    (f) => !f.match(/^(goat|cattle)\.repo\.ts$/),
  );
  if (!sample) continue;

  const samplePath = path.join(modDir, sample);
  const sampleSrc = fs.readFileSync(samplePath, "utf8");
  const sampleLines = sampleSrc.split("\n");

  const startIdx = sampleLines.findIndex((l) => l.trim().startsWith(START_MARK));
  const endIdx = findEnd(sampleLines, startIdx);
  if (startIdx === -1 || endIdx === -1) {
    console.warn(`[skip] markers not found in ${sample}`);
    continue;
  }

  // Extract header imports (lines 0 .. startIdx-1) — needed by projections
  const headerImports = sampleLines.slice(0, startIdx).join("\n").trimEnd();
  // Extract projections block (between markers)
  const projBlock = sampleLines.slice(startIdx + 1, endIdx).join("\n").trim();

  // Find all `const xxxSelect = {` to know exports
  const selectNames = [];
  for (const line of projBlock.split("\n")) {
    const m = /^const (\w+Select)\s*=/.exec(line.trim());
    if (m) selectNames.push(m[1]);
  }

  // Write _projections.ts
  const projContent = `${headerImports}\n\n// SELECT projections (return Flutter field names)\n\n${projBlock.replace(/^const /gm, "export const ")}\n`;
  const projPath = path.join(modDir, "_projections.ts");
  fs.writeFileSync(projPath, projContent, "utf8");
  console.log(`wrote ${path.relative(ROOT, projPath)} with ${selectNames.length} exports`);

  // Update each sub-file: remove the projections block and add import
  for (const f of files) {
    const subPath = path.join(modDir, f);
    const src = fs.readFileSync(subPath, "utf8");
    const lines = src.split("\n");
    const s = lines.findIndex((l) => l.trim().startsWith(START_MARK));
    const e = findEnd(lines, s);
    if (s === -1 || e === -1) {
      // No projections section (probably barrel) — skip
      continue;
    }
    // Remove lines [s .. e] inclusive of the END_MARK line? Keep END_MARK as it separates from repo body.
    // Replace lines [s .. e-1] with an import statement.
    const before = lines.slice(0, s);
    const after = lines.slice(e);
    const importLine = `import { ${selectNames.join(", ")} } from "./_projections";`;
    const newSrc = [...before, importLine, "", ...after].join("\n");
    fs.writeFileSync(subPath, newSrc, "utf8");
  }
  console.log(`  updated ${files.length} sub-files in ${mod.dir}`);
}

console.log("\nDone.");
