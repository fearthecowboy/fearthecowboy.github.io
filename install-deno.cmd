#!/usr/bin/env -S bash # > NUL 2>&1 || echo off && goto init:
function shh() { return; } ; shh \\<<shh
## THIS IS THE START OF THE POWERSHELL SCRIPT #################################
# Copyright 2018 the Deno authors. All rights reserved. MIT license.
# TODO(everyone): Keep this script simple and easily auditable.
$ProgressPreference='SilentlyContinue'
$ErrorActionPreference = 'Stop'

if ($v) {
  $Version = "v${v}"
}
if ($args.Length -eq 1) {
  $Version = $args.Get(0)
}
if (-not $Version) {
  $version = ((iwr https://api.github.com/repos/denoland/deno/releases/latest).Content | convertfrom-json).name
}

$DenoInstall = $env:DENO_INSTALL
$BinDir = if ($DenoInstall) {
  "$DenoInstall\bin"
} else {
  "$Home\.deno\bin"
}

$DenoZip = "$BinDir\deno.zip"
$DenoExe = "$BinDir\deno.exe"
$Target = 'x86_64-pc-windows-msvc'

# GitHub requires TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$DenoUri = "https://github.com/denoland/deno/releases/download/${Version}/deno-${Target}.zip"

if (!(Test-Path $BinDir)) {
  New-Item $BinDir -ItemType Directory | Out-Null
}

# check if it's here already.
if( test-path $DenoExe )  {
  $installed = [System.Version] (((& $DenoExe --version)[0]) -split "deno\s*([\d\.]+)")[1]
  $latest = [System.Version] $version.split('v')[1]
  if( $installed -ge $latest ) {
    $skip = $true
  }
}

if(-not $skip) {
  curl.exe -Lo $DenoZip $DenoUri
  tar.exe xf $DenoZip -C $BinDir
  Remove-Item $DenoZip
}

$User = [EnvironmentVariableTarget]::User
$Path = [Environment]::GetEnvironmentVariable('Path', $User)
if (!(";$Path;".ToLower() -like "*;$BinDir;*".ToLower())) {
  [Environment]::SetEnvironmentVariable('Path', "$Path;$BinDir", $User)
}
if(!(get-command -ea 0 deno) ) {
  $Env:Path += ";$BinDir"
}

Write-Output "Deno was installed successfully to $DenoExe"
Write-Output "Run 'deno --help' to get started"

if( $ENV:DENO_POSTSCRIPT -ne $null ) {
  # dump the environment into the file 
  $content = @"
echo off
set PATH=$ENV:PATH
set DENO_INSTALL=$ENV:DENO_INSTALL
"@
  set-content -Path $ENV:DENO_POSTSCRIPT -value $content
}

return;
## THIS IS THE END OF THE POWERSHELL SCRIPT ###################################
<#
shh
## THIS IS THE START OF THE POSIX SCRIPT ######################################

# check to see if we've been dot-sourced
sourced=0
if [ -n "$ZSH_EVAL_CONTEXT" ]; then
  case $ZSH_EVAL_CONTEXT in *:file) sourced=1;; esac
elif [ -n "$BASH_VERSION" ]; then
  (return 0 2>/dev/null) && sourced=1
else # All other shells: examine $0 for known shell binary filenames
  # Detects `sh` and `dash`; add additional shell filenames as needed.
  case ${0##*/} in sh|dash) sourced=1;; esac
fi

if [ $sourced -eq 0 ]; then
  echo 'This script is expected to be dot-sourced'
  echo ''
  echo "You should instead run '. $(basename $0)'"
  exit
fi

# Copyright 2019 the Deno authors. All rights reserved. MIT license.
# TODO(everyone): Keep this script simple and easily auditable.

set -e

if ! command -v unzip >/dev/null; then
	echo "Error: unzip is required to install Deno (see: https://github.com/denoland/deno_install#unzip-is-required)." 1>&2
	exit 1
fi

if [ "$OS" = "Windows_NT" ]; then
	target="x86_64-pc-windows-msvc"
else
	case $(uname -sm) in
	"Darwin x86_64") target="x86_64-apple-darwin" ;;
	"Darwin arm64") target="aarch64-apple-darwin" ;;
	"Linux aarch64")
		echo "Error: Official Deno builds for Linux aarch64 are not available. (https://github.com/denoland/deno/issues/1846)" 1>&2
		exit 1
		;;
	*) target="x86_64-unknown-linux-gnu" ;;
	esac
fi

if [ $# -eq 0 ]; then
	deno_uri="https://github.com/denoland/deno/releases/latest/download/deno-${target}.zip"
else
	deno_uri="https://github.com/denoland/deno/releases/download/${1}/deno-${target}.zip"
fi

deno_install="${DENO_INSTALL:-$HOME/.deno}"
bin_dir="$deno_install/bin"
exe="$bin_dir/deno"

if [ ! -d "$bin_dir" ]; then
	mkdir -p "$bin_dir"
fi

curl --fail --location --progress-bar --output "$exe.zip" "$deno_uri"
unzip -d "$bin_dir" -o "$exe.zip"
chmod +x "$exe"
rm "$exe.zip"

echo "Deno was installed successfully to $exe"
if command -v deno >/dev/null; then
	echo "Run 'deno --help' to get started"
else
	case $SHELL in
	/bin/zsh) shell_profile=".zshrc" ;;
	*) shell_profile=".bashrc" ;;
	esac
	echo "Manually add the directory to your \$HOME/$shell_profile (or similar)"
	echo "  export DENO_INSTALL=\"$deno_install\""
	echo "  export PATH=\"\$DENO_INSTALL/bin:\$PATH\""
	echo "Run '$exe --help' to get started"
fi

DENO_INSTALL=$deno_install
PATH=$DENO_INSTALL/bin:$PATH

return 
## THIS IS THE END OF THE POSIX SCRIPT ########################################


## THIS IS THE START OF THE CMD SCRIPT ########################################
:init 
cls

IF "%DENO_INSTALL%"=="" SET DENO_INSTALL=%USERPROFILE%\.deno

SET /A DENO_POSTSCRIPT=%RANDOM% * 32768 + %RANDOM%
SET DENO_POSTSCRIPT=%DENO_INSTALL%\DENO_tmp_%DENO_POSTSCRIPT%.cmd

set POWERSHELL_EXE=
for %%i in (pwsh.exe powershell.exe) do (
  if EXIST "%%~$PATH:i" set POWERSHELL_EXE=%%~$PATH:i & goto :gotpwsh
)
:gotpwsh
"%POWERSHELL_EXE%" -noprofile -executionpolicy unrestricted -command "iex (get-content %~dfp0 -raw)#" 

:POSTSCRIPT
:: Call the post-invocation script if it is present, then delete it.
:: This allows the invocation to potentially modify the caller's environment (e.g. PATH).
IF NOT EXIST "%DENO_POSTSCRIPT%" GOTO :fin
CALL "%DENO_POSTSCRIPT%"
DEL "%DENO_POSTSCRIPT%"

: THIS IS THE END OF THE CMD SCRIPT ###########################################
:#>
