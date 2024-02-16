# Define parameters
param (
    [string]$ExecutablePath,
    [string]$OutputFile,
    [switch]$DisableNetwork = $false,
    [switch]$ReadOnly = $false,
    [string]$LogonCommand 
)

# Set paths
$hostFolderPath = Split-Path -Path $ExecutablePath -Parent

# Set networking and read-only configurations
$networkingConfig = if ($DisableNetwork) { "<Networking>Disable</Networking>" } else { "<Networking>Default</Networking>" }
$readOnlyValue = if ($ReadOnly) { "true" } else { "false" }


$configXmlContent = @"
<Configuration>
    $networkingConfig
    <MappedFolders>
        <MappedFolder>
            <HostFolder>$hostFolderPath</HostFolder>
            <SandboxFolder>C:\Users\WDAGUtilityAccount\Desktop\output</SandboxFolder>
            <ReadOnly>$readOnlyValue</ReadOnly>
        </MappedFolder>
    </MappedFolders>
    <LogonCommand>
        <Command>powershell.exe -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy Bypass -Scope Process; &amp; `"$LogonCommand`"</Command> 
    </LogonCommand>
</Configuration>
"@

$configXmlContent | Out-File -FilePath "CustomSandboxConfig.wsb"

