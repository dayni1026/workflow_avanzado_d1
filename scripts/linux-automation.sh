#!/bin/bash
# scripts/linux-automation.sh

set -e  # Exit on error
set -o pipefail

echo "=== LINUX SYSTEM AUTOMATION ==="
echo "Timestamp: $(date)"
echo "User: $(whoami)"
echo "Hostname: $(hostname)"
echo ""

# Create directories
echo "1. Creating directory structure..."
mkdir -p output logs backups

# File operations - Read/write files
echo ""
echo "2. File operations..."

# Create system info file
cat > output/system-info.txt << EOF
System Information
==================
Date: $(date)
User: $(whoami)
Hostname: $(hostname)
OS: $(lsb_release -ds 2>/dev/null || cat /etc/os-release | grep PRETTY_NAME)
Kernel: $(uname -r)
Memory: $(free -h | awk '/^Mem:/ {print $2}')
EOF

# Create CSV file
echo "id,name,value,timestamp" > output/data.csv
for i in {1..5}; do
  echo "$i,item_$i,$((RANDOM % 100)),$(date +%s)" >> output/data.csv
done

# Create JSON file
cat > output/config.json << EOF
{
  "environment": "${NODE_ENV}",
  "timestamp": "$(date -Iseconds)",
  "system": {
    "hostname": "$(hostname)",
    "user": "$(whoami)"
  }
}
EOF

echo "Files created in output/ directory"

# File permissions management (chmod)
echo ""
echo "3. Managing file permissions..."

# Create files with different permissions
echo "Public content" > output/public.txt
echo "Private content" > output/private.txt
echo "Executable script" > output/script.sh
echo "Backup data" > backups/data.bak

# Apply permissions
chmod 644 output/public.txt      # rw-r--r--
chmod 600 output/private.txt     # rw-------
chmod 755 output/script.sh       # rwxr-xr-x
chmod 400 backups/data.bak       # r--------

echo "Permissions applied:"
echo "  public.txt: $(stat -c %A output/public.txt)"
echo "  private.txt: $(stat -c %A output/private.txt)"
echo "  script.sh: $(stat -c %A output/script.sh)"
echo "  data.bak: $(stat -c %A backups/data.bak)"

# Background processes
echo ""
echo "4. Creating background processes..."

# Process 1: System monitor
(
  echo "Starting system monitor at $(date)" > logs/monitor.log
  for i in {1..3}; do
    echo "[$(date '+%H:%M:%S')] Monitor iteration $i" >> logs/monitor.log
    echo "CPU load: $(uptime | awk '{print $10 $11 $12}')" >> logs/monitor.log
    sleep 2
  done
) &
MONITOR_PID=$!

# Process 2: Data processor
(
  for i in {1..5}; do
    echo "Processing data $i at $(date)" >> logs/processor.log
    sleep 1
  done
) &
PROCESSOR_PID=$!

echo "Background processes started:"
echo "  Monitor PID: $MONITOR_PID"
echo "  Processor PID: $PROCESSOR_PID"

# Wait for processes to do some work
echo "Waiting for processes to work..."
sleep 3

# Stop background processes
kill $MONITOR_PID $PROCESSOR_PID 2>/dev/null || true
echo "Background processes stopped"

# Environment variables and secrets
echo ""
echo "5. Environment variables and secrets..."

echo "Environment variables:" > output/env-vars.txt
echo "NODE_ENV: $NODE_ENV" >> output/env-vars.txt
echo "USER: $(whoami)" >> output/env-vars.txt
echo "HOSTNAME: $(hostname)" >> output/env-vars.txt

# Handle secret (without exposing it)
if [ -n "$SECRET_MESSAGE" ]; then
  echo "Secret is configured (value hidden)" >> output/secrets.txt
  echo "Operation using secret completed" >> output/secret-operation.txt
else
  echo "No secret configured" >> output/secrets.txt
fi

echo "Environment info saved to output/env-vars.txt"

# Generate artifacts
echo ""
echo "6. Generating artifacts..."

