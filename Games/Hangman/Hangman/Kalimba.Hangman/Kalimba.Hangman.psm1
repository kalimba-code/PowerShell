# PowerShell Hangman v2.0
# Programed by Kalimba in Visual Studio Code for PowerShellv5 and up
# Works in Windows 10 and Windows 11

<#
    .SYNOPSIS
    Starts a game of Hangman. Programmed by Kalimba, version 2.0

    .DESCRIPTION
    Starts a game of Hangman. ASCII art for the display is retrieved from a TXT file located at *\Documents\Kalimba\HangmanAssets\SpriteSheet.txt
    The lexicons (collection of themed words) for the game are located at *\Documents\Kalimba\Hangman\Lexicon.
#>

function Start-Hangman {

    <################## 
      Set folder paths
    ###################>

    # Test if the user is syncing to OneDrive or not and set the path to the program folder (Titled "Kalimba") appropriately
    if (Test-Path -Path "$($HOME)\*\Documents") { 
        $KalimbaFolder = Get-ItemProperty -Path "$($HOME)\*\Documents\Kalimba" | Select-Object -ExpandProperty FullName 
    } else {
        $KalimbaFolder = "$($HOME)\Documents\Kalimba" 
    }

    # Set the path to the folder containing the lexicons
    $LexiconFolder = "$KalimbaFolder\Hangman\Lexicons"

    # Create the Kalimba folder if it isn't already
    if ((Test-Path -Path $KalimbaFolder) -eq $false) {
        New-Item -ItemType Directory -Path $KalimbaFolder
    }

    # Create the Lexicon folder if it isn't already
    if ((Test-Path -Path $LexiconFolder) -eq $false) {
        New-Item -ItemType Directory -Path $LexiconFolder
    }

    <######################################
      Set variables and check for lexicons
    #######################################>    

    # Get the sprite sheet. UTF8 encoding is needed for the block characters
    $SpriteSheet = Get-Content -Path "$KalimbaFolder\Hangman\Assets\SpriteSheet.txt" -Encoding utf8
    # Split the sprite sheet into seperate sprites. We use -join to convert the array into a single string and then split it up on the ampersand
    $SlicedSprites = ($SpriteSheet -join "`n").Split("&")

    # Make an array with the alphabet for future input validation
    $Alphabet = @("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z")
    # Make an array with all the body parts for future incorrect messages
    $BodyParts = @("head","torso","left arm","right arm","left leg","right leg")  

    # Get all the lexicons(.txt files) in the Lexicon folder that aren't empty
    $AllLexicons = Get-ChildItem -Path $LexiconFolder | Where-Object {$_.Extension -eq ".txt"} | Where-Object {$_.Length -gt 0}

    Clear-Host

    # Check if there are no lexicons, if there aren't, tell the player and exit the program
    if ($null -eq $AllLexicons) {
        Write-Host $SlicedSprites[10]
        Write-Host "No themed lexicons found. Please put a comma-separated .txt file full of words in the `nLexicons folder at Documents\Kalimba\Hangman\Lexicons`nThe name of the file will be used as the theme." -ForegroundColor Red
        break
    }

    <####################################
      Declare and call the menu function
    #####################################>

    function Enter-Menu  {

        Clear-Host

        # Display the menu, tell the player where to put more lexicons, and prompt them to select a theme
        Write-Host $SlicedSprites[1]
        Write-Host "Place your comma-seperated .txt file full of words at `nDocuments\Kalimba\Hangman\Lexicons and it will show up below."
        Write-Host " "
        Write-Host "Select a theme!`n"
        Write-Host "`t0. Random"
    
        # Set the menu counter at 1, because 0 is always random
        $MenuCounter = 1
        # Set the menu color to cyan, because the random option is already white
        $MenuColor = "Cyan"
    
        foreach ($Lexicon in $AllLexicons) {
            # Grab all the content in each lexicon, join everything together into a string, then split into an array on the comma
            $LexiconArray = ((Get-Content -Path "$($Lexicon.FullName)") -join "").Trim(",").Split(",")
            # Display the number, the lexicon's name, and the amount of words in the lexicon
            Write-Host "`t$MenuCounter. $($Lexicon.BaseName) ($($LexiconArray.Count) Words)" -ForegroundColor $MenuColor
            $MenuCounter++
            # Alternate the color for the next entry in the list of lexicons
            if ($MenuColor -eq "White") {
                $MenuColor = "Cyan"
            } else {
                $MenuColor = "White"
            }
        }
    
        # Add a blank line for formatting
        Write-Host " "

        # Count the number of lexicons, this number will be used as the max number the player can choose
        $NumOfLexicons = $AllLexicons.Count
    
        while ($true) {
            # Assume the answer is invalid
            $ValidGuessNum = $False
    
            # Prompt the user for a number
            $Num = Read-Host "Choose the corresponding number"
    
            # Check if the number is a valid selection
            if ($Num -le $NumOfLexicons) {
                $ValidGuessNum = $true
            }
    
            # Let the user know if the num is invalid
            if ($ValidGuessNum -eq $False) {
                Write-Host "Please enter a single number between 0 and $NumOfLexicons" -ForegroundColor Cyan
            }
    
            # Break out of the loop if the input is valid
            if ($ValidGuessNum -eq $true) {
                # If Random is selected, get a random lexicons
                if ($Num -eq 0) {
                    $SelectedLexicon = $AllLexicons | Get-Random
                } else {
                    # Otherwise, grab the selected lexicon and subtract one because arrays
                    $SelectedLexicon = ($AllLexicons[($Num -1)])
                }
                break
            }
        }

        Clear-Host

        # Return the selected lexicon
        $SelectedLexicon
    }    

    # Prompt the player to select a lexicon and store it. 
    # This is called once at the beginning, the player will have the option to call the menu again at the end of the game
    $Lexicon = Enter-Menu

    <############################################
      Start the game and set/reset the variables
    #############################################>

    # Start the game engine loop
    while ($True) {
        # Keeps track if the game was won or lost
        $Win = $false
        # Used to exit the game
        $Break = $false

        # Set the number of wrong guesses
        $NumOfWrongGuesses = 0
        # Set the sprite number. It is set to 2 because 0 is the description in the spritesheet and 1 is the menu screen.
        $SpriteNum = 2

        # Reset the string that keeps track of the wrong letters guessed
        $WrongGuessDisplay = $null
        # Reset the string that is used to display the word when you win
        $WinDisplay = $null
    
        # Reset the counter used to keep track of the total number of characters in the entry
        $TotalCharCounter = 0
        # Reset the counter used keep track of the number of characters in the word
        $WordCharCounter = 0

        # Reset all the arrays
        $GuessArray = $null
        $CorrectArray = $null
        $CharArray = $null
        $areEqual = $null

        # Create an array to store wrong guesses
        $WrongArray = @($null) * 6

        # Get all the words from the lexicon. Join all the words together, trim the trailing commas, then split on the comma to properly format the array
        $LexiconContent = ((Get-Content -Path "$($Lexicon.FullName)") -join "").Trim(",").Split(",")

        # Grab the name of the lexicon, which is used to display the theme of the lexicon
        $Theme = $Lexicon.BaseName

        # Get a random entry from the lexicon. We split on the space in case the entry is multiple words
        $RandomEntry = ($LexiconContent | Get-Random).Split(" ")

        # Converts each char in the entry into a array 
        $CharArray = $RandomEntry.ToCharArray()

        <# 
            Builds two strings that will be arrays. The foreach goes through each word(s), and finds the length of the word (how many characters there are). 
            It then runs through a while loop until all the characters are used. In each loop, it stores that loop's character in the $GuessArray and the
            $CorrectArray. If that character is a specified special character, it is added to both the $GuessArray and $CorrectArray as is. If the character 
            is a letter, a "_" is stored where that letter should be in the $GuessArray and the letter in the $CorrectArray. Spaces are added in between letters 
            and a double space is added inbetween words. 
        #>
        foreach ($Word in $RandomEntry) {
            while ($Word.Length -ne $WordCharCounter) {
                # Store this loop's character
                $Char = $CharArray[$TotalCharCounter]
                if ($Char -eq "'") {
                    # Remove the space that was added on the last letter for formatting
                    $GuessArray = $GuessArray.TrimEnd(" ")
                    $CorrectArray = $CorrectArray.TrimEnd(" ")
                    $GuessArray += $Char
                    $CorrectArray += $Char
                } else {
                    $GuessArray += "_"
                    $GuessArray += " "
                    $CorrectArray += $Char
                    $CorrectArray += " "
                }
                $TotalCharCounter++
                $WordCharCounter++
            }
            $GuessArray += "  "
            $CorrectArray += "  "
            # Reset the char counter for the next word
            $WordCharCounter = 0
        }
    
        # Display the ASCII Art depending on which body part we are on
        Write-Host $SlicedSprites[$SpriteNum]
        # Display the theme
        Write-Host "Theme: $Theme" -ForegroundColor Yellow 

        # Display the wrong guesses on first load to keep everything uniform
        Write-Host "Wrong Guesses: $WrongGuessDisplay" -ForegroundColor Magenta
        # Show the player how many letters and special characters are in the word(s)
        Write-Output $GuessArray

        # Trim the strings to remove the extra blank spaces
        $GuessArray = $GuessArray.TrimEnd(" ")
        $CorrectArray = $CorrectArray.TrimEnd(" ")
        # Split up the strings into an actual array
        $GuessArray = @($GuessArray -split "")
        $CorrectArray = @($CorrectArray -split "")

        <###############
          The game loop 
        ################>

        # Start the game loop
        While ($True) {
            # Start the loop that gets input from the user
            while ($True) {

                # Reset the variable to true. If the guessed word is correct, the game ends, so this variable is used to keep track of the wrong guesses
                $WordCorrect = $True

                # Reset the variable checking if the guess is valid
                $ValidGuess = $false

                $Guess = Read-Host -Prompt "Guess a letter or the word!"
                    
                # Check if the guess is longer then one character. If it is, then the player is guessing a word. If it isn't, then the player is guessing a letter
                if ($Guess.Length -gt 1) {
                    $Letter = $false
                } else {
                    $Letter = $True
                }

                if ($Letter) {
                    # Check if the guess is a single letter in the alphabet
                    foreach ($Letter in $Alphabet) {
                        if ($Guess -eq $Letter) {
                            $ValidGuess = $true
                        }
                    }
                    
                    # If the guess is not a single letter of the alphabet, notify the user
                    if ($ValidGuess -eq $False) {
                        Write-Host "Please enter a single letter of the alphabet" -ForegroundColor Cyan
                    }
                    
                    # Check if the letter to see if its a previous incorrectly guessed letter
                    if ($ValidGuess -eq $true) {
                        foreach ($Letter in $WrongArray) {
                            if ($Guess -eq $Letter) {
                                Write-Host "This letter has already been guessed" -ForegroundColor Cyan
                                $ValidGuess = $false
                            }
                        }
                    }
                    
                    # Check if the letter is a previous correctly guessed letter, and if it is, tell the player and break to avoid duplicate messages
                    if ($ValidGuess -eq $true) {
                        foreach ($CorrectLetter in $GuessArray) {
                            if ($Guess -eq $CorrectLetter) {
                                    Write-Host "This letter has already been guessed" -ForegroundColor Cyan
                                    $ValidGuess = $false
                                    break
                            }
                        }
                    }
                    
                    # If the guess is valid, check if it's correct
                    if ($ValidGuess -eq $true) {
                        # Assume the guessed letter is incorrect
                        $LetterCorrect = $false
                        # Reset the array counter. This is used to increment the $GuessArray so if the guess is correct its put in the right spot
                        $ArrayCounter = 0

                        # Test the guessed letter against each letter in the word array
                        foreach ($Char in $CorrectArray) {
                            if ($Char -eq " ") {
                                # Do nothing
                            }
                            else {
                                if ($Guess -eq $Char) {
                                    # Add the correctly guessed letter to the $GuessArray
                                    $GuessArray[$ArrayCounter] = $Guess
                                    $LetterCorrect = $true
                                }
                            }
                            $ArrayCounter++
                        }
                        # Break out of the input loop
                        break
                    }
                }
                # If its not a letter, then its a word(s) 
                else {
                    while ($true) {
            
                        # Prompt the user to lock in their guess, in case it was a mistype
                        $Confirmation = Read-Host -Prompt "Are you sure you want to guess $($Guess)? y/n"
                                
                        # Check if the guess is valid
                        if ($Confirmation -eq "y" -or $Confirmation -eq "n") {
                            $ValidGuess = $true
                        }
                    
                        # Tell the player if the output is invalid
                        if ($ValidGuess -eq $false) {
                            Write-Host "Please enter y or n" -ForegroundColor Red
                        }
                        else {
                            # Break out of the input loop if the answer is correct
                            break
                        }
                    }

                    if ($Confirmation -eq "y") {
                        # Check if the guess is the same as the entry
                        if ($Guess -eq $RandomEntry) {
                            $Win = $True
                        } 
                        else {
                            $WordCorrect = $false
                        }
                        break
                    }
                }
            }

            # Check if the word was guess correctly
            if ($Win -eq $True) {
                # If it is, break out of the game loop
                break
            }

            # Test if there was any correct guesses
            if ($LetterCorrect -eq $false -or $WordCorrect -eq $false) {
                # Store the incorrect letter in the $WrongArray
                $WrongArray[$NumOfWrongGuesses] = $Guess
            
                # Add the wrong letter to the wrong letter display string
                $WrongGuessDisplay += $Guess
                $WrongGuessDisplay += ","
            
                # Increment number of wrong guess
                $NumOfWrongGuesses++
                # Increment the sprite counter so the correct body part sprite is shown
                $SpriteNum++
            }

            Clear-Host

            # Update the display with current body part sprite
            Write-Host $SlicedSprites[$SpriteNum]

            # Display the theme
            Write-Host "Theme: $Theme" -ForegroundColor Yellow

            # Show the player all the wrong letters
            Write-Host "Wrong Guesses: $WrongGuessDisplay" -ForegroundColor Magenta

            # Give the player a message stating which body part was added if there was incorrect guess
            if ($LetterCorrect -eq $false -or $WordCorrect -eq $false) {
                Write-Host "Incorrect Answer, you got a $($BodyParts[$NumOfWrongGuesses - 1])" -ForegroundColor Red
            }

            # Convert the $GuessArray into a string
            foreach ($Char in $GuessArray) {
                $GuessDisplay += $Char
            }

            # Display the current guess display
            Write-Host $GuessDisplay

            # Reset the display
            $GuessDisplay = $null

            # Convert all letters in the two arrays to uppercase and then compare them and store the results. 
            $areEqual = Compare-Object $GuessArray.ToUpper() $CorrectArray.ToUpper()

            # Test if the guess array matches the letter array by measuring the length of the $areEqual array
            if ($areEqual.Length -eq 0) {
                # Set the win to true and exit the loop
                $Win = $true
                break
            }

            # Check if the there are too many wrong guesses
            if ($NumOfWrongGuesses -eq 6) {
                # If so, exit the loop
                break
            }
        }

        <###########################################################################
          Determine if the game was won or lost and if a new game should be started
        ############################################################################>

        # Test if the game has been won or lost
        if ($Win -eq $True) {
            Clear-Host
            # Display the win screen
            Write-Host $SlicedSprites[9]
            # Write the theme to keep with conformity
            Write-Host "Theme: $Theme" -ForegroundColor Yellow
            # Display the wrong guess to keep with conformity
            Write-Host "Wrong Guesses: $WrongGuessDisplay" -ForegroundColor Magenta

            # Reset the counter used to keep track of which character to grab from the $CorrectArray
            $CharCounter = 0

            # Build a string using the $CorrectArray to make a correctly formatted display
            foreach ($Char in $CorrectArray) {
                $WinDisplay += $CorrectArray[$CharCounter]
                $CharCounter++
            }
            Write-Host $WinDisplay
            # Notify the player they won
            Write-Host "You Win!" -ForegroundColor Green
            # Look for the Shell.Watch module. If its found, grab the Update-ShellWatch function and tell it to update the save data with a win
            if (Get-Module -ListAvailable Shell.Watch) {
                Update-ShellWatch -PlayerOutcome "Win"
            }
        }
        else {
            # Notify the player they lost and show them the entry
            Write-Host "You Lose! The word was $RandomEntry" -ForegroundColor Red
            # Look for the Shell.Watch module. If its found, grab the Update-ShellWatch function and tell it to update the save data with a loss
            if (Get-Module -ListAvailable Shell.Watch) {
                Update-ShellWatch -PlayerOutcome "Loss"
            }
        }

        while ($true) {
            # Assume the answer is invalid
            $ValidAnswer = $false
        
            # Prompt the player
            $Answer = Read-Host -Prompt "Enter y to play again, m to return to the menu, and x to exit"
        
            # Check if the guess is a valid answer
            if ($Answer -eq "y" -or $Answer -eq "m" -or $Answer -eq "x") {
                $ValidAnswer = $true
            }
        
            # Tell the player if the answer is invalid
            if ($ValidAnswer -eq $false) {
                Write-Host "Please enter y, m, or x" -ForegroundColor Cyan
            }
            else {
                # Break out of the input loop if the answer is correct
                break
            }
        }

        # Clear the host if y, call the menu to get a new lexicon if m, and thank the player and break if x
        switch ($Answer) {
            y {Clear-Host}
            m {$Lexicon = Enter-Menu}
            x {
                Write-Host "Thanks for playing!" -ForegroundColor Cyan
                $Break = $True
            }
        }

        if ($Break -eq $True) {
            break
        }
    } # End of the game loop
} # End of function