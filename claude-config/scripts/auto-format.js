#!/usr/bin/env node
/**
 * auto-format.js
 * PostToolUse hook: auto-formatea el archivo recién editado según su extensión.
 *
 * Comentario en español: corre después de cada Write/Edit. Si la herramienta
 * está disponible (black, prettier, ruff, gofmt), la usa. Si falla, no rompe
 * el flujo — solo loggea el warning.
 */

const { execSync } = require('child_process');
const fs = require('fs');

let input = '';
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
  try {
    const data = JSON.parse(input);
    const path = data.tool_input?.file_path || '';

    if (!path || !fs.existsSync(path)) {
      process.exit(0);
    }

    const tryRun = (cmd, name) => {
      try {
        execSync(cmd, { stdio: 'ignore', timeout: 10000 });
        return true;
      } catch (err) {
        // Tool no disponible o falló. No es bloqueante.
        return false;
      }
    };

    const quotedPath = JSON.stringify(path);

    // Python
    if (/\.pyi?$/.test(path)) {
      tryRun(`python -m black --quiet ${quotedPath}`, 'black') ||
      tryRun(`ruff format ${quotedPath}`, 'ruff format');
      tryRun(`ruff check --fix --quiet ${quotedPath}`, 'ruff check');
    }

    // TypeScript / JavaScript / JSON / Markdown / YAML
    else if (/\.(ts|tsx|js|jsx|mjs|cjs|json|md|mdx|yaml|yml|css|scss|html)$/.test(path)) {
      tryRun(`npx --no-install prettier --write --log-level error ${quotedPath}`, 'prettier');
    }

    // Go
    else if (/\.go$/.test(path)) {
      tryRun(`gofmt -w ${quotedPath}`, 'gofmt');
      tryRun(`goimports -w ${quotedPath}`, 'goimports');
    }

    // Rust
    else if (/\.rs$/.test(path)) {
      tryRun(`rustfmt --quiet ${quotedPath}`, 'rustfmt');
    }

    // Java / Kotlin
    else if (/\.kt$/.test(path)) {
      tryRun(`ktlint --format ${quotedPath}`, 'ktlint');
    }

    // Swift
    else if (/\.swift$/.test(path)) {
      tryRun(`swiftformat ${quotedPath}`, 'swiftformat');
    }

    process.exit(0);
  } catch (err) {
    console.error(`[auto-format hook warning]: ${err.message}`);
    process.exit(0);
  }
});
