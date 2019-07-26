function get-proctimeandRAM() {
    [CmdletBinding()]
    param (
        [string]$computername = $env:COMPUTERNAME
    )

    Get-WmiObject -ClassName Win32_Process -ComputerName $computername |
    foreach {
        $props = [ordered]@{
            Name          = $psitem.Name
            ProcessId     = $psitem.ProcessId
            RAM           = [math]::Round($psitem.WS / 1mb)
            ProcessorTime = [math]::Round(($psitem.KernalModeTime + $psitem.UserModeTime) / 10000000)
            UserName      = $psitem.GetOwner().Domain + "\" + $psitem.GetOwner().User
        }
        New-Object -TypeName PSObject -Property $props
    }
}

$server = Read-Host 'Please enter PC Name'
$sortby = 'ProcessorTime'
$sort = Read-Host 'Choose sort mode (1 - by CPU (Default), 2 - by RAM)'
If ($sort -eq '2') {
    $sortby = 'RAM'
}

get-proctimeandRAM -ComputerName $server | Sort-Object -Descending $sortby | ft -AutoSize | Select -First 15