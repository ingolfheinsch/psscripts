param(
      [parameter()][alias("r")]
      $recursive,

      [parameter()][alias("d")]
      $delete,

      [Parameter(Mandatory = $true, Position = 0)]
      [string] $path
   )
   if ($recursive -eq "true")
   {
        Get-ChildItem $path -recurse -force | Where-Object {$_.mode -match "h"}
        if ($delete -eq "true")
        {
            Get-ChildItem $path -recurse -force | Where-Object {$_.mode -match "h"} | Remove-Item -force
        }
   }
    else
   {
        Get-ChildItem $path -force | Where-Object {$_.mode -match "h"}
    if ($delete -eq "true")
        {
             Get-ChildItem $path -force | Where-Object {$_.mode -match "h"} | Remove-Item -force
        }
   }

 


