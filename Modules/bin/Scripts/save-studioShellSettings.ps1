#
#   Copyright (c) 2011 Code Owls LLC, All Rights Reserved.
#
#   Licensed under the Microsoft Reciprocal License (Ms-RL) (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#     http://www.opensource.org/licenses/ms-rl
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#


[CmdletBinding()]
param( 
	[Parameter(ValueFromPipeline=$true)]
	# the settings to save
	$settings
)

begin
{
	$mydocs = [environment]::getFolderPath( 'mydocuments' );
    
	$script:profileDir = $mydocs | join-path -child 'codeowlsllc.studioshell';
	$script:profileFile = $script:profileDir | join-path -child 'settings.txt';

	if( -not (test-path $script:profileDir) )
	{
		mkdir $script:profileDir
	}
}

process
{
	$settings | Get-Member -MemberType Properties | foreach{ 
		$name = $_.name; 
		$value = $settings."$name";
		if( $value -match 'false' )
		{
			$value = $null;
		}
		
		"$name=" + $value;
	} | Out-File -filepath $script:profileFile
}

<#
.SYNOPSIS 
Saves user-level StudioShell settings.

.DESCRIPTION
Saves user-level StudioShell settings.

These settings are stored in the user's home folder in the following location:

~/documents/codeowlsllc.studioshell/settings.txt

.INPUTS
System.Collections.Hashtable.  A table of StudioShell user-level settings.

.OUTPUTS
None.

.NOTE
This script is used internally by StudioShell to persist user-level settings.

.LINK
about_StudioShell
about_StudioShell_Settings
about_StudioShell_Profiles
get-help PSDTE
get-studioShellSettings
#>
