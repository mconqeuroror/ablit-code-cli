# ABLIT CODE — downloads

Release binaries of **ABLIT CODE**, Ablit's coding agent for your terminal (macOS, Linux, Windows).

Install on macOS or Linux:

```bash
curl -fsSL https://ablit.app/install | bash
```

Install on Windows (PowerShell):

```powershell
irm https://ablit.app/install.ps1 | iex
```

Then connect your Ablit API key (Settings → API access on https://ablit.app):

```bash
ablit auth login ablit
```

Guide: https://ablit.app/cli · API docs: https://ablit.app/docs/api

The same installers are mirrored here as `install` and `install.ps1`. Each release ships `ablit-code-<os>-<arch>.tar.gz` / `.zip` plus `SHA256SUMS`. This repository holds downloads only.
