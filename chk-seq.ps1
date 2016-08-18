# this script checks a given folder for conseductive file namings as there are used for image sequences
# it returns missing numbers
if ($args.Length -eq 0)
{
    echo "path missing"
    echo "Usage: chk-seq <path>"
    break
}
else
{
# initialize the items variable with the
# contents of a directory
$items = Get-ChildItem -Path $args[0]
 
#create int array to store filenumbers
$ArrList = [System.Collections.ArrayList]@()
#create arraylist to store missing filenames
$files = [System.Collections.ArrayList]@()
# enumerate the items array

# find all elements containing at least 4 digits in their name, converting them into int and adding into a new arraylist
foreach ($item in $items)
{
      # if the item is NOT a directory, then process it.
      if ($item.Attributes -ne "Directory" -and $item.BaseName -match '(\d{4})')
      {
        [Void]$ArrList.Add($item.BaseName) 
      }
}

#parsing arraylist checking for conseductive numbers
for ($i=1; $i -le $ArrList.Count;$i++)
{
    if ($ArrList[$i]-$ArrList[$i-1] -gt 1)
    {
        Write-Host ($ArrList[$i]-1) is missing
    }
}
}