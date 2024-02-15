Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Sandbox Execution Tool'
$form.Size = New-Object System.Drawing.Size(500,400)
$form.StartPosition = 'CenterScreen'

# Path input
$pathLabel = New-Object System.Windows.Forms.Label
$pathLabel.Location = New-Object System.Drawing.Point(10,20)
$pathLabel.Size = New-Object System.Drawing.Size(480,20)
$pathLabel.Text = 'Executable Path:'
$form.Controls.Add($pathLabel)


$pathTextBox = New-Object System.Windows.Forms.TextBox
$pathTextBox.Location = New-Object System.Drawing.Point(10,40)
$pathTextBox.Size = New-Object System.Drawing.Size(360,20)
$form.Controls.Add($pathTextBox)


# File browsing for Executable Path
$browseButton = New-Object System.Windows.Forms.Button
$browseButton.Location = New-Object System.Drawing.Point(370,40)
$browseButton.Size = New-Object System.Drawing.Size(100,20)
$browseButton.Text = "Choose file"
$browseButton.Add_Click({
    $fileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $fileDialog.Filter = "C# builded Files (*.exe)|*.exe"
    $fileDialog.ShowDialog() | Out-Null
    $pathTextBox.Text = $fileDialog.FileName
})
$form.Controls.Add($browseButton)

# Custom Command input
$customCmdLabel = New-Object System.Windows.Forms.Label
$customCmdLabel.Location = New-Object System.Drawing.Point(10,70)
$customCmdLabel.Size = New-Object System.Drawing.Size(480,20)
$customCmdLabel.Text = 'Custom Command (optional):'
$form.Controls.Add($customCmdLabel)

$customCmdTextBox = New-Object System.Windows.Forms.TextBox
$customCmdTextBox.Location = New-Object System.Drawing.Point(10,90)
$customCmdTextBox.Size = New-Object System.Drawing.Size(460,20)
$customCmdTextBox.Multiline = $true
$customCmdTextBox.Height = 60
$form.Controls.Add($customCmdTextBox)

# Output file input
$outputLabel = New-Object System.Windows.Forms.Label
$outputLabel.Location = New-Object System.Drawing.Point(10,160)
$outputLabel.Size = New-Object System.Drawing.Size(480,20)
$outputLabel.Text = 'Output File Name (Ex: output.txt):'
$form.Controls.Add($outputLabel)

$outputTextBox = New-Object System.Windows.Forms.TextBox
$outputTextBox.Location = New-Object System.Drawing.Point(10,180)
$outputTextBox.Size = New-Object System.Drawing.Size(460,20)
$form.Controls.Add($outputTextBox)

# Network checkbox
$networkCheckBox = New-Object System.Windows.Forms.CheckBox
$networkCheckBox.Location = New-Object System.Drawing.Point(15,245)
$networkCheckBox.Size = New-Object System.Drawing.Size(150,35)
$networkCheckBox.Text = 'Disable Network'
$form.Controls.Add($networkCheckBox)

# Read-Only checkbox
$readOnlyCheckBox = New-Object System.Windows.Forms.CheckBox
$readOnlyCheckBox.Location = New-Object System.Drawing.Point(15,210)
$readOnlyCheckBox.Size = New-Object System.Drawing.Size(150,35)
$readOnlyCheckBox.Text = 'Read-Only'
$form.Controls.Add($readOnlyCheckBox)

# Run button
$runButton = New-Object System.Windows.Forms.Button
$runButton.Location = New-Object System.Drawing.Point(380,210)
$runButton.Size = New-Object System.Drawing.Size(90,35)
$runButton.Text = 'Run'
$runButton.Add_Click({
    $ExecutablePath = $pathTextBox.Text
    $OutputFile = $outputTextBox.Text
    $DisableNetwork = $networkCheckBox.Checked
    $ReadOnly = $readOnlyCheckBox.Checked
    $CustomCommand = $customCmdTextBox.Text

    # Validate the executable path
    if ([System.IO.Path]::GetExtension($ExecutablePath) -ne '.exe') {
        [System.Windows.Forms.MessageBox]::Show("Please enter a valid path to the .exe file.", "Invalid Input", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    $hostFolderPath = Split-Path -Path $ExecutablePath -Parent
    $sandboxFolderPath = "C:\Users\WDAGUtilityAccount\Desktop\output"
    $sandboxExecutableName = [System.IO.Path]::GetFileName($ExecutablePath)
    $sandboxOutputPath = Join-Path -Path "C:\Users\WDAGUtilityAccount\Desktop\output" -ChildPath $OutputFile

    $logonCommand = if ($CustomCommand) {
        # When the user provides a custom command, ensure it's properly escaped for XML
        [Security.SecurityElement]::Escape($CustomCommand)
    } else {
        # Construct a default command
        $sandboxExecutableName = [System.IO.Path]::GetFileName($ExecutablePath)
        $sandboxOutputPath = Join-Path -Path "C:\Users\WDAGUtilityAccount\Desktop\output" -ChildPath $OutputFile
        "C:\Users\WDAGUtilityAccount\Desktop\output\$sandboxExecutableName | Out-File -FilePath $sandboxOutputPath"
    }

    # Construct the arguments for the generation script
    $commandArgs = @("-ExecutablePath `"$ExecutablePath`"", "-LogonCommand `"$logonCommand`"")
    
    if ($DisableNetwork) {
        $commandArgs += "-DisableNetwork"
    }
    
    if ($ReadOnly) {
        $commandArgs += "-ReadOnly"
    }

    # Call the generation script with the constructed arguments
    $command = "powershell.exe -File step4-GenerateSandboxConfig.ps1 " + ($commandArgs -join ' ')

    # Execute the command
    Invoke-Expression $command
    
    $form.Close()
})
$form.Controls.Add($runButton)

# Show the form
$form.ShowDialog()
