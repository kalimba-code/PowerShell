# Install-ShellWatch v1.0
# Programmed by Kalimba

# Tidy Up
Clear-Host

# Test if OneDrive is backing up the Desktop and set the path accordingly
if (Test-Path -Path "$($HOME)\*\Desktop") { 
    $DesktopPath = Get-ItemProperty -Path "$($HOME)\*\Desktop" | Select-Object -ExpandProperty FullName 
} else {
    $DesktopPath = "$($HOME)\Desktop" 
}

# Test if OneDrive is backing up the Documents and set the path accordingly
if (Test-Path -Path "$($HOME)\*\Documents") { 
    $DocumentsPath = Get-ItemProperty -Path "$($HOME)\*\Documents" | Select-Object -ExpandProperty FullName 
} else {
    $DocumentsPath = "$($HOME)\Documents" 
}

# Set the other reusable path variables
$KalimbaFolder = "$DocumentsPath\Kalimba"
$DownloadsPath = "$($HOME)\Downloads"

# Try and locate the downloaded zip file 
Write-Host "Finding the .zip folder..."
$ZipFilePath = Get-ItemProperty -Path "$DownloadsPath\ShellWatch.zip" | Select-Object -ExpandProperty FullName

if ($null -eq $ZipFilePath) {
    Write-Host "Please download the ShellWatch.zip file to the Downloads folder" -ForegroundColor Red
    break;
}

# Extract the folder if it hasn't been done
if ((Test-Path -Path $DownloadsPath\ShellWatch) -eq $false) {
    Write-Host "Extracting the ShellWatch.zip folder..."
    Expand-Archive -Path $ZipFilePath -DestinationPath $DownloadsPath
}

Write-Host "Creating the Kalimaba folder and subfolders in Documents..."
[void](New-Item -Type Directory -Name "Kalimba" -Path $DocumentsPath)
[void](New-Item -Type Directory -Name "Assets" -Path $KalimbaFolder)
# Create folders that will be used for shortcuts on the desktop
[void](New-Item -Type Directory -Name "ShellWatch" -Path $KalimbaFolder)
[void](New-Item -Type Directory -Name "Bowl" -Path $KalimbaFolder)

# The default module path I see recommend in Microsoft Documentation that doesn't require Admin rights
$PSModPath = "$DocumentsPath\WindowsPowerShell\Modules"

if ((Test-Path -Path $PSModPath) -eq $false) {
    Write-Host "Creating the $PSModPath folder..."
    [void](New-Item -Type Directory -Path $PSModPath)
}

Write-Host "Moving downloaded files..."
Get-ChildItem -Path "$DownloadsPath\ShellWatch\Assets" -Recurse | Move-Item -Destination "$KalimbaFolder\Assets"
Move-Item -Path "$DownloadsPath\ShellWatch\Shell.Watch" -Destination "$DocumentsPath\WindowsPowerShell\Modules"
Remove-Item -Path "$DownloadsPath\ShellWatch" -Recurse

Write-Host "Creating desktop shortcuts..."
$shell = New-Object -comObject WScript.Shell

$Shortcut = $shell.CreateShortcut("$DesktopPath\ShellWatch.lnk")
$Shortcut.WorkingDirectory = "$DocumentsPath"
$Shortcut.TargetPath = "$KalimbaFolder\ShellWatch"
$Shortcut.IconLocation = "$KalimbaFolder\Assets\ShellWatch.ico"
$Shortcut.Save()

$Shortcut = $shell.CreateShortcut("$KalimbaFolder\ShellWatch\Bowl.lnk")
$Shortcut.WorkingDirectory = "$KalimbaFolder\ShellWatch"
$Shortcut.TargetPath = "$KalimbaFolder\Bowl"
$Shortcut.IconLocation = "$KalimbaFolder\Assets\EmptyBowl.ico"
$Shortcut.Save()

Write-Host "Creating save data..."
$DefaultSave = @{
    Hunger = 100
    Money = 0
    Wins = 0
    Losses = 0
}
$DefaultSave | ConvertTo-Json -Depth 1 | Set-Content -Path "$DocumentsPath\Kalimba\SaveData.json"

Write-Host "Creating the start button..."
$Shortcut = $shell.CreateShortcut("$KalimbaFolder\ShellWatch\Start.lnk")
$Shortcut.TargetPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$Shortcut.Arguments = '-Command "Start-ShellWatch" -NoExit'
$Shortcut.IconLocation = "$KalimbaFolder\Assets\ShellWatch.ico"
$Shortcut.Save()

Write-Host "Finished!"