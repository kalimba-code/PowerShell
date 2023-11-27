# Purpose

This program recreates a Tamagotchi in a PowerShell Window. Tamagotchi is a portmanteau of two Japanese words meaning egg and watch, so I dubbed this project ShellWatch as it runs in PowerShell. Programmed by Kalimba, no other Tamagotchi Powershell projects where used as reference. 

# Installation

Download the ShellWatch.zip folder to your Downloads folder, and then select all of the code (CTRL+A) in the Install-ShellWatch script and copy (CTRL+C) it. Then paste 
(CTRL+V) the code into a PowerShell window and press Enter. When the install script is done, there will be a couple of new folders on your computer. First, a Kalimba folder
will show up in your Documents folder. This is where all the program files are located. Second, a ShellWatch folder will be created on the desktop with a custom ico. This is 
where the bowl folder will be located and the shortcuts for starting ShellWatch, playing games, and buying food will be located. For the best effect, change the view to extra large icons.

The execution policy needs to be set to remote signed for the Start button to work. Turning this on could be a security risk. If you are on a personal computer, I suggest researching this and make your own decision. If this is a work computer, please consult your IT department. If you are uncomfortable with running the following command, you can just delete the Start button in the ShellWatch desktop shortcut and manually run the program by opening PowerShell and typing "Start-ShellWatch". Otherwise, run PowerShell as an Administrator and paste the following command.

set-executionpolicy remotesigned

Then say y to the prompt.

# How to Play

Double-click on the ShellWatch icon on your Desktop, then click on the Start button with the same icon. Currently the Pet doesn't do anything but sit there and blink, while the hunger bar slowly widdles down. Don't worry, death hasn't been programmed in yet so it is fine. I will add game integration and the shop in the future. 

# Uninstall

I will add a uninstaller in the future, as for now there isn't one. To uninstall, delete the Kalimba folder under Documents, the ShellWatch shortcut on the desktop, and the Shell.Watch folder under Documents\WindowsPowerShell\Modules.