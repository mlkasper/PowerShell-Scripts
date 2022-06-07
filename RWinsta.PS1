<#
    Author: Michael Kasper
    Date Created: 6/6/22
    Last Modified: 6/7/22
    Purpose: An IT Technician can enter a username to kill a users session. 
#>

$RDServers = @('', '', '', '') #PUT YOUR SERVERS HERE, Change Line 43 to how many servers you use
$UsernameInput = Read-Host "Please enter a username "
$Flag = "F"
$Counter = 0
$SessionID
function Get-RDPSessions($Username) { 
    #While $Flag is false (i.e. user not found) execute this loop
    while ( $Flag -eq "F" ) {
        $serverName = $RDServers[$Counter] #assign array at position $counter to $serverName
        Write-Host -NoNewLine -ForegroundColor Green 'Querying server' $serverName `n
        $result = query user $Username /server:$serverName | Select-Object -skip 1 | ForEach-Object { #$result stores the session ID
            $_.SubString(41,5).Trim()
        }
        try { #Try to convert String to Int
            $sessionID = [int]$result
            Write-Host 'SessionID: ' $sessionID
        } catch { 
            Write-Host -ForegroundColor Red 'An error has occured while trying to convert $result to an int value.'
        }
        if($sessionID -is [int] -and $sessionID -ne 0 -and $sesionID -ne 1) { #check if int and if our session id is not 0 or 1 continue
            $Flag = "T"
            Write-Host -ForegroundColor Green 'User has been found on ' $RDServers[$Counter] 'with session ID: ' $sessionID `n
            $TerminateConfirmation = Read-Host "Would you like to terminate " $Username "'s session? (y\n)"
            if( ($TerminateConfirmation -eq 'y') -or ($TerminateConfirmation -eq 'Y') -or ($TerminateConfirmation -eq 'Yes') ) { 
                try { #try to terminate remote session
                    rwinsta.exe /server:$serverName $sessionID /V
                } catch {
                    Write-Host -ForegroundColor Red 'An error has occured while trying to terminate the users session.'
                }
            } else {
                cmd /c pause
            }
            
        }
        $Counter++
        if($counter -ge 4) { #Change #4 to how many servers are in the RDServers array. 
            $Flag = "T"
             Write-Host -ForegroundColor DarkRed 'User specified is not currently logged in to a remote session.'
        }
        
    }
    cmd /c pause
}

Get-RDPSessions($UsernameInput)