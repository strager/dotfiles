# deploy.ps1 - Run ansible-playbook from PowerShell via WSL
#
# Usage:
#   .\deploy.ps1                    # Run the playbook
#   .\deploy.ps1 --tags vim         # Run specific tags
#   .\deploy.ps1 --check            # Dry run
#   .\deploy.ps1 --tags vim --check # Combine options

param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$AnsibleArgs
)

# Get the directory where this script is located
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Convert Windows path to WSL path
$WslPath = wsl wslpath -u "$ScriptDir"

# Run ansible-playbook from WSL
$cmd = "cd '$WslPath' && ansible-playbook site.yml $($AnsibleArgs -join ' ')"
wsl bash -c $cmd
