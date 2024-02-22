Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Function to generate the sandbox configuration
function Generate-SandboxConfig {
    param (
        [string]$ExecutablePath,
        [string]$OutputFile,
        [switch]$DisableNetwork,
        [switch]$ReadOnly,
        [string]$LogonCommand
    )

    $hostFolderPath = Split-Path -Path $ExecutablePath -Parent
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
        <Command>powershell.exe -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy Bypass -Scope Process; &amp; $LogonCommand"</Command> 
    </LogonCommand>
</Configuration>
"@

    $configXmlContent | Out-File -FilePath "CustomSandboxConfig.wsb"
}

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Sandbox Execution Tool'
$form.Size = New-Object System.Drawing.Size(500,400)
$form.StartPosition = 'CenterScreen'

# Path input
$pathLabel = New-Object System.Windows.Forms.Label
$pathLabel.Location = New-Object System.Drawing.Point(10,20)
$pathLabel.Size = New-Object System.Drawing.Size(480,20)
$pathLabel.Text = 'Executable Path*:'
$form.Controls.Add($pathLabel)

$pathTextBox = New-Object System.Windows.Forms.TextBox
$pathTextBox.Location = New-Object System.Drawing.Point(10,40)
$pathTextBox.Size = New-Object System.Drawing.Size(360,20)
$form.Controls.Add($pathTextBox)

# File browsing for Executable Path
$browseButton = New-Object System.Windows.Forms.Button
$browseButton.Location = New-Object System.Drawing.Point(370,40)
$browseButton.Size = New-Object System.Drawing.Size(100,20)
$browseButton.Text = "Browse..."
$browseButton.Add_Click({
    $fileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $fileDialog.Filter = "Executable Files (*.exe)|*.exe"
    if ($fileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $pathTextBox.Text = $fileDialog.FileName
    }
})
$form.Controls.Add($browseButton)

# Arguments input
$argsLabel = New-Object System.Windows.Forms.Label
$argsLabel.Location = New-Object System.Drawing.Point(10,70)
$argsLabel.Size = New-Object System.Drawing.Size(480,20)
$argsLabel.Text = 'Arguments (optional):'
$form.Controls.Add($argsLabel)

$argsTextBox = New-Object System.Windows.Forms.TextBox
$argsTextBox.Location = New-Object System.Drawing.Point(10,90)
$argsTextBox.Size = New-Object System.Drawing.Size(460,20)
$form.Controls.Add($argsTextBox)

# Output file input
$outputLabel = New-Object System.Windows.Forms.Label
$outputLabel.Location = New-Object System.Drawing.Point(10,120)
$outputLabel.Size = New-Object System.Drawing.Size(480,20)
$outputLabel.Text = 'Output File Name (optional):'
$form.Controls.Add($outputLabel)

$outputTextBox = New-Object System.Windows.Forms.TextBox
$outputTextBox.Location = New-Object System.Drawing.Point(10,140)
$outputTextBox.Size = New-Object System.Drawing.Size(460,20)
$form.Controls.Add($outputTextBox)

# Custom Command input
$customCmdLabel = New-Object System.Windows.Forms.Label
$customCmdLabel.Location = New-Object System.Drawing.Point(10,170)
$customCmdLabel.Size = New-Object System.Drawing.Size(480,20)
$customCmdLabel.Text = 'Custom Command (optional):'
$form.Controls.Add($customCmdLabel)

$customCmdTextBox = New-Object System.Windows.Forms.TextBox
$customCmdTextBox.Location = New-Object System.Drawing.Point(10,190)
$customCmdTextBox.Size = New-Object System.Drawing.Size(460,40)
$customCmdTextBox.Multiline = $true
$form.Controls.Add($customCmdTextBox)

# Network checkbox
$networkCheckBox = New-Object System.Windows.Forms.CheckBox
$networkCheckBox.Location = New-Object System.Drawing.Point(10,240)
$networkCheckBox.Size = New-Object System.Drawing.Size(150,20)
$networkCheckBox.Text = 'Disable Network'
$form.Controls.Add($networkCheckBox)

# Read-Only checkbox
$readOnlyCheckBox = New-Object System.Windows.Forms.CheckBox
$readOnlyCheckBox.Location = New-Object System.Drawing.Point(10,265)
$readOnlyCheckBox.Size = New-Object System.Drawing.Size(150,20)
$readOnlyCheckBox.Text = 'Read-Only'
$form.Controls.Add($readOnlyCheckBox)

# Run button
$runButton = New-Object System.Windows.Forms.Button
$runButton.Location = New-Object System.Drawing.Point(380,300)
$runButton.Size = New-Object System.Drawing.Size(100,30)
$runButton.Text = 'Run'
$runButton.Add_Click({
    # Extracting values from the form
    $ExecutablePath = $pathTextBox.Text
    $Arguments = $argsTextBox.Text
    $OutputFile = $outputTextBox.Text
    $CustomCommand = $customCmdTextBox.Text
    $DisableNetwork = $networkCheckBox.Checked
    $ReadOnly = $readOnlyCheckBox.Checked

    # Validate input
    if (![System.IO.File]::Exists($ExecutablePath)) {
        [System.Windows.Forms.MessageBox]::Show("Executable path is invalid. Please select a valid .exe file.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    # Constructing the Logon Command
    $logonCommand = if ($CustomCommand) {
        $CustomCommand
    } else {
        $sandboxExecutablePath = Join-Path -Path "C:\Users\WDAGUtilityAccount\Desktop\output" -ChildPath (Split-Path -Path $ExecutablePath -Leaf)
        $sandboxOutputPath = Join-Path -Path "C:\Users\WDAGUtilityAccount\Desktop\output" -ChildPath $OutputFile
        if ($OutputFile) {
            "cmd.exe /c `"$sandboxExecutablePath`" $Arguments | Out-File -FilePath `"$sandboxOutputPath`""
        } else {
            "cmd.exe /c start `"$sandboxExecutablePath`" $Arguments"
        }
    }
    
    # Generating Sandbox Configuration
    Generate-SandboxConfig -ExecutablePath $ExecutablePath -OutputFile $OutputFile -DisableNetwork:$DisableNetwork -ReadOnly:$ReadOnly -LogonCommand $logonCommand
    
    $wsbFilePath = Join-Path -Path (Get-Location) -ChildPath "CustomSandboxConfig.wsb"
    # Check if the .wsb file was successfully created
    if (Test-Path -Path $wsbFilePath) {
        try {
            # Start Windows Sandbox with the .wsb configuration file
            Start-Process -FilePath "C:\Windows\System32\WindowsSandbox.exe" -ArgumentList $wsbFilePath -ErrorAction Stop
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show("Failed to start Windows Sandbox. Please ensure Windows Sandbox is enabled and try again.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    }
    else {
        [System.Windows.Forms.MessageBox]::Show("The .wsb file was not found. Please check the script and try again.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }

    $form.Close()
})
$form.Controls.Add($runButton)

# Show the form
$form.ShowDialog()
