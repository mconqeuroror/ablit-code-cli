# ABLIT CODE — downloads

Release binaries of **ABLIT CODE**, Ablit's coding agent for your terminal (macOS, Linux, Windows).

Install:

```bash
curl -fsSL https://ablit.app/install | bash        # macOS / Linux
```

```powershell
irm https://ablit.app/install.ps1 | iex             # Windows
```

Then `ablit-code auth login ablit` with your Ablit API key (Settings → API access on https://ablit.app).

Guide: https://ablit.app/cli · API docs: https://ablit.app/docs/api

Each release ships `ablit-code-<os>-<arch>.tar.gz` / `.zip` plus `SHA256SUMS`. This repository holds downloads only.
