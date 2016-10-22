Import-Module C:\workspace\source\PowerShell\Elysian.psd1 -Force

set-alias -Name ele -value Stop-LocalLiquidEnvironment
function slef { Start-LocalLiquidEnvironment -ShadowCopy -Environment 90_LOCALFULL }
function sled { Start-LocalLiquidEnvironment -ShadowCopy -Environment 90_LOCALDATASERVER }
function sleb { Start-LocalLiquidEnvironment -ShadowCopy -Environment 90_LOCALBME }
function slef { Start-LocalLiquidEnvironment -ShadowCopy -Environment 90_LOCALGLOBEX }


Export-ModuleMember -Function “*”
Export-ModuleMember -Variable “*”
Export-ModuleMember -Alias “*”