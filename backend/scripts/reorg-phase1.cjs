/* eslint-disable */
// Phase 1: Move per-module files into module subfolders and rewrite all imports.
// Layers: services, controllers, routes, repositories, validators, db/schema
// Each "<module>.<suffix>.ts" -> "<module>/<module>.<suffix>.ts"
// Skips: common.*, index.ts

const fs = require('fs');
const path = require('path');

const SRC = path.resolve(__dirname, '..', 'src');

const LAYERS = [
  { dir: 'services',     suffix: '.service.ts'    },
  { dir: 'controllers',  suffix: '.controller.ts' },
  { dir: 'routes',       suffix: '.routes.ts'     },
  { dir: 'repositories', suffix: '.repo.ts'       },
  { dir: 'validators',   suffix: '.validator.ts'  },
  { dir: 'db/schema',    suffix: '.schema.ts'     },
];

const EXCLUDE_MODULES = new Set(['common', 'index']);

// 1) Build move plan: Map<oldAbs, newAbs>
const moves = new Map();
for (const layer of LAYERS) {
  const layerDir = path.join(SRC, layer.dir);
  if (!fs.existsSync(layerDir)) continue;
  for (const entry of fs.readdirSync(layerDir, { withFileTypes: true })) {
    if (!entry.isFile() || !entry.name.endsWith(layer.suffix)) continue;
    const mod = entry.name.slice(0, -layer.suffix.length);
    if (EXCLUDE_MODULES.has(mod)) continue;
    const oldAbs = path.resolve(layerDir, entry.name);
    const newAbs = path.resolve(layerDir, mod, entry.name);
    moves.set(oldAbs, newAbs);
  }
}

console.log(`Planned moves: ${moves.size}`);

// 2) Walk all .ts files in src
function walk(dir, out = []) {
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, e.name);
    if (e.isDirectory()) walk(full, out);
    else if (e.name.endsWith('.ts')) out.push(path.resolve(full));
  }
  return out;
}
const allFiles = walk(SRC);

const futureLoc = (abs) => moves.get(abs) || abs;

const importRe = /(from\s+["']|require\(\s*["']|import\(\s*["'])(\.[^"']+)(["'])/g;

let rewritten = 0;
for (const file of allFiles) {
  const oldAbs = file;
  const newAbs = futureLoc(oldAbs);
  const oldDir = path.dirname(oldAbs);
  const newDir = path.dirname(newAbs);

  const original = fs.readFileSync(oldAbs, 'utf8');
  let changed = false;

  const updated = original.replace(importRe, (match, prefix, impPath, suffix) => {
    // Resolve target against OLD source dir (files haven't moved yet on disk)
    const targetBase = path.resolve(oldDir, impPath);
    const candidates = [
      targetBase + '.ts',
      targetBase,
      path.join(targetBase, 'index.ts'),
    ];
    let resolvedTarget = null;
    for (const c of candidates) {
      if (fs.existsSync(c) && fs.statSync(c).isFile()) {
        resolvedTarget = path.resolve(c);
        break;
      }
    }
    if (!resolvedTarget) return match; // unresolved (e.g. node module) → leave

    const targetFuture = futureLoc(resolvedTarget);

    let rel = path.relative(newDir, targetFuture).replace(/\\/g, '/');
    if (rel.endsWith('.ts')) rel = rel.slice(0, -3);
    if (rel.endsWith('/index')) rel = rel.slice(0, -'/index'.length);
    if (rel === 'index') rel = '.';
    if (!rel.startsWith('.')) rel = './' + rel;

    if (rel !== impPath) changed = true;
    return prefix + rel + suffix;
  });

  if (changed) {
    fs.writeFileSync(oldAbs, updated, 'utf8');
    rewritten++;
  }
}
console.log(`Files with rewritten imports: ${rewritten}`);

// 3) Perform the moves
let moved = 0;
for (const [oldAbs, newAbs] of moves) {
  fs.mkdirSync(path.dirname(newAbs), { recursive: true });
  fs.renameSync(oldAbs, newAbs);
  moved++;
}
console.log(`Files moved: ${moved}`);
console.log('Phase 1 complete.');
