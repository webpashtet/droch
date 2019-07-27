Function Get-CPUProcess {
    [CmdletBinding()]
    param (
        [string]$computername = $env:COMPUTERNAME
    )
    $cores = (Get-WmiObject Win32_Processor -ComputerName $computername).NumberOfLogicalProcessors
    $properties = @(
        @{Name = "Name"; Expression = { $_.name } },
        @{Name = "PID"; Expression = { $_.IDProcess } },
        @{Name = "CPU (%)"; Expression = { for ($i = 0; $i -ne 3; $i++) { (Get-WMiObject -class Win32_PerfFormattedData_PerfProc_Process -ComputerName $computername -Filter "IDProcess='$($_.IDProcess)'").PercentProcessorTime / $cores; Start-Sleep(1)} } },
        @{Name = "Memory (MB)"; Expression = { [Math]::Round(($_.workingSetPrivate / 1mb), 2) } },
        @{Name = "Disk (MB)"; Expression = { [Math]::Round(($_.IODataOperationsPersec / 1mb), 2) } },
        @{Name = "User"; Expression = { $_.PSComputerName + '\' + (Get-WMiObject Win32_Process -ComputerName $computername -Filter "ProcessId='$($_.IDProcess)'").GetOwner().User } }
    )
    $ProcessCPU = Get-WmiObject -class Win32_PerfFormattedData_PerfProc_Process -ComputerName $computername | Where-Object { $_.Name -notmatch "^(idle|_total|system)$" -and $_.PercentProcessorTime -gt 0 } |
    Select-Object $properties |
    Sort-Object $sortby -desc |
    Select-Object -First 10 |
    Format-Table -AutoSize
    $ProcessCPU
}

$server = Read-Host 'Please enter PC Name'
$sortby = 'CPU (%)'
$sort = Read-Host 'Choose sort mode (1 - by CPU (Default), 2 - by RAM)'
If ($sort -eq '2') {
    $sortby = 'Memory (MB)'
}
Get-CPUProcess -computername $server