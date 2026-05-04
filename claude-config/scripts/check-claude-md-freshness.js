#!/usr/bin/env node
/**
 * check-claude-md-freshness.js
 * Stop hook: valida freshness de todos los CLAUDE.md en el repo antes de cerrar sesión.
 *
 * Comentario en español: corre cuando la IA dice "listo" o el usuario cierra sesión.
 * Reporta drift / referencias rotas / módulos sin CLAUDE.md. No bloquea — solo informa.
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

let input = '';
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
  try {
    let cwd;
    try {
      cwd = execSync('git rev-parse --show-toplevel', { encoding: 'utf8' }).trim();
    } catch {
      cwd = process.cwd();
    }

    if (!fs.existsSync(cwd)) {
      process.exit(0);
    }

    const findClaudeMds = (dir, depth = 0, max = 5) => {
      if (depth > max) return [];
      let results = [];
      let entries;
      try {
        entries = fs.readdirSync(dir, { withFileTypes: true });
      } catch {
        return [];
      }
      for (const entry of entries) {
        const full = path.join(dir, entry.name);
        if (entry.isDirectory()) {
          if (/^(node_modules|dist|build|\.git|\.venv|venv|target|__pycache__|\.next|\.nuxt)$/.test(entry.name)) continue;
          results = results.concat(findClaudeMds(full, depth + 1, max));
        } else if (entry.name === 'CLAUDE.md') {
          results.push(full);
        }
      }
      return results;
    };

    const claudeMds = findClaudeMds(cwd);
    if (claudeMds.length === 0) {
      process.exit(0);
    }

    const issues = [];

    for (const mdPath of claudeMds) {
      const content = fs.readFileSync(mdPath, 'utf8');
      const moduleDir = path.dirname(mdPath);

      // Check 1: @import paths exist
      const importMatches = content.matchAll(/@([\.~\/][\w\.\-\/]+\.md)/g);
      for (const m of importMatches) {
        const importPath = m[1].replace(/^~/, process.env.HOME || process.env.USERPROFILE || '~');
        const resolved = path.isAbsolute(importPath)
          ? importPath
          : path.resolve(moduleDir, importPath);
        if (!fs.existsSync(resolved)) {
          issues.push(`❌ ${mdPath}: broken @import → ${m[1]}`);
        }
      }

      // Check 2: relative path mentions still exist
      const pathMentions = content.matchAll(/`([\w\.\-\/]+\.(py|ts|tsx|js|jsx|go|rs|java|swift|kt))`/g);
      for (const m of pathMentions) {
        const mentionedPath = path.resolve(moduleDir, m[1]);
        if (!fs.existsSync(mentionedPath)) {
          issues.push(`⚠️  ${mdPath}: mentions ${m[1]} but file doesn't exist`);
        }
      }

      // Check 3: CLAUDE.md older than module's last commit (heurística)
      try {
        const mdMtime = fs.statSync(mdPath).mtime;
        const moduleFiles = fs.readdirSync(moduleDir).filter(f =>
          /\.(py|ts|tsx|js|jsx|go|rs|java|swift|kt)$/.test(f)
        );
        for (const f of moduleFiles) {
          const fileMtime = fs.statSync(path.join(moduleDir, f)).mtime;
          const ageDiffMs = fileMtime - mdMtime;
          const ageDiffDays = ageDiffMs / (1000 * 60 * 60 * 24);
          if (ageDiffDays > 90) {
            issues.push(`📅 ${mdPath}: stale (>90 days behind ${f})`);
            break;
          }
        }
      } catch {}
    }

    // Check 4: módulos sin CLAUDE.md que cumplen criterios
    const findCandidateModules = (dir, depth = 0, max = 4) => {
      if (depth > max) return [];
      let results = [];
      let entries;
      try {
        entries = fs.readdirSync(dir, { withFileTypes: true });
      } catch {
        return [];
      }
      const codeFiles = entries.filter(e => e.isFile() && /\.(py|ts|tsx|js|jsx|go|rs|java|swift|kt)$/.test(e.name));
      const hasClaudeMd = entries.some(e => e.name === 'CLAUDE.md');
      if (depth > 0 && codeFiles.length >= 3 && !hasClaudeMd) {
        results.push({ dir, count: codeFiles.length });
      }
      for (const entry of entries) {
        if (entry.isDirectory() && !/^(node_modules|dist|build|\.git|\.venv|venv|target|__pycache__|\.next|tests|test|__tests__)$/.test(entry.name)) {
          results = results.concat(findCandidateModules(path.join(dir, entry.name), depth + 1, max));
        }
      }
      return results;
    };

    const candidates = findCandidateModules(cwd);
    for (const c of candidates) {
      issues.push(`📝 ${c.dir} has ${c.count} code files but no CLAUDE.md`);
    }

    if (issues.length === 0) {
      console.error(`✅ CLAUDE.md freshness check: all ${claudeMds.length} files OK.`);
    } else {
      console.error(`\n📋 CLAUDE.md freshness report (${issues.length} issues):`);
      issues.slice(0, 20).forEach(i => console.error(`   ${i}`));
      if (issues.length > 20) console.error(`   ... and ${issues.length - 20} more.`);
      console.error(`\n   Action: address before next session, or invoke /audit-freshness.`);
    }

    process.exit(0);
  } catch (err) {
    console.error(`[check-claude-md-freshness hook error]: ${err.message}`);
    process.exit(0);
  }
});
