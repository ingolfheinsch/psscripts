param(
      [parameter()][alias("r")]
      $rec,

      [parameter()][alias("d")]
      $del,

      [Parameter(Mandatory = $true, Position = 0)]
      [string] $path
   )
   if ($rec -eq "true")
   {
        Get-ChildItem $path -recurse -force | Where-Object {$_.mode -match "h"}
        if ($del -eq "true")
        {
            Get-ChildItem $path -recurse -force | Where-Object {$_.mode -match "h"} | Remove-Item -force
        }
   }
    else
   {
    Get-ChildItem $path -force | Where-Object {$_.mode -match "h"}
    if ($del -eq "true")
        {
             Get-ChildItem $path -force | Where-Object {$_.mode -match "h"} | Remove-Item -force
        }
   }

 


