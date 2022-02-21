#!/usr/bin/env pwsh

# Disclaimer:
# $options=[System.Management.Automation.Host.ChoiceDescription[]] @(yada)
# $defaultChoice=1
# $opt=$host.UI.PromptForChoice($Title, $Info, $Options, $defaultChoice)
# Would yield the same Powershell-way prompt akin to the one Microsoft put together when PowerShell
# ask for user input (excluding filters), like it does when we use Set-ExecutionPolicy "Bypass"
# like this:
# [O] Oui [T] Oui pour tout [N] Non [U] Non pour tout [S] Suspendre [?] Aide (la valeur par défaut est « N ») :
# But this is a one-line, only first-letter prompt

# We could use a switch statement. We could.
# But doing so would prevent us from the whole Arrays into an Array
# into dynamically populate the entries the user can do
# Since my C# programming days, I've not brought a Windows machine to its knees
# This whole thing may just be a gimmick, no question,
# but since I've never did that, why wouldn't I do just that?

# Store all possible values, will eval later input against it.
# An array in an array is a table, hence "line" is a line of the table,
# "entry" is a string in that line
# Example: $PossibleChoices[0][3] => "LocalMember" of the line starting with "Manage Users:"
$PossibleChoices = @(@("Manage Users:","LocalAccount","LocalGroup","LocalMember","LocalPassword","Quit"),
		@("Local Account:", "Get", "Add", "Remove", "Quit"),
		@("Local Group:", "Get", "Add", "Remove", "Quit"),
		@("Local Member:", "Get", "Add", "Remove", "Quit"),
		@("Local User Status:", "Get", "Add", "Remove", "Quit"),
		@("Local Password:", "Get", "Add", "Remove", "Quit"))

# Bookkeep the current menu and stuff
[int]$CurrentLine = 3

# Possible answers for a given menu.
# Imply dynamically adding the entries and matching it.
# Could be absolutely spastic.
[array]$KeyAnswers = "q", "Q"
[string]$CurrentInvoke = ""

# We want to construct dynamically the commands to pass later on
# enum could be a good way to have a one-position-only parameter
# then we slap it into a variable and pass it in the scriptblock
enum CommandType {
	account
	group
	member
	status
	password
}

enum ActionType {
	get
	add
	remove
}

# Going whack: Here we dynamically crawl the arrays in the array to make entries
# As the entries are done, we capture the First letter of each value and add it to the KeyAnswers
# Or we will add the Index of the Answer
# Best case would be appending both
function Display-Menu([string]$line) {
	# Write first entry of the array as a title, then loop it
	Write-Host $PossibleChoices[$line][0]
	[int]$count = 1
	foreach ($e in $PossibleChoices[$line]) {
		if ($e -eq $PossibleChoices[$line][0]){
			continue
		} else {
			if ($e -eq "Quit") {
				Write-Host "[Q] $e"
				continue
			}
			Write-Host "[$count] $e"
			# Using and abusing casting because .ToString() is more character
			$KeyAnswers += [string]$count
		}
		$count += 1
	}
}

function Build-Command([string]$line, [string]$KeyPressed) {
	
}

# About here is our "main" function

Display-Menu($CurrentLine)

while ($KeyAnswers -notcontains $KeyPressed) {
	Write-Host ""
	[string]$KeyPressed = Read-Host "Enter the index, or [q] to quit: "
	if ($KeyPressed -eq "") {
		# Specific case of no input, as we could simply use a function here
		# to loop and prompt the user again or we could make it select a default value
		# Here, we basically do that, but in an absolutely not elaborated way, a better thing
		# would be to have a ternary operator as $KeyPressed and return "q" if $KeyPressed is empty
		echo "Exiting"
		break
	}
	if (($KeyPressed -ne "q") -xor ($KeyPressed -ne "Q")) {
		echo "Requesting $KeyPressed"
		Build-Command($line, $KeyPressed)
	} else {
		# Means Q, mandatory, as "" -empty string- and not "Q" are handled above
		echo "Exiting"
	}
}
