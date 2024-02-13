param (
    [string]$ExecutablePath,
    [string]$OutputFile = "Output.txt",
    [string]$textInput,
    [switch]$DisableNetwork = $false
)

$hostFolderPath = Split-Path -Path $ExecutablePath -Parent
$sandboxExecutablePath = Join-Path -Path "C:\Users\WDAGUtilityAccount\Desktop" -ChildPath (Split-Path -Path $ExecutablePath -Leaf)
$sandboxOutputPath = Join-Path -Path "C:\Users\WDAGUtilityAccount\Desktop" -ChildPath $OutputFile

$networkingConfig = if ($DisableNetwork) { "<Networking>Disable</Networking>" } else { "<Networking>Default</Networking>" }

$configXmlContent = @"
<Configuration>
    $networkingConfig
    <MappedFolders>
        <MappedFolder>
            <HostFolder>$hostFolderPath</HostFolder>
            <SandboxFolder>C:\Users\WDAGUtilityAccount\Desktop</SandboxFolder>
            <ReadOnly>false</ReadOnly>
        </MappedFolder>
    </MappedFolders>
    <LogonCommand>
        <Command>powershell.exe -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy Bypass -Scope Process; &amp; `"$sandboxExecutablePath`" | Out-File -FilePath `"$sandboxOutputPath`"; echo '$textInput' | Out-File -FilePath `"$sandboxOutputPath`" -Append"</Command>

    </LogonCommand>
</Configuration>
"@

$configXmlContent | Out-File -FilePath "CustomSandboxConfig.wsb"
