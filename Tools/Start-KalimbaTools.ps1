#Kalimba Tools v0.5
#Programed by Kalimba in Visual Studio Code
$Version = "0.5"

$Tag = "KalimaTools v$($Version) `nChoose a category by entering the corresponding number`nGreen text requires an admin window. Red text requires an admin window and permently deletes`n" 

$Numbers = @(0,1,2,3,4,5,6,7,8,9)

$End = $false

#Function to validate input. The $NumLimit variable determines the limit of the number that can be choosen
function Test-Input {

    param ($NumLimit)

    #Start the validation loop, it will be exited with a break statement
    while ($true) {
        #Assume the answer is invalid
        $Valid = $false

        #Prompt the user for a number
        $Num = Read-Host "Select a number"

        #Run through each number in the $Numbers array and test if the input is one of them and is less then or equal to the limit.
        foreach ($Number in $Numbers) {
            if ($Num -eq $Number -and $Num -le $NumLimit) {
                $Valid = $true
            }
        }   

        #Let the user know if the num is invalid
        if ($Valid -eq $False) {
            Write-Host "Please enter a single number between 0 and $NumLimit" -ForegroundColor Cyan
        }

        #Break out of the loop if the input is valid
        if ($Valid -eq $true) {
            break
        }
    }

    #Return the Input
    $Num
}

function Get-PrinterMenu {

    $Clear = $true

    while ($true) {

        if ($Clear -eq $true) {
            Clear-Host
            Write-Host $Tag -ForegroundColor Cyan
            Write-Host "`t0 - Back"
            Write-Host "`t1 - Reset and clear print spooler" -ForegroundColor Green
            Write-Host "`t2 - Open Devices and Printers`n`t3 - List all printers with IPP drivers"
            Write-Host "`t4 - Remove default Microsoft printers`n" -ForegroundColor Red
        }
        $Clear = $true

        $NumLimit = 4
        $Choice = Test-Input -NumLimit $NumLimit

        switch ($Choice) {
            0 {$End = $true}
            1 {
                Write-Host "Stopping the Print Spooler" -ForegroundColor Cyan
                Stop-Service -DisplayName "Print Spooler"
                
                Write-Host "Clearing out the spooler" -ForegroundColor Cyan
                $PrintKey = Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Print\Printers
                Remove-Item -Path "$($PrintKey.DefaultSpoolDirectory)" -Force

                Write-Host "Starting the Print Spooler" -ForegroundColor Cyan
                Start-Service -DisplayName "Print Spooler"

                $Clear = $false
            }
            2 {

            }
            3 {
                Get-Printer | Where-Object {$_.DriverName -like "*IPP*"}

                $Clear = $false
            }
            4 {
                Get-Printer | Where-Object {$_.DriverName -like "*Microsoft*"} | Remove-Printer

                $Clear = $false
            }
        
        }
    
        if ($End -eq $true)
        {
            break
        }
    }
}

function Get-InfoMenu {
    $Clear = $true

    while ($true) {

        if ($Clear -eq $true) {
            Clear-Host
            Write-Host $Tag -ForegroundColor Cyan
            Write-Host "`t0 - Back"
            Write-Host "`t1 - Windows Info`n`t2 - Network Info`n`t3 - Disk Info`n"
        }

        $Clear = $true

        $NumLimit = 4
        $Choice = Test-Input -NumLimit $NumLimit

        switch ($Choice) {
            0 {$End = $true}
            1 {
                $Env:COMPUTERNAME
                $Env:OS
                $Env:USERPROFILE
            }
            2 {
                Get-NetIPConfiguration | Format-List -Property @{Name="Interface"; Expression={$_.InterfaceAlias}}, InterfaceDescription, @{Name="Status"; Expression={$_.NetAdapter.Status}}, @{Name="Network Name"; Expression={$_.NetProfile.Name}}, IPv4Address, IPv4DefaultGateway, IPv6Address, IPv6DefaultGateway, @{Name="DNSServer"; Expression={$_.DNSServer}}
            }
            3 {
                Get-PhysicalDisk | Format-Table -Property MediaType, Model, SerialNumber, @{Name='Size GB'; Expression={$_.Size / 1GB}}, BusType
            }
        }

        $Clear = $false

        if ($End -eq $true)
        {
            break
        }
    }

}

while ($true) {
    Clear-Host

    #Display the menu
    Write-Host $Tag -ForegroundColor Cyan
    Write-Host "`t0 - Exit Program`n`t1 - PC Info`n`t2 - Printers`n"
    
    $NumLimit = 1
    $Choice = Test-Input -NumLimit $NumLimit
    
    switch ($Choice) {
        0 {$End = $true}
        1 {Get-InfoMenu}
        2 {Get-PrinterMenu}
    }

    if ($End -eq $true)
    {
        break
    }
}
