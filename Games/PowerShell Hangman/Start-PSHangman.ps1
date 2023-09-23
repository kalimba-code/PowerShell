#PowerShell Hangman v1.0
#Programed by Kalimba in Visual Studio Code for PowerShellv7 (Untested in other versions) 

#######################################################################
# Set the static variables outside of the game loop and start the game
#######################################################################

#Theme of the dictionary
$Theme = "The 50 States"

#The dictionary to choose word(s) from
$Dictionary = @("Alabama","Alaska","Arizona","Arkansas","California","Colorado","Connecticut","Delaware","Florida","Georgia","Hawaii","Idaho","Illinois","Indiana","Iowa","Kansas","Kentucky","Louisiana","Maine","Maryland","Massachusetts","Michigan","Minnesota","Mississippi","Missouri","Montana","Nebraska","Nevada","New Hampshire","New Jersey","New Mexico","New York","North Carolina","North Dakota","Ohio","Oklahoma","Oregon","Pennsylvania","Rhode Island","South Carolina","South Dakota","Tennessee","Texas","Utah","Vermont","Virginia","Washington","West Virginia","Wisconsin","Wyoming")

#Make an array with the alphabet for future input validation
$Alphabet = @("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z")

#Make an array with all the body parts for future incorrect messages
$BodyParts = @("head","torso","left arm","right arm","left leg","right leg")

#A function that updates the display of the hangman tree. Receives the current number of wrong guess and then finds the appropriate ASCII art to display
function Update-Display ($NumOfWrongGuesses){

    if ($NumOfWrongGuesses -eq 0){
        Write-Output -InputObject "
                '.,
                'b      *
                 '$    #.
                  @:   #:
                  *#  @):
                  :@,@):   ,.**:'
                  :@@*: ..**'  |
         '#o.    .:(@'.@*@'    
            'bq,..:,@@*'   
            ,p@q8,:@)'  
           '    '@@Pp     PowerShell
                 Y7'.     Hangman
                :@):.
               .:@:'.
             .::(@:.
        "
    }

    if ($NumOfWrongGuesses -eq 1){
        Write-Output -InputObject "
                '.,
                'b      *
                 '$    #.
                  @:   #:
                  *#  @):
                  :@,@):   ,.**:'
                  :@@*: ..**'  |
         '#o.    .:(@'.@*@'    0
            'bq,..:,@@*'   
            ,p@q8,:@)'  
           '    '@@Pp
                 Y7'.
                :@):.
               .:@:'.
             .::(@:.
        "
    }

    if ($NumOfWrongGuesses -eq 2){
        Write-Output -InputObject "
                '.,
                'b      *
                 '$    #.
                  @:   #:
                  *#  @):
                  :@,@):   ,.**:'
                  :@@*: ..**'  |
         '#o.    .:(@'.@*@'    0
            'bq,..:,@@*'       |
            ,p@q8,:@)'  
           '    '@@Pp
                 Y7'.
                :@):.
               .:@:'.
             .::(@:.
        "
    }

    if ($NumOfWrongGuesses -eq 3){
        Write-Output -InputObject "
                '.,
                'b      *
                 '$    #.
                  @:   #:
                  *#  @):
                  :@,@):   ,.**:'
                  :@@*: ..**'  |
         '#o.    .:(@'.@*@'    0
            'bq,..:,@@*'      /|
            ,p@q8,:@)'  
           '    '@@Pp
                 Y7'.
                :@):.
               .:@:'.
             .::(@:.
        "
    }

    if ($NumOfWrongGuesses -eq 4){
        Write-Output -InputObject "
                '.,
                'b      *
                 '$    #.
                  @:   #:
                  *#  @):
                  :@,@):   ,.**:'
                  :@@*: ..**'  |
         '#o.    .:(@'.@*@'    0
            'bq,..:,@@*'      /|\
            ,p@q8,:@)'  
           '    '@@Pp
                 Y7'.
                :@):.
               .:@:'.
             .::(@:.
        "
    }

    if ($NumOfWrongGuesses -eq 5){
        Write-Output -InputObject "
                '.,
                'b      *
                 '$    #.
                  @:   #:
                  *#  @):
                  :@,@):   ,.**:'
                  :@@*: ..**'  |
         '#o.    .:(@'.@*@'    0
            'bq,..:,@@*'      /|\
            ,p@q8,:@)'        /
           '    '@@Pp
                 Y7'.
                :@):.
               .:@:'.
             .::(@:.
        "
    }

    if ($NumOfWrongGuesses -eq 6){
        Write-Output -InputObject "
                '.,
                'b      *
                 '$    #.
                  @:   #:
                  *#  @):
                  :@,@):   ,.**:'
                  :@@*: ..**'  |
         '#o.    .:(@'.@*@'    0
            'bq,..:,@@*'      /|\
            ,p@q8,:@)'        / \
           '    '@@Pp
                 Y7'.      Wasted
                :@):.      You Died
               .:@:'.      Game Over
             .::(@:.
        "
    }
}

