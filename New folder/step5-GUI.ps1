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

# Text input
$textInputLabel = New-Object System.Windows.Forms.Label
$textInputLabel.Location = New-Object System.Drawing.Point(10,70)
$textInputLabel.Size = New-Object System.Drawing.Size(480,20)
$textInputLabel.Text = 'Text Input:'
$form.Controls.Add($textInputLabel)

$textInputTextBox = New-Object System.Windows.Forms.TextBox
$textInputTextBox.Location = New-Object System.Drawing.Point(10,90)
$textInputTextBox.Size = New-Object System.Drawing.Size(460,20)
$form.Controls.Add($textInputTextBox)

# Output file input
$outputLabel = New-Object System.Windows.Forms.Label
$outputLabel.Location = New-Object System.Drawing.Point(10,120)
$outputLabel.Size = New-Object System.Drawing.Size(480,20)
$outputLabel.Text = 'Output File Name (Ex: output.txt):'
$form.Controls.Add($outputLabel)

$outputTextBox = New-Object System.Windows.Forms.TextBox
$outputTextBox.Location = New-Object System.Drawing.Point(10,140)
$outputTextBox.Size = New-Object System.Drawing.Size(460,20)
$form.Controls.Add($outputTextBox)

# Network checkbox
$networkCheckBox = New-Object System.Windows.Forms.CheckBox
$networkCheckBox.Location = New-Object System.Drawing.Point(15,195)
$networkCheckBox.Size = New-Object System.Drawing.Size(150,35)
$networkCheckBox.Text = 'Disable Network'
$form.Controls.Add($networkCheckBox)

# Read-Only checkbox
$readOnlyCheckBox = New-Object System.Windows.Forms.CheckBox
$readOnlyCheckBox.Location = New-Object System.Drawing.Point(15,170)
$readOnlyCheckBox.Size = New-Object System.Drawing.Size(150,35)
$readOnlyCheckBox.Text = 'Read-Only'
$form.Controls.Add($readOnlyCheckBox)

# Run button
$runButton = New-Object System.Windows.Forms.Button
$runButton.Location = New-Object System.Drawing.Point(380,170)
$runButton.Size = New-Object System.Drawing.Size(90,35)
$runButton.Text = 'Run'
$runButton.Add_Click({

    # Construct the command with parameters from the form
    $ExecutablePath = $pathTextBox.Text
    $OutputFile = $outputTextBox.Text
    $TextInput = $textInputTextBox.Text
    $DisableNetwork = $networkCheckBox.Checked
    $ReadOnly = $readOnlyCheckBox.Checked

    $commandArgs = @("-ExecutablePath `"$ExecutablePath`"", "-OutputFile `"$OutputFile`"")
    
    if ([System.IO.Path]::GetExtension($pathTextBox.Text) -ne '.exe') {
        [System.Windows.Forms.MessageBox]::Show("Please enter a valid path to the .exe file.", "Invalid Input", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    if ($TextInput) {
        $commandArgs += "-textInput `"$TextInput`""
    }

    if ($DisableNetwork) {
        $commandArgs += "-DisableNetwork"
    }
    
    if ($ReadOnly) {
        $commandArgs += "-ReadOnly"
    }
    
    $command = "powershell.exe -File step4-GenerateSandboxConfig.ps1 " + ($commandArgs -join ' ')

    # Run the command
    Invoke-Expression $command
    
    $form.Close()
})
$form.Controls.Add($runButton)

# Show the form
$form.ShowDialog()
