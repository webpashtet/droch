function Detect-VirtualMachine {
    Param (
        [string]$ComputerName
    )
    $VMModels = @("Virtual Machine", "VMware Virtual Platform", "Xen", "VirtualBox", "Parallels Virtual Platform")
    $CheckPhysicalOrVMQuery = Get-WmiObject -ComputerName $ComputerName -Query "Select * FROM Win32_ComputerSystem" -Namespace "root\CIMV2" -ErrorAction SilentlyContinue
    if ($VMModels -contains $CheckPhysicalOrVMQuery.Model) {
        $IsVM = $True
    }
    else {
        $IsVM = $False
    }
    return $IsVM
}

$hren = 'Decay'
$Out = @()
$Out += Write-Output ("Name;UserName;Adapter")
$servers = '.'#Get-Content C:\Users\$hren\Desktop\MachineBase.txt
$machines = 0

foreach ($Server in $Servers) {
    Write-host Look at: $Server machine
    $Ping = Test-Connection -ComputerName $Server -Count 1 -Quiet
    if ($Ping -eq $true) { break }
    $S_error = ""
    Write-Host Work on: $Server machine
    $IsPhysicalMachine = Detect-VirtualMachine -ComputerName $Server
    if ($S_error[0]) {
        Write-Host Established connection to $Server have error
        $Server | Out-File C:\Users\$hren\Desktop\notpinged.txt -Append
        break
    }
    elseif ($IsPhysicalMachine -eq $false) {
        $machines += 1
        $sys = Get-WmiObject Win32_ComputerSystem -ComputerName $Server
        $wifi = Get-WmiObject Win32_NetworkAdapter -ComputerName $Server | Where-Object { $_.Name -like '*Wireless*' }
        $Out += Write-Output ("{0};{1};{2}" -f $sys.Name, $sys.UserName, $wifi.Name)
        $Out > C:\Users\$hren\Desktop\enabled_wifi.csv
        $Out = $null
    }
    else {
        Write-Host 'Kakaya to error, sori'
        $Server | Out-File C:\Users\$hren\Desktop\err_base.txt
    }
}
Write-Host Proccessed $machines machines of ($servers).count
Invoke-Expression C:\Users\$hren\Desktop\enabled_wifi.csv