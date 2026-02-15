# PM2 System Configuration (Manual Setup)

Set up **PM2** for Node.js projects on Ubuntu with:
* a shared `ecosystem.config.cjs`
* auto-start on reboot with `systemd`
* helper commands for apply/sync and port visibility

Tested on **Ubuntu 22.04 / 24.04**.

---

## Prerequisites

* `node` and `npm` must already be installed.
* If needed, use the Node installer guide first: [../Node/README.md](../Node/README.md)

---

## Step 1) Install PM2 globally

```bash
npm i -g pm2
pm2 -v
```

---

## Step 2) Create PM2 directory structure

```bash
mkdir -p ~/pm2/{logs,scripts}
mkdir -p ~/bin
```

---

## Step 3) Create the ecosystem file

```bash
nano ~/pm2/ecosystem.config.cjs
```

Paste this template:

```javascript
// ~/pm2/ecosystem.config.cjs
const path = require("path");
const fs = require("fs");

const HOST = "0.0.0.0";

// Example workspace root (replace with your actual path)
const BASE = "/home/path/to/your/workspace";

const LOG_DIR = path.join(process.env.HOME, "pm2", "logs");
if (!fs.existsSync(LOG_DIR)) fs.mkdirSync(LOG_DIR, { recursive: true });

/**
 * App runner presets:
 *  - "vite"   -> Vite dev server with explicit host/port and strict port binding
 *  - "next"   -> Next.js dev server with explicit host/port flags
 *  - "node"   -> Generic Node/Express-style app (expects HOST/PORT from environment)
 *  - "custom" -> Fully custom command string provided via `cmd`
 */
function mkApp({ name, cwd, port, kind = "custom", cmd }) {
  const out = path.join(LOG_DIR, `${name}.out.log`);
  const err = path.join(LOG_DIR, `${name}.err.log`);

  let finalCmd = cmd;

  if (!finalCmd) {
    if (kind === "vite") {
      // Prevent Vite from silently switching to another free port
      finalCmd = `npm run dev -- --host ${HOST} --port ${port} --strictPort`;
    } else if (kind === "next") {
      finalCmd = `npm run dev -- -H ${HOST} -p ${port}`;
    } else if (kind === "node") {
      // Use HOST/PORT from environment variables
      finalCmd = `npm run dev`;
    } else {
      throw new Error(`cmd is required for kind="${kind}" on app "${name}"`);
    }
  }

  return {
    // Stable app name (keep port in env/args, not in the app name)
    name,
    cwd,

    // Run via interactive shell so npm scripts behave consistently
    script: "bash",
    exec_mode: "fork",
    args: `-lc '${finalCmd}'`,

    env: {
      NODE_ENV: "development",
      HOST,
      PORT: String(port),

      // Enable polling if file watching is unreliable (VM/WSL/network FS)
      CHOKIDAR_USEPOLLING: "1",
    },

    // Restart policy
    autorestart: true,
    restart_delay: 2000,
    max_restarts: 20,

    // Let framework tooling handle HMR/watch
    watch: false,

    // Logging
    time: true,
    log_date_format: "YYYY-MM-DD HH:mm:ss",
    out_file: out,
    error_file: err,
    merge_logs: true,
  };
}

// Example apps registry (replace with your real projects)
module.exports = {
  apps: [
    // Vite example
    mkApp({ name: "ui-dashboard", cwd: `${BASE}/apps/ui-dashboard`, port: 5000, kind: "vite" }),

    // Next.js example
    mkApp({ name: "web-portal", cwd: `${BASE}/apps/web-portal`, port: 5001, kind: "next" }),

    // Express/Node example (reads HOST/PORT from env)
    mkApp({ name: "api-gateway", cwd: `${BASE}/services/api-gateway`, port: 5002, kind: "node" }),

    // Custom command example
    mkApp({
      name: "worker-jobs",
      cwd: `${BASE}/services/worker-jobs`,
      port: 5003,
      kind: "custom",
      cmd: "node ./src/worker.js",
    }),
  ],
};
```

---

## Step 4) Clean old PM2 state (optional reset)

Use this only if you want a clean restart:

```bash
pm2 ls
pm2 delete all
pm2 kill
```

---

## Step 5) Start apps from ecosystem

```bash
pm2 start ~/pm2/ecosystem.config.cjs
pm2 ls
```

---

## Step 6) Enable auto-start after reboot (systemd)

```bash
pm2 startup systemd -u $USER --hp $HOME
pm2 save
```

---

## Step 7) Create `pm2-apply` helper (sync from ecosystem)

```bash
nano ~/bin/pm2-apply
```

Paste:

```bash
#!/usr/bin/env bash
set -euo pipefail

ECOS="$HOME/pm2/ecosystem.config.cjs"

# Fully sync running apps with ecosystem config (no drift)
pm2 startOrRestart "$ECOS" --update-env

# Persist current state for reboot restore
pm2 save

echo "✅ PM2 synced with ecosystem + saved."
```

Then:

```bash
chmod +x ~/bin/pm2-apply
```

Add to PATH for **zsh** only:

```bash
grep -q 'export PATH="$HOME/bin:$PATH"' ~/.zshrc || echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

Usage:

```bash
pm2-apply
```

---

## Step 8) Create `pm2ports` helper (show app ports)

```bash
nano ~/bin/pm2ports
```

Paste:

```bash
#!/usr/bin/env bash
pm2 jlist | node -e '
const xs = JSON.parse(require("fs").readFileSync(0, "utf8"));
console.log("NAME\tPORT\tSTATUS\tPID");
for (const x of xs) {
  const env = (x.pm2_env && x.pm2_env.env) || {};
  const port = env.PORT ?? "-";
  const pid = x.pid ?? "-";
  console.log(`${x.name}\t${port}\t${x.pm2_env.status}\t${pid}`);
}
'
```

Then:

```bash
chmod +x ~/bin/pm2ports
```

Usage:

```bash
pm2ports
```

---

## Daily Operations

```bash
pm2 ls
pm2 logs
pm2 restart <app-name>
pm2 stop <app-name>
pm2 delete <app-name>
pm2 save
```

---

## Notes

* Replace `BASE` in `~/pm2/ecosystem.config.cjs` with your real workspace path.
* Keep one source of truth: update the ecosystem file, then run `pm2-apply`.
* If app commands change env vars, use `--update-env` (already included in `pm2-apply`).
