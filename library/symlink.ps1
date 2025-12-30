#!powershell
# -*- coding: utf-8 -*-

#Requires -Module Ansible.ModuleUtils.Legacy

$ErrorActionPreference = "Stop"

$params = Parse-Args -arguments $args -supports_check_mode $true
$check_mode = Get-AnsibleParam -obj $params -name "_ansible_check_mode" -type "bool" -default $false

$src = Get-AnsibleParam -obj $params -name "src" -type "str" -failifempty $true
$dest = Get-AnsibleParam -obj $params -name "dest" -type "str" -failifempty $true
$force = Get-AnsibleParam -obj $params -name "force" -type "bool" -failifempty $true

$result = @{
    changed = $false
    src = $src
    dest = $dest
}

if ($force) {
    Fail-Json $result "force=true is not supported"
}

# Check if symlink already exists and is correct
if (Test-Path -LiteralPath $dest) {
    $item = Get-Item -LiteralPath $dest -Force
    if ($item.LinkType -eq "SymbolicLink") {
        if ($item.Target -eq $src) {
            Exit-Json $result
        }
    } else {
        Fail-Json $result "Destination '$dest' already exists."
    }
}

# Fail if parent directory doesn't exist
$parent_dir = Split-Path -Parent $dest
if ($parent_dir -and -not (Test-Path -LiteralPath $parent_dir)) {
    Fail-Json $result "Parent directory '$parent_dir' does not exist."
}

# Create the symlink atomically using temp file + rename
if (-not $check_mode) {
    try {
        $dest_dir = Split-Path -Parent $dest
        if (-not $dest_dir) {
            $dest_dir = "."
        }
        $tmp_name = ".ansible_symlink.$([guid]::NewGuid().ToString('N')).tmp"
        $tmp_path = Join-Path $dest_dir $tmp_name

        try {
            # Create symlink at temporary path
            New-Item -ItemType SymbolicLink -Path $tmp_path -Target $src -ErrorAction Stop | Out-Null

            # Atomically rename to destination
            Move-Item -LiteralPath $tmp_path -Destination $dest -Force -ErrorAction Stop
        }
        catch {
            # Clean up temp file on failure
            if (Test-Path -LiteralPath $tmp_path) {
                Remove-Item -LiteralPath $tmp_path -Force -ErrorAction SilentlyContinue
            }
            throw
        }
    }
    catch {
        $error_msg = $_.Exception.Message
        # Provide helpful error message for Windows permission issues
        if ($error_msg -match "privilege" -or $error_msg -match "1314") {
            $error_msg += " (On Windows, enable Developer Mode or run as Administrator)"
        }
        Fail-Json $result "Failed to create symlink: $error_msg"
    }
}

$result.changed = $true
Exit-Json $result
