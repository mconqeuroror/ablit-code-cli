# ABLIT CODE installer for Windows: downloads the `ablit-code` CLI, verifies its checksum, installs it to
# %USERPROFILE%\.ablit-code\bin and adds that directory to the user PATH.
#
#   irm https://ablit.app/install.ps1 | iex
#   $env:ABLIT_CODE_VERSION = "2.3.0"; irm https://ablit.app/install.ps1 | iex
#
$ErrorActionPreference = "Stop"
$App = "ablit-code"
$DownloadBase = if ($env:ABLIT_CODE_DOWNLOAD_BASE) { $env:ABLIT_CODE_DOWNLOAD_BASE } else { "https://github.com/mconqeuroror/ablit-code-cli/releases" }
$Version = $env:ABLIT_CODE_VERSION

$arch = $env:PROCESSOR_ARCHITECTURE
if ($env:PROCESSOR_ARCHITEW6432) { $arch = $env:PROCESSOR_ARCHITEW6432 }
if ($arch -notin @("AMD64", "ARM64")) { Write-Error "Unsupported architecture: $arch. ABLIT CODE for Windows needs a 64-bit x64 or ARM64 system."; exit 1 }
# The x64 build runs on Windows on ARM through emulation.
$target = "windows-x64"
try {
  $k32 = Add-Type -MemberDefinition '[DllImport("kernel32.dll")] public static extern bool IsProcessorFeaturePresent(int ProcessorFeature);' -Name Kernel32 -Namespace Win32 -PassThru
  if (-not $k32::IsProcessorFeaturePresent(40)) { $target = "windows-x64-baseline" }
} catch { }

$asset = "$App-$target.zip"
if ($Version) { $releaseUrl = "$DownloadBase/download/v$($Version.TrimStart('v'))" } else { $releaseUrl = "$DownloadBase/latest/download" }
$installDir = Join-Path $env:USERPROFILE ".ablit-code\bin"
New-Item -ItemType Directory -Force -Path $installDir | Out-Null
$tmp = Join-Path ([System.IO.Path]::GetTempPath()) "ablit-code-install-$PID"
New-Item -ItemType Directory -Force -Path $tmp | Out-Null

try {
  Write-Host "Installing $App ($(if ($Version) { $Version } else { 'latest' }), $target)..."
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  Invoke-WebRequest -UseBasicParsing -Uri "$releaseUrl/$asset" -OutFile (Join-Path $tmp $asset)
  try {
    Invoke-WebRequest -UseBasicParsing -Uri "$releaseUrl/SHA256SUMS" -OutFile (Join-Path $tmp "SHA256SUMS")
    $line = Get-Content (Join-Path $tmp "SHA256SUMS") | Where-Object { $_ -match "  $([regex]::Escape($asset))$" } | Select-Object -First 1
    if ($line) {
      $expected = ($line -split "\s+")[0].ToLower()
      $actual = (Get-FileHash -Algorithm SHA256 (Join-Path $tmp $asset)).Hash.ToLower()
      if ($expected -ne $actual) { Write-Error "Checksum mismatch for $asset (expected $expected, got $actual)"; exit 1 }
      Write-Host "Checksum verified."
    }
  } catch { Write-Host "No checksum published; skipping verification." }

  Expand-Archive -Force -Path (Join-Path $tmp $asset) -DestinationPath $tmp
  $exe = Join-Path $installDir "$App.exe"
  Move-Item -Force (Join-Path $tmp "$App.exe") $exe
  Unblock-File $exe -ErrorAction SilentlyContinue
} finally {
  Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
}

$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if (($userPath -split ";") -notcontains $installDir) {
  [Environment]::SetEnvironmentVariable("Path", "$installDir;$userPath", "User")
  $env:Path = "$installDir;$env:Path"
  Write-Host "Added $installDir to your user PATH."
}

Write-Host ""
Write-Host "ABLIT CODE is installed. To start (open a new terminal first if the command is not found):"
Write-Host ""
Write-Host "  ablit-code auth login ablit     # paste your Ablit API key (Settings -> API access)"
Write-Host "  cd <project>; ablit-code        # start coding"
Write-Host ""
Write-Host "Guide: https://ablit.app/cli"
