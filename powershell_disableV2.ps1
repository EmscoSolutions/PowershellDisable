#   <Powershell Disable V2.0 - This script can be used to disable remote powershell for clients either by user or by group>
#   Copyright (C) <2019>  <Billy Rigdon>
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <https://www.gnu.org/licenses/>.



#########                                README
#########   For this to work, you will need the following:
#########              User's name or Group's Name
#########              365 Administrative access
#########              MFA must be turned off in order to administer a Delegated partner
#########              The Delegated Partner FQDN if managing by domain
#########
#########   Any questions or errors can be reported to billy@emscosolutions.com
#########


#Establish connection to Exchange Online for a Delegated Partner Client
##############Needs MFA turned off to work###############
##############Needs Further Testing######################
function EstablishConnectionDelegated {
  $UserLogonCredential = Get-Credential
  $DelegatedDomain = Read-Host -Prompt 'Enter in the domain that you would like to administer'
  $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell-liveid?DelegatedOrg=$DelegatedDomain -Credential $UserLogonCredential -Authentication Basic -AllowRedirection
  Import-PSSession $Session
}

#Establish connection to Exchange Online
function EstablishConnection {
  $UserLogonCredential = Get-Credential
  $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserLogonCredential -Authentication Basic -AllowRedirection
  Import-PSSession $Session -DisableNameChecking
}

#by specificuser or by group?
function DisablePowershell {
  $userorgroup = Read-Host -Prompt 'Enter a 1 to disable powershell for a specific user or 2 for a group'
  if ($userorgroup -eq 1) {
    $username = Read-Host -Prompt 'Input username'
    Set-User $username -RemotePowerShellEnabled $false
  } ElseIf ($userorgroup -eq 2) {
    $groupname = Read-Host -Prompt 'Input name of Group'
    Get-UnifiedGroupLinks -Identity $groupname -LinkType Members | Set-User -RemotePowerShellEnabled $false
  } Else {
    'Invalid Response'
  }
}

#Disconnects Session once finished running
function DisconnectSession {
  Remove-PSSession $Session
}

#Main
function StartProgram {
  $delegateornot = Read-Host -Prompt 'Enter 1 to manage a delegate partner. Enter 2 to manage local domain.'
    if ($delegateornot -eq 1) {
      EstablishConnectionDelegated
      DisablePowershell
      DisconnectSession
    } Elseif ($delegateornot -eq 2) {
        EstablishConnection
        DisablePowershell
        DisconnectSession
      } Else {
          'Invalid Response'
        }
 }

StartProgram
