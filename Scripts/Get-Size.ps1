function Get-Size {
  #.Synopsis
  #  Calculate the size of a folder on disk
  #.Description
  #  Recursively calculate the size of a folder on disk,
  #  outputting it's size, and that of all it's children,
  #  and optionally, all of their children
  param(
    [string]$root,
    # Show the size for each descendant recursively (otherwise, only immediate children)
    [switch]$recurse
  )
  # Get the full canonical FileSystem path:
  $root = Convert-Path $root

  $size = 0
  $files = 0
  $folders = 0

  $items = Get-ChildItem $root
  foreach($item in $items) {
    if($item.PSIsContainer) {
      # Call myself recursively to calculate subfolder size
      # Since we're streaming output as we go, 
      #   we only use the last output of a recursive call
      #   because that's the summary object
      if($recurse) {
        Get-Size $item.FullName | Tee-Object -Variable subItems
        $subItem = $subItems[-1]
      } else {
        $subItem = Get-Size $item.FullName | Select -Last 1
      }

      # The (recursive) size of all subfolders gets added
      $size += $subItem.Size
      $folders += $subItem.Folders + 1
      $files += $subItem.Files
      Write-Output $subItem
    } else {
      $files += 1
      $size += $item.Length
    }
  }

  # in PS3, use the CustomObject trick to control the output order
  if($PSVersionTable.PSVersion -ge "3.0") {
    [PSCustomObject]@{ 
      Folders = $folders
      Files = $Files
      Size = $size
      Name = $root
    }
  } else {
    New-Object PSObject -Property @{ 
      Folders = $folders
      Files = $Files
      Size = $size
      Name = $root
    }
  }
}