# Create summary file
cat > output/execution-summary.md << EOF
# Linux Automation Execution Summary

## Execution Details
- Date: $(date)
- Script: linux-automation.sh
- Status: Completed successfully
- Exit Code: 0

## Files Generated
$(find output/ -type f | while read f; do
  echo "- \`$(basename "$f")\` ($(stat -c %s "$f") bytes)"
done)

## System Info
- OS: $(uname -s)
- Kernel: $(uname -r)
- Architecture: $(uname -m)

## Background Processes
- Started: 2 processes
- Duration: ~3 seconds
EOF

# List generated files
echo ""
echo "=== GENERATED FILES ==="
find output/ logs/ backups/ -type f 2>/dev/null | sort

echo ""
echo "=== LINUX AUTOMATION COMPLETED SUCCESSFULLY ==="
echo "Exit code: 0"
y en el de windows este
# scripts/windows-automation.ps1
Write-Host "=== WINDOWS SYSTEM AUTOMATION ===" -ForegroundColor Cyan
Write-Host "Date: $(Get-Date)"
Write-Host "User: $env:USERNAME"
Write-Host "Computer: $env:COMPUTERNAME"
Write-Host ""

# Create directories
Write-Host "1. Creating directory structure..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path output, logs, backups | Out-Null

# File operations
Write-Host "`n2. File operations..." -ForegroundColor Yellow

# Create system info file
$systemInfo = @"
System Information
==================
Date: $(Get-Date)
User: $env:USERNAME
Computer: $env:COMPUTERNAME
OS: $([Environment]::OSVersion.VersionString)
PowerShell: $($PSVersionTable.PSVersion)
Memory: $([math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)) GB
"@

$systemInfo | Out-File -FilePath "output\system-info.txt" -Encoding UTF8

# Create CSV file
$csvData = @()
for ($i = 1; $i -le 5; $i++) {
    $csvData += [PSCustomObject]@{
        Id = $i
        Name = "item_$i"
        Value = Get-Random -Minimum 1 -Maximum 100
        Timestamp = Get-Date -Format "o"
    }
}
$csvData | Export-Csv -Path "output\data.csv" -NoTypeInformation -Encoding UTF8

# Create JSON file
$jsonConfig = @{
    environment = $env:NODE_ENV
    timestamp = Get-Date -Format "o"
    system = @{
        computerName = $env:COMPUTERNAME
        userName = $env:USERNAME
    }
}
$jsonConfig | ConvertTo-Json | Out-File -FilePath "output\config.json" -Encoding UTF8

Write-Host "Files created in output\ directory" -ForegroundColor Green

# File permissions management (icacls)
Write-Host "`n3. Managing file permissions..." -ForegroundColor Yellow

# Create files
"Public content" | Out-File -FilePath "output\public.txt" -Encoding UTF8
"Private content" | Out-File -FilePath "output\private.txt" -Encoding UTF8
"Backup data" | Out-File -FilePath "backups\data.bak" -Encoding UTF8

# Apply permissions using icacls
try {
    # Public file - Read for everyone
    icacls "output\public.txt" /inheritance:r /grant:r "Everyone:(R)" 2>&1 | Out-Null
    
    # Private file - Read only for current user
    icacls "output\private.txt" /inheritance:r /grant:r "$env:USERNAME:(R)" 2>&1 | Out-Null
    
    # Backup file - No inheritance, restricted
    icacls "backups\data.bak" /inheritance:r 2>&1 | Out-Null
    
    Write-Host "Permissions applied successfully" -ForegroundColor Green
    Write-Host "Current permissions:" -ForegroundColor Gray
    Get-ChildItem output\, backups\ -File | ForEach-Object {
        $perm = icacls $_.FullName 2>&1 | Select-String $env:USERNAME, "Everyone"
        Write-Host "  $($_.Name): $perm"
    }
}
catch {
    Write-Host "Error applying permissions: $_" -ForegroundColor Red
}

# Background processes (Jobs)
Write-Host "`n4. Creating background processes..." -ForegroundColor Yellow

