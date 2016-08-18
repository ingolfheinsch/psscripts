param(
      [parameter()][alias("r")]
      $rec,

      [Parameter(Mandatory = $true, Position = 0)]
      [string] $path
   )
   if ($rec -eq "true")
   {
    Get-ChildItem $path -recurse -force | Where-Object {$_.mode -match "h"}
   }
else
   {
    Get-ChildItem $path -force | Where-Object {$_.mode -match "h"}
   }

 


