# About

This is a custom module that lets you play Hangman in a PowerShell window. All code was programmed by Kalimba. I avoided looking at any other Hangman PowerShell programs, I wanted to find solutions to all the problems by myself. This is version 2.0, a massive upgrade to the original 1.0 version. 

# Installation

1. Download the Hangman.zip folder to your Downloads folder.
2. Select all of the code (CTRL+A) in the Install-Hangman script and copy (CTRL+C) it.
3. Paste (CTRL+V) the code into a PowerShell window (no Admin privilege required!) and press Enter.
    - If you are running Windows 11, it is better to paste the code into the Windows PowerShell ISE (search for it). It will work in a regular window, it just won't look pretty. Essentially the Windows 11 built-in in PowerShell executes each line of code as it appears, while the ISE treats it as a script like the Windows 10 build-in PowerShell does.

When the install script is done, there will be a couple of new folders and files on your computer. If this is the first Kalimba program you have installed, a Kalimba folder will show up in your Documents folders. In the Kalimba folder there will be a Hangman folder, with two more sub folders, Assets and Lexicons. Assets stores the SpriteSheet.txt used for all ASCII displays and the .ico for the desktop icon. The Lexicons folder is where the comma separated .txt files full of words are located. The name of the file will be used as the theme.

A WindowsPowerShell folder will show up in your Documents folder if you don't have one already. In that folder there will be a Modules folder, where the Kalimba.Hangman folder will be located. The Documents\WindowsPowerShell\Modules path is an offical PowerShell path for Modules, and the only one that doesn't require admin privileges to move Modules to. You can move the Kalimba.Hangman folder to a different Module path if you like. 

There will also be a Hangman shortcut on the desktop with the custom .ico image. If you have the ShellWatch program installed, I recommend moving this shortcut to the ShellWatch folder to keep everything together.

# How to Play

Either launch the game using the desktop shortcut or enter "Start-Hangman" in a PowerShell window.

# ShellWatch Integration

Hangman intergrates the ShellWatch program if you have both installed! Wins and losses will show up in the ShellWatch window and wins give you money. This is a work in progress and subject to change. 

# Lexicons

These are the following pre-packaged lexicons. I will likely add and remove more in the future. If you would like to add a custom lexicon to the program, make a .txt file full of words. These words need to be separated by commas. The name of the file will be used to show the player the theme. Put that file in the Lexicons folder, located at:
Documents\Kalimba\Hangman\Lexicons

#### United States of America

Best theme to start with, just the 50 states. 

#### Fairy and Folktales

A list of well-known fairytales and folktales. There is a lot of multi-word entries. 

#### Mythology

A list of Greek and Norse mythological characters that are the most used in pop culture. Think Percy Jackson, Hades, God of War. This is probably a bad decision for Hangman, due to the different way mythological characters have their names spelled. For instance, I have Heracles instead of Hercules. I like it for now, but feel free to delete it if you don't. 

# Updating

To check the version number, type "Start-Hangman -?" in a PowerShell window, and look at the SYNOPSIS part. The current version is 2.0. If your version is lower, download the Hangman.zip
folder again and run the Install-Hangman script again. It will wipe out the old module and replace it with a new module. The Assets and Lexicons folder will remain untouched, as I don't plan on updating them and I don't want to wipe out any custom assets or lexicons.

# Uninstalling 

I will add an uninstall script soon. For now, delete the following files and folders:

- The Kalimba.Hangman at Documents\WindowsPowerShell\Modules
- The Hangman folder at Documents\Kalimba (or the whole Kalimba folder if you don't have any other Kalimba programs)
- The Hangman desktop shortcut located on your desktop 