#!/usr/bin/env pwsh

[int]$Phase = 0

# enum ScopeType {
#	Local
#	Remote
# }

#$ScopeTitle =   "---- Scope ----"
#$ScopeMessage = "Pick the Scope: "

enum TargetType {
	Account
	Group
	Member
	Password
}

$TargetTitle =   "---- Target ----"
$TargetMessage = "Pick the Target: "

enum ActionType {
	Get
	Add
	Remove
}

$ActionTitle =   "---- Action ----"
$ActionMessage = "Pick the Action: "

function Mend-Command {
	
}

function Display-Menu([enum]Choices, Title, Message) {
	$ItemArray = [Enum]::GetNames([Choices])
	$Options = [System.Management.Automation.Host.ChoiceDescription[]] ($ItemArray)
	$Result = $host.UI.PromptForChoice($Title, $Message, $Options, $ItemArray.Length)
}

$IsPicking = $True

while($IsPicking) {
	Display-Menu(TargetType, TargetTitle, TargetMessage)
	# get values
	# store them
	# pass them around as bitmask? return values?
}
