/* eslint-disable */
// Phase 2: Split monolith service/controller/repository files by `// ── Section ──` markers.
// Each section becomes its own file. The original file becomes a barrel re-exporting all sub-files.

const fs = require("fs");
const path = require("path");

const ROOT = path.resolve(__dirname, "..", "src");

// Section name → kebab-case file slug
const SLUGS = {
  Animals: "animals",
  "Weight Records": "weight",
  "Mating Records": "mating",
  "Pregnancy Checks": "pregnancy",
  "Kidding Events": "kidding",
  "Calving Events": "calving",
  "Breeding Records": "breeding",
  "Daily Milk": "milk",
  "Shearing Records": "shearing",
  "Health Events": "health",
  "Medication Logs": "medications",
  Vaccinations: "vaccinations",
  "Sale Records": "sales",
  "Feed Records": "feed",
  "Pasture Records": "pasture",
  "FAMACHA Records": "famacha",
  "BCS Records": "bcs",
  "Dipping Records": "dipping",
};

// Targets: [absolute path, module name, kind (service|controller|repo), exported object name, sub-object suffix]
const TARGETS = [
  // SERVICES
  {
    file: "services/goat/goat.service.ts",
    module: "goat",
    kind: "service",
    objectName: "goatService",
    subPrefix: "goat",
  },
  {
    file: "services/cattle/cattle.service.ts",
    module: "cattle",
    kind: "service",
    objectName: "cattleService",
    subPrefix: "cattle",
  },
  // CONTROLLERS
  {
    file: "controllers/goat/goat.controller.ts",
    module: "goat",
    kind: "controller",
    objectName: "goatController",
    subPrefix: "goat",
  },
  {
    file: "controllers/cattle/cattle.controller.ts",
    module: "cattle",
    kind: "controller",
    objectName: "cattleController",
    subPrefix: "cattle",
  },
  // REPOSITORIES
  {
    file: "repositories/goat/goat.repo.ts",
    module: "goat",
    kind: "repo",
    objectName: "goatRepo",
    subPrefix: "goat",
  },
  {
    file: "repositories/cattle/cattle.repo.ts",
    module: "cattle",
    kind: "repo",
    objectName: "cattleRepo",
    subPrefix: "cattle",
  },
];

function toPascal(slug) {
  return slug
    .split("-")
    .map((s) => s.charAt(0).toUpperCase() + s.slice(1))
    .join("");
}

