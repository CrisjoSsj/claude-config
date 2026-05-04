#!/usr/bin/env node
/**
 * merge-settings.js
 *
 * Deep-merges the claude-config settings.json into the user's existing one
 * without destroying their customizations.
 *
 * Strategy:
 *   - Top-level keys not in either: preserved
 *   - hooks: merge by event type, concat arrays of hook entries (deduplicated by command)
 *   - permissions.allow / permissions.deny: union (deduplicated)
 *   - enabledPlugins: object spread (user takes precedence — they may have disabled some)
 *   - Other top-level keys: user value preserved if exists, else our value
 *
 * Usage: node merge-settings.js <user-settings.json> <ours-settings.json> [--dry-run]
 *
 * Comentario en español: el merge respeta lo que el usuario ya tiene. NUNCA borra
 * sus hooks, permisos o plugins. Solo agrega los nuestros que faltan.
 */

const fs = require('fs');

const [, , userPath, oursPath, ...flags] = process.argv;
const dryRun = flags.includes('--dry-run');

if (!userPath || !oursPath) {
  console.error('Usage: merge-settings.js <user-settings.json> <ours-settings.json> [--dry-run]');
  process.exit(1);
}

const readJson = (p) => {
  try { return JSON.parse(fs.readFileSync(p, 'utf8')); }
  catch (err) {
    if (err.code === 'ENOENT') return null;
    throw err;
  }
};

const user = readJson(userPath) || {};
const ours = readJson(oursPath) || {};

// Deep-merge logic
const dedupBy = (arr, key) => {
  const seen = new Set();
  return arr.filter(item => {
    const k = typeof item === 'string' ? item : JSON.stringify(item[key] ?? item);
    if (seen.has(k)) return false;
    seen.add(k);
    return true;
  });
};

const mergeHookArrays = (userHooks, ourHooks) => {
  // Each hook entry has { matcher, hooks: [{type, command}] }
  // Merge by matcher, concat hooks arrays
  const byMatcher = new Map();
  for (const h of [...(userHooks || []), ...(ourHooks || [])]) {
    const key = h.matcher || '*';
    const existing = byMatcher.get(key) || { matcher: key, hooks: [] };
    existing.hooks = dedupBy([...existing.hooks, ...(h.hooks || [])], 'command');
    byMatcher.set(key, existing);
  }
  return [...byMatcher.values()];
};

const mergeHooks = (userH, ourH) => {
  const allEvents = new Set([...Object.keys(userH || {}), ...Object.keys(ourH || {})]);
  const merged = {};
  for (const ev of allEvents) {
    merged[ev] = mergeHookArrays(userH?.[ev], ourH?.[ev]);
  }
  return merged;
};

const mergePermissions = (userP, ourP) => {
  const allow = dedupBy([...(userP?.allow || []), ...(ourP?.allow || [])]);
  const deny = dedupBy([...(userP?.deny || []), ...(ourP?.deny || [])]);
  // defaultMode: prefer user's if set
  const defaultMode = userP?.defaultMode ?? ourP?.defaultMode;
  return { ...ourP, ...userP, allow, deny, ...(defaultMode && { defaultMode }) };
};

const mergeEnabledPlugins = (userE, ourE) => {
  // Plugins ours adds, user can disable. So: union, but user values win for shared keys.
  return { ...(ourE || {}), ...(userE || {}) };
};

const merged = {
  ...ours,
  ...user, // user top-level keys win for unknown keys
  hooks: mergeHooks(user.hooks, ours.hooks),
  permissions: mergePermissions(user.permissions, ours.permissions),
  enabledPlugins: mergeEnabledPlugins(user.enabledPlugins, ours.enabledPlugins),
  // extraKnownMarketplaces: deep merge
  extraKnownMarketplaces: { ...(ours.extraKnownMarketplaces || {}), ...(user.extraKnownMarketplaces || {}) },
};

const output = JSON.stringify(merged, null, 2) + '\n';

if (dryRun) {
  process.stdout.write(output);
} else {
  fs.writeFileSync(userPath, output);
  console.error(`✅ Merged settings.json: ${userPath}`);
}
