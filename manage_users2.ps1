#!/usr/bin/env pwsh

Import-Module ActiveDirectory

# Variable related part--------------------------------

[array]$ItemArray
[array]$Answer = -1, -1, -1
[array]$KeyStopper = "q", "Q"

#enum PhaseType {
#    Scope
#    Target
#    Action
#}


enum ScopeType {
      Local
      AD
}

$ScopeTitle =   "---- Scope ----"
$ScopeMessage = "Pick the Scope: "

enum TargetType {
	User
	Group
	GroupMember
	Password
}

$TargetTitle =   "---- Target ----"
$TargetMessage = "Pick the Target: "

# One can't do both Get and Remove for example, so bitmasking isn't required.
# Otherwise, we could set Get as 1, Add as 2, Remove as 4

enum ActionType {
	Get
	New
	Remove
}

$ActionTitle =   "---- Action ----"
$ActionMessage = "Pick the Action: "

# Command related part--------------------------------

# switches seems annoying to use, we have enums already
# so we can return the name of the matched int in the enum
# ie:	ActionType.Get is the first value, hence it's 0
# 	ActionType.Remove is the 3rd one, hence it's 3 - 1 (list start at 0 in PS)

function Find-Action($Action){
    return [ActionType].GetEnumName($Action)
}

function Find-Scope($Scope){
    return [ScopeType].GetEnumName($Scope)
}

function Find-Target($Target){
    return [TargetType].GetEnumName($Target)
}

function Mend-Command($para){
    # so if we hand over to the function something like
    # function(1,0,0)
    # it'll pass "1 0 0" to the first parameter, not split them across
    # the matching one.
    # Hence we accept the whole thing and simply circumvent it
    # And it does do that, even as we pass them as individual variables...
    $Action = $para[0]
    $Scope = $para[1]
    $Target = $para[2]
    # Our commands are very predictable
    # They have an action verb
    # A scope (that uncommenting should simply make it work
    # A Target to apply to (within the caveat that we are doing this from a user viewpoint
    # So the Password target would be phrased as "A User's Password"
    # Member would be "Groups the user is member of"
    # Default Values ensure it won't change things by mistake
    # No Switch, because they require Break statement
    # We can't eval $Action and then $Scope in other switches as they glob
    # the first value they match (hence multiple int passed will match the
    # first statement they match within the first switch they met
    
    # No early-exit-if, as there is more than 2 possible values
    # hence bitmask could be a solution to pass around user selection
    # added complexity is a lot tho
    

    [string]$MendedCommand = ""
    $MendedCommand += (Find-Action($Action)) + "-"
    $MendedCommand += (Find-Scope($Scope))
    $MendedCommand += (Find-Target($Target))

    #Return final, invokable command (or close to)
    return $MendedCommand
}

function Command-Invoker([string]$DefinedCommand, [string]$ExtraName) {
    # Using Invoke-Command we can run the patched together command
    # We could also use a flag to send this command to one or several other machines
    # Invoke-Expression is a bit easier to get started with
    if ($Answer[0] -eq 0){ return Invoke-Expression -Command $DefinedCommand }
    return Invoke-Expression -Command $DefinedCommand -Name $ExtraName
}

# Menu related part--------------------------------

function Get-Entries([int]$Enum) {
    [array]$ItemArray 
    if ($Enum -eq 0) {
        $ItemArray = [ScopeType].GetEnumNames()
    }
    if ($Enum -eq 1) {
        $ItemArray = [TargetType].GetEnumNames()
    }
    if ($Enum -eq 2) {
        $ItemArray = [ActionType].GetEnumNames()
    }
    return $ItemArray
}

function Print-Menu([int]$i) {
	$Entries = (Get-Entries($i))
	[int]$counter = 0
	Clear-Host
	Write-Host ""
	foreach ($e in $Entries) {
	    Write-Host " [$counter] $e"
	    $KeyAnswers = [string]$counter
	    $counter += 1
	}
	Write-Host " [Q] Quit"
	Write-Host ""
}

# Body part--------------------------------



#while($KeyStopper -notcontains $KeyPressed) {
    # -1 mean we haven't set a value yet, hence we ask for it
    # order is broken: depending on the POV, we have several different
    # fields:
    #     menu-wise, Target is 0, as it's the first one
    #     Answer variable wise, Target is 2, so the last one
    #     PhaseType enum-wise, Target is 1
    # So it's a mess
    # Note that we _could_ in theory put something like
    # Print-Menu([PhaseType].Target)
    # But it simply doesn't work
Print-Menu(1)
if ($Answer[2] -eq -1){
    # Order is kind of broken, check the PhaseType enum for order within
    # Here we would require a step to ensure the answer given is part of
    # (a) the possible choices from the menu
    # (b) a digit or q
    # Since we are using enum, we can use the index directly as the enum was
    # used to set the menu up
    $s1 = Read-Host "Select Target:"
    $Answer[2] = [int]$s1 -1
}
Print-Menu(2)
if ($Answer[0] -eq -1){
    $s2 = Read-Host "Select Action:"
    $Answer[0] = [int]$s2 -1
}
# My whole way to dev this was a mess
# OTOH, I foresaw that we could swap "Local" with whatever
# e.g. AD
# So from the start, I expected it, and planned for it
Print-Menu(0)
if ($Answer[1] -eq -1){
    $s3 = Read-Host "Select Scope:"
    $Answer[1] = [int]$s3 -1
}

# The line here proves the command does get worked out
# Almost for the best
# Sadly, it seems that yet another "Let Me Help You Without Telling You" part of Powershell
# just keeps on giving and break the Print-Menu function
# For shit and giggles

Command-Invoker(Mend-Command($Answer))