#Clear out all pre-existing text
Clear-Host

#Set the game to start
$End = $false

#ASCII art credit and programming credit
Write-Host "ASCII Art is by Sam Blumenstein, retrieved from Christopher Johnson's Art Collection (https://asciiart.website)"
Write-Host "Game programed by Kalimba"


################################################################
# Reset the variables for a new game and initiate the first load
################################################################

#Start the loop, a break statement will be used to escape
while ($True)
{
    #Reset the Win condition
    $Win = $false

    #Reset the number of wrong guesses
    $NumOfWrongGuesses = 0

    #Reset the string that keeps track of the wrong letters guessed
    $WrongLetters = $null
    
    #Reset the counters used to create the $GuessDisplayArray and $LettersArray
    $Count = 0
    $WordCount = 0

    #Reset all the arrays
    $GuessDisplayArray = $null
    $LettersArray = $null
    $WordsArray = $null
    $areEqual = $null

    #Create an array to store wrong guesses
    $WrongArray = @($null) * 6

    #Get a random word(s) from the dictionary
    $RandomWord = $Dictionary | Get-Random

    #If there are multiple words, split them at the spaces
    $Words = $RandomWord -split " "

    #Converts the split up words to a char array
    $WordsArray = $Words.ToCharArray()

    # Builds two strings that will be arrays. The foreach goes through each word(s), and finds the length. Then runs through a while loop and stores a "_" where a letter should 
    # be in the $GuessDisplayArray and a letter from the $WordsArray in the $LettersArray. Spaces are added in between letters and a double space is added inbetween words. 
    foreach ($Word in $Words)
    {
        while ($Word.Length -ne $Count){
            $GuessDisplayArray += "_"
            $GuessDisplayArray += " "
            $LettersArray += $WordsArray[$WordCount]
            $LettersArray += " "
            $Count++
            $WordCount++
        }
        $GuessDisplayArray += "  "
        $LettersArray += "  "
        $Count = 0
    }
    
    #Display the ASCII Art
    Update-Display ($NumOfWrongGuesses)

    #Display the theme
    Write-Host "Theme: $Theme" -ForegroundColor Yellow
    
    #Display the wrong guesses on first load to keep everything uniform
    Write-Host "Wrong Guesses: $WrongLetters" -ForegroundColor Magenta

    #Show the player how many letters are in the word(s)
    Write-Output $GuessDisplayArray

    #Trim the array to remove the extra blank spaces
    $GuessDisplayArray = $GuessDisplayArray.TrimEnd(" ")
    #Split up the string into a string array at the spaces, keeping the spaces in the array
    $GuessDisplayArray = @($GuessDisplayArray -split "( )")
    
    #Trim the array to remove the extra blank spaces
    $LettersArray = $LettersArray.TrimEnd(" ")
    #Split up the string into a string array at the spaces, keeping the spaces in the array
    $LettersArray = @($LettersArray -split "( )")

    ######################
    # The Game Loop
    ######################

    #Start the loop, a break statement will be used to escape
    While ($True)
    {
        #Get the input and filter it. A break statement will be used to escape
        while ($true)
        {
            #Assume the guess is invalid
            $Valid = $false

            #Prompt the player for a guess
            $Guess = Read-Host -Prompt "Guess a letter!"

            #Check if the guess is a single letter in the alphabet
            foreach ($Letter in $Alphabet)
            {
                if ($Guess -eq $Letter)
                {
                    $Valid = $true
                }
            }

            #If the guess is not a single letter of the alphabet, notify the user
            if ($Valid -eq $False)
            {
                Write-Host "Please enter a single letter of the alphabet" -ForegroundColor Cyan
            }

            #Check if the letter to see if its a previous incorrectly guessed letter
            if ($Valid -eq $true) {
                foreach ($IncorrectLetter in $WrongArray)
                {
                    if ($Guess -eq $IncorrectLetter)
                    {
                        Write-Host "This letter has already been guessed" -ForegroundColor Cyan
                        $Valid = $false
                    }
                }
            }

            #Check if the letter is a previous correctly guessed letter
            if ($Valid -eq $true) {
                foreach ($CorrectLetter in $GuessDisplayArray)
                {
                    if ($Guess -eq $CorrectLetter -and $Valid -eq $true)
                    {
                        Write-Host "This letter has already been guessed" -ForegroundColor Cyan
                        $Valid = $false
                    }
                }
            }

            #Break out of the input loop if the guess passes all validation
            if ($Valid -eq $true) {
                break
            }
        }

        #Assume the guessed letter is incorrect
        $LetterCorrect = $false

        #Set the check guess array number to 0
        $i = 0

        #Test the guessed letter against each letter in the word array
        foreach ($Char in $LettersArray)
        {
            if ($Char -eq " ")
            {
                #Do nothing
            }
            else {
                if ($Guess -eq $Char)
                {
                    $GuessDisplayArray[$i] = $Guess
                    $LetterCorrect = $true
                }
            }
            $i++
        }

        #Test if there was any correct guesses
        if ($LetterCorrect -eq $false){

            #Store the incorrect letter in array
            $WrongArray[$NumOfWrongGuesses] = $Guess

            #Add the wrong letter to the wrong letter display string
            $WrongLetters += $Guess
            $WrongLetters += ","

            #Increment number of wrong guess
            $NumOfWrongGuesses++

        }

        #Clear the current display
        Clear-Host

        #Update the display with current number of wrong guesses
        Update-Display ($NumOfWrongGuesses)

        #Give the player a message stating which body part was added
        if ($LetterCorrect -eq $false) {
            Write-Host "Incorrect Answer, you got a $($BodyParts[$NumOfWrongGuesses - 1])" -ForegroundColor Red
        }

        #Show the player all the wrong letters
        Write-Host "Wrong Guesses: $WrongLetters" -ForegroundColor Magenta

        #Convert the $GuessDisplayArray into a string
        foreach ($Char in $GuessDisplayArray)
        {
            $GuessDisplay += $Char
        }

        #Display the current guess display
        Write-Host $GuessDisplay
        #Reset the display
        $GuessDisplay = $null

        #Convert all letters in the two arrays to uppercase and then compare them and store the results
        $areEqual = Compare-Object $GuessDisplayArray.ToUpper() $LettersArray.ToUpper()

        #Test if the guess array matches the letter array by measuring the length of the $areEqual array
        if ($areEqual.Length -eq 0)
        {
            #Exit the loop with a win
            $Win = $true
            break
        }

        if ($NumOfWrongGuesses -eq 6)
        {
            #Exit the loop
            break
        }
    }

    ############################################################################
    # Determine if the game was won or lost and if a new game should be started
    ############################################################################

    #Test if the game has been won or lost
    if ($Win -eq $True)
    {
        Write-Host "You Win!" -ForegroundColor Green
    }
    else {
        Write-Host "You Lose! The word was $Word" -ForegroundColor Red
    }

    #Prompt the user if they want to play another game and validate it with a loop
    while ($true)
    {
        #Assume the answer is invalid
        $Valid = $false

        #Prompt the player
        $Continue = Read-Host -Prompt "Do you want to play another game? Y/N"

        #Check if the guess is a single letter in the alphabet
        if ($Continue -eq "y")
        {
            $Valid = $true
        }
        if ($Continue -eq "n") {
            $Valid = $true
        }

        #Tell the player if the output is invalid
        if ($Valid -eq $false){
            Write-Host "Please enter Y or N" -ForegroundColor Cyan
        }
        else {
            #Break out of the input loop if the answer is correct
            break
        }
    }

    #Decide what to do with the anwser
    switch ($Continue) {
        Y {Clear-Host}
        N {"Thanks for playing!"; $End = $true}
    }

    #End the game
    if ($End -eq $true)
    {
        break
    }
}