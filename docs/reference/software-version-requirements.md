# Software Version Requirements

Never trust install instructions. Verify installed versions before proceeding.

## Dependency Validation Hierarchy

For every service:

### 1. Determine application requirements

```text
Quartz v5
  Node >=22
  npm >=10.9.2
```

### 2. Determine distro defaults

```text
Debian 12    Node 18.x    npm 9.x
Ubuntu 24.04 Node 18.x    npm 9.x
Ubuntu 22.04 Node 12.x    npm 8.x
```

### 3. Compare

If `distro version < application requirement`, use upstream vendor repository instead of distro packages.

## Common Version Mismatches

| Software | Runtime | Distro Default | Required | Fix |
|----------|---------|---------------|----------|-----|
| Quartz v5 | Node | 18.x | >=22 | NodeSource setup_22.x |
| Quartz v5 | npm | 9.x | >=10.9.2 | Bundled with Node 22 |
| SearXNG | Python | 3.11 (Debian 12) | >=3.10 | Usually OK |
| AnythingLLM | Node | 18.x | >=18 | Usually OK |

## Verification Workflow

```bash
cat /etc/os-release
node -v || true
npm -v || true
python3 --version || true
pip --version || true
```

Record output. Compare against application docs before any install step.

## Never Do This

```text
Install Application
   ↓
Hope
```

Always:

```text
Application Requirements
   ↓
Verify Runtime
   ↓
Install/Upgrade Runtime if needed
   ↓
Verify
   ↓
Install Application
```