function splitFile(target) {
  const fullPath = path.join(ROOT, target.file);
  const src = fs.readFileSync(fullPath, "utf8");
  const lines = src.split("\n");

  // 1. Find the `export const xxxService = {` line
  const startRe = new RegExp(`^export const ${target.objectName}\\s*=\\s*\\{`);
  const startIdx = lines.findIndex((l) => startRe.test(l));
  if (startIdx === -1) {
    console.warn(`[skip] cannot find object opening in ${target.file}`);
    return;
  }

  // 2. Find matching closing `};` at column 0 (top-level closer)
  let endIdx = -1;
  for (let i = startIdx + 1; i < lines.length; i++) {
    if (/^\};?\s*$/.test(lines[i])) {
      endIdx = i;
      break;
    }
  }
  if (endIdx === -1) {
    console.warn(`[skip] cannot find object closing in ${target.file}`);
    return;
  }

  // 3. Header = everything before startIdx (imports + helpers). Note: helpers may be used by sections.
  const headerLines = lines.slice(0, startIdx);
  const headerText = headerLines.join("\n").trimEnd();

  // 4. Body = lines between startIdx+1 and endIdx-1
  const bodyLines = lines.slice(startIdx + 1, endIdx);

  // 5. Parse sections by `// ── Name ──` markers
  const sectionRe = /^\s*\/\/\s*──\s*([^─]+?)\s*──/;
  const sections = []; // { name, slug, startLine, lines: [] }
  let current = null;
  for (const line of bodyLines) {
    const m = sectionRe.exec(line);
    if (m) {
      const name = m[1].trim();
      const slug = SLUGS[name];
      if (!slug) {
        console.warn(`[warn] unknown section "${name}" in ${target.file}`);
        if (current) current.lines.push(line);
        continue;
      }
      if (current) sections.push(current);
      current = { name, slug, lines: [] };
    } else if (current) {
      current.lines.push(line);
    } else {
      // Lines before any section — drop into a synthetic "_top" section? Most likely whitespace.
      if (line.trim()) {
        console.warn(`[warn] orphan line before first section in ${target.file}: "${line.trim()}"`);
      }
    }
  }
  if (current) sections.push(current);
  if (sections.length === 0) {
    console.warn(`[skip] no sections found in ${target.file}`);
    return;
  }

  const dir = path.dirname(fullPath);

  // 6. Rewrite header imports: paths were relative to the old file location (same dir).
  //    Sub-files live in the same directory, so import paths stay identical.

  // 7. Helper-function detection: any `function X(` defined in header? Keep header as-is and
  //    duplicate to each sub-file (small cost, avoids cross-file imports).
  //    Cross-references like `goatService.X` inside a method need rewriting to local sub-object name
  //    OR to the barrel. We use the barrel import inside each sub-file under a local alias.

  // Write each sub-file
  const subObjectNames = [];
  for (const sec of sections) {
    const subName = `${target.subPrefix}${toPascal(sec.slug)}${capitalize(target.kind)}`;
    subObjectNames.push({ slug: sec.slug, name: subName });

    // Body text for this section
    let bodyText = sec.lines.join("\n").trimEnd();
    // Rewrite internal references: `xxxService.` → use the local sub-object name only for methods in same section,
    // but it's hard to know which. Safer: import the full re-exported object from `./index` under same name.

    const sectionFileContent = renderSubFile({
      header: headerText,
      objectName: subName,
      bodyText,
      originalObjectName: target.objectName,
      module: target.module,
      kind: target.kind,
    });

    const outPath = path.join(dir, `${sec.slug}.${target.kind === "repo" ? "repo" : target.kind}.ts`);
    fs.writeFileSync(outPath, sectionFileContent + "\n", "utf8");
    console.log(`  wrote ${path.relative(ROOT, outPath)}`);
  }

  // 8. Replace the original monolith with a barrel that composes the sub-objects.
  const barrel = renderBarrel({
    objectName: target.objectName,
    subs: subObjectNames,
    kind: target.kind,
  });
  fs.writeFileSync(fullPath, barrel + "\n", "utf8");
  console.log(`  barrel  ${path.relative(ROOT, fullPath)}`);
}

function capitalize(s) {
  return s.charAt(0).toUpperCase() + s.slice(1);
}

function renderSubFile({ header, objectName, bodyText, originalObjectName, module, kind }) {
  // The header already contains imports the section may use. We append `import { originalObject } from "./index"` lazily.
  // To avoid circular imports between sub-files, we don't import the barrel. Instead, internal cross-references
  // `originalObjectName.fooMethod` inside the section body are LEFT AS-IS — TS compile will reveal which ones
  // need a sibling import. (Most monoliths have very few cross-refs.)
  //
  // For now, replace `originalObjectName.` with a self-reference token that will resolve once the barrel re-imports.
  // Simplest: keep the original name and add an import from `./index` for the barrel object. This creates a
  // controlled cycle but TypeScript handles it (functions captured at call time).
  const usesOriginal = new RegExp(`\\b${originalObjectName}\\.`).test(bodyText);
  const lazyImport = usesOriginal
    ? `\nimport { ${originalObjectName} } from "./index";\n`
    : "";
  return `${header}\n${lazyImport}\nexport const ${objectName} = {\n${bodyText}\n};\n`;
}

function renderBarrel({ objectName, subs, kind }) {
  const ext = kind === "repo" ? "repo" : kind;
  const imports = subs
    .map((s) => `import { ${s.name} } from "./${s.slug}.${ext}";`)
    .join("\n");
  const spreads = subs.map((s) => `  ...${s.name},`).join("\n");
  return `${imports}\n\nexport const ${objectName} = {\n${spreads}\n};\n`;
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
