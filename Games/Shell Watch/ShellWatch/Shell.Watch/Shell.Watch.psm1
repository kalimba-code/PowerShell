# Shell Watch v1.00
# Programmed by Kalimba

<#
 .Synopsis
  Runs a Tamagotchi-like program in the PowerShell Window.

 .Description
  Runs a Tamagotchi-like program in the PowerShell Window. Integrates with folders and other scripts to purchase items, 
  play games, and start the game

 .Parameter NewGame
  A switch parameter, if specified the save file is cleared.

 .Parameter PetDeath
  A On/Off toggle, Off by default. If toggled on, the pet won't die.

 .Example
  # Starts the Program
  Start-ShellWatch
#>

function Start-ShellWatch {

    Param (
        # If selected, the save file is cleared
        [switch]$NewGame,
        
        # Toggles whether or not the pet dies when Hunger reaches 0
        [ValidateSet("On","Off")]
        [string[]]$PetDeath
    )

    function Show-Animation {

        Param (
            # A number that corresponds with a animation in the sprite sheet. A index of animations can be found in the SpriteSheet.txt
            [int]$AnimeNum, 
            # The number of seconds to pause after displaying a frame
            [int]$Delay, 

            # Optional, contains the message that the pet should read. A 2 frame reading (mouth open/mouth closed) animation needs to be used to work
            [string]$Message
        )
    
        # Grabs the animation group specified and split up the frames on the percentage sign
        $Animation = ($SlicedSprites[$AnimeNum]).Split("%")

        if ($Message) { 

            # Remove all the spaces from the message and make it a array
            $Words = $Message.Split(" ")

            # Used to toggle between the open mouth frame and the closed mouth frame
            $FlipFlop = 0
            # Used to increment the $Words array 
            $WordCounter = 0
            # Used to count the number of lines that are displayed
            $LineCounter = 0
            # Contains the maximum amount of characters that can be displayed with out leaving the window width.
            # If you need to change the width of the window for your pet, this value needs to match the new width
            $CharacterLimit = 89
            # Contains the maximum amount of lines that can be displayed with out pushing the pet out of the window
            # This could be different for your pet depending on the pet size and window size
            $LineLimit = 7
            # Contains the amount of seconds need to read the entire message displayed. 
            # Adjust this to be higher or lower as needed
            $ReadTime = 10

            while ($True) {
                Clear-Host
                Write-Host $Animation[$FlipFlop]

                # Start a loop to determine how many words are on a line of text
                while ($True) {
                    # Test if adding a new word to the currrent line would make the character length greater then the character limit
                    if (($WordsPerLine + $Words[$WordCounter]).Length -gt $CharacterLimit) {
                        # If it does, we don't add the word and instead add a line break and then exit the loop
                        $WordsPerLine += "`n"
                        break
                    } else {
                        # If it doesn't, we add a new word with a space and increment the $WordCounter
                        $WordsPerLine += "$($Words[$WordCounter]) "
                        $WordCounter++
                    }
                }

                # Add the new line to the current paragraph
                $Paragraph += $WordsPerLine
                # Add the new line to the total read message
                $ReadMessage += $WordsPerLine

                Write-Host $Paragraph
                $LineCounter++

                if ($LineCounter -eq $LineLimit) {
                    Start-Sleep -Seconds $ReadTime
                    $Paragraph = $null
                    $LineCounter = 0
                }

                # Test if the total read message character length is greater than the original message length
                # Because of the reformatting, we always end up with more characters then the orignal, but never to many to miss displaying the full message
                if ($ReadMessage.Length -ge $Message.Length) {
                    Start-Sleep -Seconds $ReadTime
                    break
                }  

                $WordsPerLine = $null
                Start-Sleep -Seconds $Delay
                Clear-Host
                # Toggle the $FlipFlop
                if ($FlipFlop -eq 0) {
                    $FlipFlop = 1
                } else {
                    $FlipFlop = 0
                }
            }
        } 
        else {
            # Play each frame the animation
            foreach ($Frame in $Animation) {
                Clear-Host
                Write-Host $Frame
                Start-Sleep -Seconds $Delay
                Clear-Host
            }
        }
    }

    <#####################
      Setting the display 
    ######################>

    # Get the current UI
    $PSWindow = (Get-Host).UI.RawUI

    # Set the vanity title
    $PSWindow.WindowTitle = "ShellWatch v1.00 by Kalimba"

    # Set the dimensions for the PowerShell Window
    $NewSize = $PSWindow.Windowsize
    # If you pet needs a bigger window, adjust it here:
    $NewSize.Height = 25
    $NewSize.Width = 89
    $PSWindow.Windowsize = $NewSize

    # Set the buffer for the PowerShell Window
    $NewSize = $PSWindow.Buffersize
    # I believe this value needs to be one higher then your width
    $NewSize.Width = 90
    $PSWindow.Buffersize = $NewSize

    # Tidy Up
    Clear-Host

    <#####################################################
      Read the save data, sprite sheet, and load the game 
    ######################################################>

    # Test if the user is syncing to OneDrive or not and set the path to the program folder (Titled "Kalimba") appropriately
    if (Test-Path -Path "$($HOME)\*\Documents") { 
        $KalimbaFolder = Get-ItemProperty -Path "$($HOME)\*\Documents\Kalimba" | Select-Object -ExpandProperty FullName 
    } else {
        $KalimbaFolder = "$($HOME)\Documents\Kalimba" 
    }

    # Read the save data
    $Pet = Get-Content -Path "$KalimbaFolder\SaveData.json" | ConvertFrom-Json

    # Get the sprite sheet. UTF8 encoding is needed for the block characters
    $SpriteSheet = Get-Content -Path "$KalimbaFolder\Assets\SpriteSheet.txt" -Encoding utf8

    # Split the Sprite Sheet into animations groups. We use -join to convert the array into a single string and then split it up on the pound sign
    $SlicedSprites = ($SpriteSheet -join "`n").Split("#")

    # Display the logo
    Show-Animation -AnimeNum 1 -Delay 1

    # Pause between the logo and startup animation
    Start-Sleep -Seconds 0.5

    # Play the startup animation
    Show-Animation -AnimeNum 2 -Delay 1

    <######################### 
      Start the gameplay loop 
    ##########################>
    
    while ($true) {

        <###############
         Update the Hud 
        ################>        

        # Read the Wins and Losses properties from the save data
        $NewScores= Get-Content -Path "$KalimbaFolder\SaveData.json" | ConvertFrom-Json | Select-Object -Property Wins,Losses

        # Test if there has been a new win
        if ($NewScores.Wins -gt $Pet.Wins) {
            # Play a random lose animation
            Show-Animation -AnimeNum (Get-Random -Minimum 6 -Maximum 8)
            # Set the number of wins correctly
            $Pet.Wins = $NewScores.Wins
            # Increment the money
            $Pet.Money++
        }
        
        # Test if there has been a new loss
        if ($NewScores.Losses -gt $Pet.Losses) {
            # Play a random win animation
            Show-Animation -AnimeNum (Get-Random -Minimum 9 -Maximum 11)
            # Set the number of losses correctly
            $Pet.Losses = $NewScores.Losses
        }

        # A 10% chance that the pet loses a point of hunger this loop
        if ((Get-Random -Minimum 0 -Maximum 99) -le 10) {
            $Pet.Hunger--
        }
        
        # Build the Hud
        $Hud = "Hunger: $($Pet.Hunger) Money: $($Pet.Money) Wins: $($Pet.Wins) Losses: $($Pet.Losses)"

        <############# 
          Blink Cycle 
        ##############>

        # We could use the Show-Animation function with some modifications, but I feel that overcomplicates the function and this is the better way

        # Display the Hud and the default sprite from the spritesheet
        Write-Host "$Hud`n$($SlicedSprites[3])"
        # Pause for a random amount of seconds
        Start-Sleep -Seconds (Get-Random -Minimum 4 -Maximum 10)
        # Display the Hud and the blink frame
        Write-Host "$Hud`n$($SlicedSprites[4])"
        # Pause to show the blink
        Start-Sleep -Seconds 1
        # Remove the blink frame
        Clear-Host

        # Save the current Pet data to the save file
        $Pet | ConvertTo-Json -Depth 1 | Set-Content -Path "$KalimbaFolder\SaveData.json"
    }
}