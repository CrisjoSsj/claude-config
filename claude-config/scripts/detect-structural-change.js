#!/usr/bin/env node
/**
 * detect-structural-change.js
 * PostToolUse hook: detecta cambios estructurales y emite warning a stderr
 * para que la IA actualice los CLAUDE.md afectados en el mismo commit.
 *
 * Comentario en español: la IA lee stderr en el tool_response. Por la regla
 * `claude-md-freshness.md`, está obligada a actuar sobre el warning.
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

let input = '';
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
  try {
    const data = JSON.parse(input);
    const filePath = data.tool_input?.file_path || '';

    if (!filePath || !fs.existsSync(filePath)) {
      process.exit(0);
    }

    // Buscar el módulo (carpeta padre) y su CLAUDE.md
    const moduleDir = path.dirname(filePath);
    const moduleClaudeMd = path.join(moduleDir, 'CLAUDE.md');

    // Detectar si es un archivo nuevo (no estaba antes del edit)
    let isNew = false;
    try {
      execSync(`git ls-files --error-unmatch ${JSON.stringify(filePath)}`, { stdio: 'ignore' });
    } catch {
      isNew = true;
    }

    // Detectar si tocamos public API (heurística: definiciones top-level)
    const content = fs.readFileSync(filePath, 'utf8');
    const hasPublicAPI = /^(export\s+(default\s+)?(function|class|const|let|interface|type|enum)|class\s+\w+|def\s+\w+|func\s+[A-Z]\w+|pub\s+(fn|struct|enum|trait))/m.test(content);

    // Detectar si tocamos rutas (heurística: decoradores de framework)
    const hasRoutes = /(@app\.(get|post|put|delete|patch)|@router\.|app\.(get|post|put|delete|patch)|router\.(get|post|put|delete|patch)|@RestController|@RequestMapping|export const (GET|POST|PUT|DELETE|PATCH))/m.test(content);

    // Detectar workarounds nuevos (TODO/FIXME con issue link)
    const hasWorkaroundLink = /(TODO|FIXME|HACK|XXX)[\s:]*.*(github\.com\/.*\/issues\/\d+|#\d+|rdar:\/\/\d+|JIRA-\d+)/i.test(content);

    // Detectar si es un módulo (>= 3 archivos de código)
    let moduleFileCount = 0;
    try {
      const files = fs.readdirSync(moduleDir);
      moduleFileCount = files.filter(f =>
        /\.(py|ts|tsx|js|jsx|go|rs|java|swift|kt|kts|rb|php|cs|cpp|c|h)$/.test(f)
      ).length;
    } catch {}

    const flags = [];
    if (isNew && moduleFileCount >= 3) flags.push('new-file-in-module');
    if (hasPublicAPI && !isNew) flags.push('public-api-changed');
    if (hasRoutes) flags.push('routes-touched');
    if (hasWorkaroundLink) flags.push('workaround-with-ticket');

    if (flags.length === 0) {
      process.exit(0);
    }

    // El módulo cumple criterios y no tiene CLAUDE.md → MISSING
    const claudeMdMissing = !fs.existsSync(moduleClaudeMd) && moduleFileCount >= 3;

    // Emitir warning a stderr (la IA lo ve en tool_response)
    console.error(`⚠️  STRUCTURAL CHANGE detected in ${filePath}`);
    console.error(`   Flags: ${flags.join(', ')}`);
    if (claudeMdMissing) {
      console.error(`   📝 ${moduleClaudeMd} is MISSING. Module has ${moduleFileCount} code files.`);
      console.error(`   Action: generate Apple-style CLAUDE.md per ~/.claude/rules/per-module-claude-md.md`);
    } else if (fs.existsSync(moduleClaudeMd)) {
      console.error(`   📝 Update ${moduleClaudeMd} in same commit (per claude-md-freshness.md).`);
    }
    if (hasRoutes) {
      console.error(`   🔀 Routes detected — also check root CLAUDE.md route index.`);
    }
    if (hasWorkaroundLink) {
      console.error(`   🎫 Workaround with ticket detected — add to "Workarounds & tickets" section.`);
    }

    // Exit 0: no bloqueamos, solo informamos.
    process.exit(0);
  } catch (err) {
    console.error(`[detect-structural-change hook error]: ${err.message}`);
    process.exit(0);
  }
});
