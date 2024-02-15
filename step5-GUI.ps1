Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Sandbox Execution Tool'
$form.Size = New-Object System.Drawing.Size(500,300)
$form.StartPosition = 'CenterScreen'

# Path input
$pathLabel = New-Object System.Windows.Forms.Label
$pathLabel.Location = New-Object System.Drawing.Point(10,20)
$pathLabel.Size = New-Object System.Drawing.Size(480,20)
$pathLabel.Text = 'Executable Path:'
$form.Controls.Add($pathLabel)

$pathTextBox = New-Object System.Windows.Forms.TextBox
$pathTextBox.Location = New-Object System.Drawing.Point(10,40)
$pathTextBox.Size = New-Object System.Drawing.Size(460,20)
$form.Controls.Add($pathTextBox)

# Output file input
$outputLabel = New-Object System.Windows.Forms.Label
$outputLabel.Location = New-Object System.Drawing.Point(10,70)
$outputLabel.Size = New-Object System.Drawing.Size(480,20)
$outputLabel.Text = 'Output File Name:'
$form.Controls.Add($outputLabel)

$outputTextBox = New-Object System.Windows.Forms.TextBox
$outputTextBox.Location = New-Object System.Drawing.Point(10,90)
$outputTextBox.Size = New-Object System.Drawing.Size(460,20)
$form.Controls.Add($outputTextBox)

# Text input
$textInputLabel = New-Object System.Windows.Forms.Label
$textInputLabel.Location = New-Object System.Drawing.Point(10,120)
$textInputLabel.Size = New-Object System.Drawing.Size(480,20)
$textInputLabel.Text = 'Text Input:'
$form.Controls.Add($textInputLabel)

$textInputTextBox = New-Object System.Windows.Forms.TextBox
$textInputTextBox.Location = New-Object System.Drawing.Point(10,140)
$textInputTextBox.Size = New-Object System.Drawing.Size(460,20)
$form.Controls.Add($textInputTextBox)

# Network checkbox
$networkCheckBox = New-Object System.Windows.Forms.CheckBox
$networkCheckBox.Location = New-Object System.Drawing.Point(10,170)
$networkCheckBox.Size = New-Object System.Drawing.Size(104,35)
$networkCheckBox.Text = 'Disable Network'
$form.Controls.Add($networkCheckBox)

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

    $commandArgs = @("-ExecutablePath `"$ExecutablePath`"", "-OutputFile `"$OutputFile`"")
    
    if ($TextInput) {
        $commandArgs += "-textInput `"$TextInput`""
    }

    if ($DisableNetwork) {
        $commandArgs += "-DisableNetwork"
    }

    $command = "powershell.exe -File step4-GenerateSandboxConfig.ps1 " + ($commandArgs -join ' ')

    # Run the command
    Invoke-Expression $command
    
    $form.Close()
})
$form.Controls.Add($runButton)

# Show the form
$form.ShowDialog()
