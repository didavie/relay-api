// Checks that every JSON file parses and that the OpenAPI file and the Postman
// collection describe the same API paths.
import { readFileSync, readdirSync, statSync } from 'node:fs';
import { join } from 'node:path';

const root = new URL('..', import.meta.url).pathname;
let failed = 0;

function walk(dir) {
  return readdirSync(dir).flatMap((name) => {
    if (name === 'node_modules' || name.startsWith('.')) return [];
    const full = join(dir, name);
    return statSync(full).isDirectory() ? walk(full) : [full];
  });
}

for (const file of walk(root).filter((f) => f.endsWith('.json'))) {
  try {
    JSON.parse(readFileSync(file, 'utf8'));
  } catch (err) {
    console.error(`invalid JSON: ${file}: ${err.message}`);
    failed++;
  }
}

const spec = JSON.parse(readFileSync(join(root, 'openapi/openapi.json'), 'utf8'));
const collection = JSON.parse(readFileSync(join(root, 'collections/postman/relay-api.postman_collection.json'), 'utf8'));
const specPaths = new Set(Object.keys(spec.paths));
const used = new Set();
for (const group of collection.item) {
  for (const item of group.item) {
    const path = '/' + item.request.url.path.join('/').replace(/\{\{trackingCode\}\}/g, '{tracking_code}');
    if (path.startsWith('/sandbox/')) continue;
    if (!specPaths.has(path)) {
      console.error(`collection request "${item.name}" uses ${path}, which is not in openapi.json`);
      failed++;
    }
    used.add(path);
  }
}
for (const path of specPaths) {
  if (!used.has(path)) {
    console.error(`openapi.json path ${path} has no request in the Postman collection`);
    failed++;
  }
}

if (failed) process.exit(1);
console.log(`JSON files valid; ${used.size} collection paths match openapi.json`);
