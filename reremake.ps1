# Let's rewrite it again, and suffer more from it.


Import-Module ActiveDirectory

# enum hold the data in a nice, compact, self labeled way.
enum ViewType {
    Action  # 0
    Scope   # 1
    Target  # 2
    Options # 3
}

enum ActionType {
    Get
    New
    Remove
}

enum ScopeType {
    Local
    AD
}

enum TargetType {
    User
    Group
    GroupMember
    Password
}

# Will let us navigate as things 
[array]$KeyAnswers

# Will force bail out to quit
[array]$KeyHalter = "q", "Q"

# Help function
function Find-Action($Action) {
    return [ActionType].GetEnumName($Action)
}

function Find-Scope($Scope) {
    return [ScopeType].GetEnumName($Scope)
}

function Find-Target($Target) {
    return [TargetType].GetEnumName($Target)
}



function Make-Menu() {
    Clear-Host
    Write-Host "---"
    
    [array]$menuEntries = [ViewType].GetEnumNames()
    [int]$cnt = 0
    foreach($e in $menuEntries){
        if ($cnt -eq 0) { continue }
        Write-Host "[$cnt] $e"
        $KeyAnswers += [string]$cnt
        $cnt += 1
    }
    
    Write-Host "---"
}
