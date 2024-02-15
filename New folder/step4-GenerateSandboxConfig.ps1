param (
    [string]$ExecutablePath,
    [string]$OutputFile,
    [string]$textInput,
    [switch]$DisableNetwork = $false,
    [switch]$ReadOnly = $false
)

$hostFolderPath = Split-Path -Path $ExecutablePath -Parent
$sandboxExecutablePath = Join-Path -Path "C:\Users\WDAGUtilityAccount\Desktop\output" -ChildPath (Split-Path -Path $ExecutablePath -Leaf)
$sandboxOutputPath = Join-Path -Path "C:\Users\WDAGUtilityAccount\Desktop\output" -ChildPath $OutputFile

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
        <Command>powershell.exe -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy Bypass -Scope Process; &amp; `"$sandboxExecutablePath`" | Out-File -FilePath `"$sandboxOutputPath`"; echo '$textInput' | Out-File -FilePath `"$sandboxOutputPath`" -Append"</Command>
    </LogonCommand>
</Configuration>
"@

$configXmlContent | Out-File -FilePath "CustomSandboxConfig.wsb"
