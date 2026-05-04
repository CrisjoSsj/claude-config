#!/usr/bin/env node
/**
 * merge-claude-md.js
 *
 * Updates the user's ~/.claude/CLAUDE.md by replacing only content between
 * <!-- claude-config:start --> and <!-- claude-config:end --> markers.
 * Preserves any custom content the user has outside those markers.
 *
 * Behavior:
 *   - User has no CLAUDE.md           → write our content with markers
 *   - User has CLAUDE.md with markers → replace marker block, keep before/after
 *   - User has CLAUDE.md w/o markers  → prepend our marker block, keep theirs below
 *
 * Usage: node merge-claude-md.js <user-claude.md> <ours-claude.md>
 *
 * Comentario en español: nunca destruye contenido del usuario. Solo gestiona el
 * bloque entre marcadores. Lo que el usuario pone fuera de los marcadores
 * sobrevive todos los UPDATE.sh.
 */

const fs = require('fs');

const [, , userPath, oursPath] = process.argv;

if (!userPath || !oursPath) {
  console.error('Usage: merge-claude-md.js <user-claude.md> <ours-claude.md>');
  process.exit(1);
}

const START = '<!-- claude-config:start -->';
const END = '<!-- claude-config:end -->';

const ours = fs.readFileSync(oursPath, 'utf8');
const ourBlock = `${START}\n${ours.trim()}\n${END}\n`;

let user = '';
try { user = fs.readFileSync(userPath, 'utf8'); }
catch (err) {
  if (err.code !== 'ENOENT') throw err;
}

let result;
let mode;

if (!user.trim()) {
  result = ourBlock;
  mode = 'created';
} else if (user.includes(START) && user.includes(END)) {
  // Replace block between markers
  const before = user.split(START)[0];
  const after = user.split(END)[1] || '';
  result = `${before}${ourBlock.trim()}\n${after.replace(/^\n+/, '')}`;
  if (!result.endsWith('\n')) result += '\n';
  mode = 'updated';
} else {
  // User has CLAUDE.md without markers — prepend ours, keep theirs below
  result = `${ourBlock}\n# User custom content (preserved across updates)\n\n${user.trim()}\n`;
  mode = 'prepended';
}

fs.writeFileSync(userPath, result);
console.error(`✅ CLAUDE.md ${mode}: ${userPath}`);
