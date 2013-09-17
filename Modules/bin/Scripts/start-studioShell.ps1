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

write-host "Studio" -back darkblue -fore darkyellow -nonewline;
write-host "Shell" -fore darkblue -back darkyellow;
write-host "Copyright (c) 2011 Code Owls LLC, All Rights Reserved.";

import-module studioshell;

if( $profile )
{
	. invoke-studioShellProfile.ps1 $profile;
}

<#
.SYNOPSIS 
Initializes StudioShell.

.DESCRIPTION
Dot-source this command to load StudioShell in your PowerShell session.

This script imports the StudioShell PowerShell module and dot-sources
the StudioShell profile scripts.

.INPUTS
None.

.OUTPUTS
None.

.EXAMPLE
C:\PS> start-studioShell.ps1

.LINK
about_StudioShell
about_StudioShell_Hosts
about_StudioShell_Settings
about_StudioShell_Profiles
get-help PSDTE

#>
