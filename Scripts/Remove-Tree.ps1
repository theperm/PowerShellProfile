function Get-Tree($Path,$Include='*') { 
    @(Get-Item $Path -Include $Include) + 
        (Get-ChildItem $Path -Recurse -Include $Include) | 
        sort pspath -Descending -unique
} 

function Remove-Tree($Path,$Include='*') { 
    Get-Tree $Path $Include | Remove-Item -force -recurse
} 

