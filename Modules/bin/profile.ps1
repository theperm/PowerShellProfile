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
#	profile.ps1 - static "All Users" profile script for StudioShell
#	
#	note that editing this file is NOT RECOMMENDED; instead create a
#	user StudioShell profile script by following the instructions in 
#	about_StudioShell_Profiles
#

# default prompt
function prompt()
{
	"§ $( $pwd -replace '^.+::','' )> ";
}
           
#additional profile and environment initialization scripts

$local:root = $myInvocation.MyCommand.Path | split-path | join-path -child '../InitializationScripts';
write-debug "profile initialization script repository path is $local:root";

# registers drive aliases for common dte access points
. $local:root/register-drives.ps1;	

# adds context menu items specific to studioshell
#. $local:root/register-contextMenuItems.ps1;

# scaffolds the solution event handlers for per-solution module management
. $local:root/register-solutionevents.ps1;
