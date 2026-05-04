#!/usr/bin/env node
/**
 * block-sensitive-files.js
 * PreToolUse hook: bloquea writes/edits a archivos sensibles.
 *
 * Comentario en español: corre antes de cada Write/Edit. Si el path matchea
 * un patrón de archivo sensible (.env, .pem, .key, secrets/), aborta la operación.
 */

let input = '';
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
  try {
    const data = JSON.parse(input);
    const path = data.tool_input?.file_path || '';

    const sensitivePatterns = [
      /\.env(\.|$)/i,
      /\.pem$/i,
      /\.key$/i,
      /\.p12$/i,
      /\.pfx$/i,
      /\bsecrets?\//i,
      /\bcredentials?\//i,
      /\bprivate[_-]?key/i,
      /\.aws\/credentials/i,
      /\.npmrc$/i,
      /\.netrc$/i,
    ];

    const matched = sensitivePatterns.find(p => p.test(path));
    if (matched) {
      console.error(`🚫 BLOCKED: archivo sensible detectado en ${path}`);
      console.error(`   Razón: matchea patrón ${matched.source}`);
      console.error(`   Si necesitás escribir esto, remové temporalmente la regla en ~/.claude/scripts/block-sensitive-files.js`);
      process.exit(2);
    }

    process.exit(0);
  } catch (err) {
    // Si el hook falla por un bug, NO bloquear el flujo del usuario.
    console.error(`[block-sensitive-files hook error]: ${err.message}`);
    process.exit(0);
  }
});
