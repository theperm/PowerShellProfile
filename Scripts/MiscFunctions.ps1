function fu($folder)
{

  $startFolder = "."

  $colItems = (Get-ChildItem $startFolder | Measure-Object -property length -sum)
  "$startFolder -- " + "{0:N2}" -f ($colItems.sum / 1MB) + " MB"

  $colItems = (Get-ChildItem $startFolder -recurse | Where-Object {$_.PSIsContainer -eq $True} | Sort-Object)
  foreach ($i in $colItems)
      {
          $subFolderItems = (Get-ChildItem $i.FullName | Measure-Object -property length -sum)
          $i.FullName + " -- " + "{0:N2}" -f ($subFolderItems.sum / 1MB) + " MB"
      }
}

function DirWithSize($path=$pwd)
{
    Get-ChildItem $path | 
        Foreach {if (!$_.PSIsContainer) {$_} `
                 else {
                     $size=0; `
                     Get-ChildItem $_ -r | Foreach {$size += $_.Length}; `
                     Add-Member NoteProperty Length $size -Inp $_ -PassThru `
                 }} |
        Format-Table Mode, LastWriteTime, Name, Length -Auto
}

function Reload-Profile {
    @(
        $Profile.AllUsersAllHosts,
        $Profile.AllUsersCurrentHost,
        $Profile.CurrentUserAllHosts,
        $Profile.CurrentUserCurrentHost
    ) | % {
        if(Test-Path $_){
            Write-Verbose "Running $_"
            . $_
        }
    }    
}