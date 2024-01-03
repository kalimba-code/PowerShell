# Install-Hangman v1.0
# Programmed by Kalimba in Visual Studio Code for PowerShellv5 and up
# Works in Windows 10 and Windows 11

# Clear the pasted text
Clear-Host

# Set environmental paths for the Documents and Desktop folders
$DocumentsPath = [environment]::GetFolderPath("mydocument")
$DesktopPath = [environment]::GetFolderPath("desktop")

# Set the other reusable path variables
$KalimbaPath = "$DocumentsPath\Kalimba"
$HangmanPath = "$KalimbaPath\Hangman"
$DownloadsPath = "$($HOME)\Downloads"
$HangmanDownloadsPath = "$DownloadsPath\Hangman"
$ZipFilePath = "$DownloadsPath\Hangman.zip"


Write-Host "Finding the downloaded folder..."
if ((Test-Path -Path "$HangmanDownloadsPath*") -eq $false) {
    Write-Host "Please download the Hangman.zip file to the Downloads folder" -ForegroundColor Red
    break;
} else {
    # Extract the folder if it hasn't been done
    if ((Test-Path -Path $HangmanDownloadsPath) -eq $false) {
        Write-Host "Extracting the Hangman.zip folder..."
        Expand-Archive -Path $ZipFilePath -DestinationPath $DownloadsPath
    }

    # Test if the user has a Kalimba folder from one of my other programs
    if ((Test-Path -Path $KalimbaPath) -eq $false) {
        # Send it to void to stop the new file message from displaying
        [void](New-Item -Type Directory -Name "Kalimba" -Path $DocumentsPath)
    }

    # The default module path I see recommend in Microsoft Documentation that doesn't require Admin rights
    $PSModPath = "$DocumentsPath\WindowsPowerShell\Modules"

    if ((Test-Path -Path $PSModPath) -eq $false) {
        Write-Host "Creating the WindowsPowerShell\Modules folder..."
        [void](New-Item -Type Directory -Path $PSModPath)
    }

    Write-Host "Moving downloaded files..."
    # I might be missing something, but I cannot get Move-Item to work with -Force. Kept getting the "Move-Item : Cannot create a file when that file already exists." error.
    # That is the reason behind the if statement. I want the new file to overwrite the old file in case the installer is being used as a updater to a newer version of the program.
    if (Test-Path -Path "$DocumentsPath\WindowsPowerShell\Modules\Kalimba.Hangman") {
        Remove-Item -Path "$DocumentsPath\WindowsPowerShell\Modules\Kalimba.Hangman" -Force -Recurse
    }
    Move-Item -Path "$HangmanDownloadsPath\Kalimba.Hangman" -Destination "$DocumentsPath\WindowsPowerShell\Modules"

    # The reason I test instead of using -Force is to preserve any custom dictionaries or sprite sheets.
    if ((Test-Path -Path $HangmanPath) -eq $false) {
        [void](New-Item -ItemType Directory -Path $HangmanPath)
        Get-ChildItem -Path "$HangmanDownloadsPath\*" | Move-Item -Destination $HangmanPath
    }

    Write-Host "Removing the downloaded files..."
    # Delete the zip folder if hasn't been done
    if ((Test-Path -Path "$HangmanDownloadsPath.zip") -eq $True) {
        Remove-Item -Path $ZipFilePath
    }
    Remove-Item -Path $HangmanDownloadsPath -Recurse

    Write-Host "Creating a desktop shortcut..."
    $shell = New-Object -comObject WScript.Shell
    $Shortcut = $shell.CreateShortcut("$DesktopPath\Hangman.lnk")
    $Shortcut.TargetPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
    $Shortcut.Arguments = '-Command "Start-Hangman" -NoExit'
    $Shortcut.IconLocation = "$KalimbaPath\Hangman\Assets\Hangman.ico"
    $Shortcut.Save()

    Write-Host "Install Finished!!!" -ForegroundColor Cyan
}