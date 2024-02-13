# Write the current date and time to a file
Get-Date | Out-File -FilePath C:\Users\WDAGUtilityAccount\Desktop\test_results.txt

# Test network connectivity (this will fail if networking is disabled)
Test-NetConnection www.google.com | Out-File -FilePath C:\Users\WDAGUtilityAccount\Desktop\test_results.txt -Append

# List currently running processes
Get-Process | Out-File -FilePath C:\Users\WDAGUtilityAccount\Desktop\test_results.txt -Append

"task1 completed by powershell" > C:\Users\WDAGUtilityAccount\Desktop\output.txt