# Job 1: System monitor
$job1 = Start-Job -Name "SystemMonitor" -ScriptBlock {
    "Starting system monitor at $(Get-Date)" | Out-File -FilePath "logs\monitor.log" -Encoding UTF8
    for ($i = 1; $i -le 3; $i++) {
        $timestamp = Get-Date -Format "HH:mm:ss"
        "[$timestamp] Monitor iteration $i" | Out-File -FilePath "logs\monitor.log" -Append -Encoding UTF8
        "[$timestamp] CPU: $(Get-Counter '\Processor(_Total)\% Processor Time' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue)" | Out-File -FilePath "logs\monitor.log" -Append -Encoding UTF8
        Start-Sleep -Seconds 2
    }
}

# Job 2: Data processor
$job2 = Start-Job -Name "DataProcessor" -ScriptBlock {
    for ($i = 1; $i -le 5; $i++) {
        "Processing data $i at $(Get-Date)" | Out-File -FilePath "logs\processor.log" -Append -Encoding UTF8
        Start-Sleep -Seconds 1
    }
}

Write-Host "Background jobs started:" -ForegroundColor Green
Get-Job | Select-Object Id, Name, State | Format-Table -AutoSize

# Wait for jobs to work
Write-Host "Waiting for jobs to work..." -ForegroundColor Gray
Start-Sleep -Seconds 3

# Get job results and clean up
$job1 | Receive-Job -AutoRemoveJob -Wait
$job2 | Receive-Job -AutoRemoveJob -Wait

Write-Host "Background jobs completed" -ForegroundColor Green

# Environment variables and secrets
Write-Host "`n5. Environment variables and secrets..." -ForegroundColor Yellow

# Environment variables
$envVars = @"
Environment Variables
====================
NODE_ENV: $env:NODE_ENV
USERNAME: $env:USERNAME
COMPUTERNAME: $env:COMPUTERNAME
"@

$envVars | Out-File -FilePath "output\env-vars.txt" -Encoding UTF8

# Handle secret (without exposing it)
if (-not [string]::IsNullOrEmpty($env:SECRET_MESSAGE)) {
    "Secret is configured (value hidden)" | Out-File -FilePath "output\secrets.txt" -Encoding UTF8
    "Operation using secret completed" | Out-File -FilePath "output\secret-operation.txt" -Encoding UTF8
}
else {
    "No secret configured" | Out-File -FilePath "output\secrets.txt" -Encoding UTF8
}

Write-Host "Environment info saved to output\env-vars.txt" -ForegroundColor Green

# Generate artifacts
Write-Host "`n6. Generating artifacts..." -ForegroundColor Yellow

# Create summary file
$summary = @"
# Windows Automation Execution Summary

## Execution Details
- Date: $(Get-Date)
- Script: windows-automation.ps1
- Status: Completed successfully
- Exit Code: 0

## Files Generated
$(
    $files = Get-ChildItem -Recurse output, logs, backups -File -ErrorAction SilentlyContinue
    foreach ($file in $files) {
        "- ``$($file.Name)`` ($($file.Length) bytes)"
    }
)

## System Info
- OS: $([Environment]::OSVersion.VersionString)
- PowerShell: $($PSVersionTable.PSVersion)
- Architecture: $env:PROCESSOR_ARCHITECTURE

## Background Processes
- Started: 2 jobs
- Duration: ~3 seconds
"@

$summary | Out-File -FilePath "output\execution-summary.md" -Encoding UTF8

# List generated files
Write-Host "`n=== GENERATED FILES ===" -ForegroundColor Magenta
Get-ChildItem -Recurse output, logs, backups -File -ErrorAction SilentlyContinue | 
    Select-Object Directory, Name, Length | 
    Format-Table -AutoSize

Write-Host "`n=== WINDOWS AUTOMATION COMPLETED SUCCESSFULLY ===" -ForegroundColor Green
Write-Host "Exit code: 0" -ForegroundColor Green

exit 0