param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$AnsibleArgs
)

# Run ansible-playbook from WSL.
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$WSLPath = wsl --exec wslpath -a -u "$ScriptDir"
wsl --cd "$WSLPath" --exec ansible-playbook site.yml --inventory ansible-inventory-windows.yml $AnsibleArgs
