set-location C:\
$scripts = "C:\nsynk-system\scripts\ps\"
#msbuild
set-alias msbuild C:\Windows\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe
# firefox
Set-Alias ff  "C:\Program Files (x86)\Mozilla Firefox\firefox.exe"
# notepat
Set-Alias edit 'C:\Program Files\Notepad++\notepad++.exe'
#set-alias for graphics magick
Set-Alias im "C:\Program Files\ImageMagick-7.0.5-Q16\magick.exe"
#list directories only
function getdir {get-childitem | ?{$_.psiscontainer}}
set-alias lsd -value getdir
#emacs nowindow
function emacs-nw($file)
{   
    &((gcm emacs).Source) -nw $file
}
set-alias em emacs-nw
# get-remaining battery time
function getruntime {(Get-WmiObject win32_battery).estimatedruntime} 
set-alias grt -value getruntime
#zip
set-alias uzip expand-archive
set-alias zip compress-archive
function Expand-ZIPFile($file, $destination)
{
    $shell = new-object -com shell.application
    $zip = $shell.NameSpace($file)
    foreach($item in $zip.items())
    {
        $shell.Namespace($destination).copyhere($item)
    }
}

#ls date sorted
function lsw ($count)
{
	if ($count -eq $Null){Get-ChildItem | Sort-Object -property LastWriteTime} 
	else {gci | sort-object -property LastWriteTime | select-object -last $count}  
}
#get 5 most cpu consuming processes
function cpu ($count)
{
	if ($count -eq $Null) {get-process | sort-object CPU -desc | format-table CPU,ProcessName}
	else {get-process | sort-object CPU -desc | select-object -first $count | format-table CPU,ProcessName}
}

#Alias
Set-Alias touch -Value New-Item

#create vvvv plugin template in current directory
function create-vvvv-template ($name) {
    if($name -eq $Null) {
        Write-Output "you must specify a name!"
    }
    else {
        Write-Output "Clone Repo - should be changed to donwload a zip"
        git clone https://bitbucket.org/ingolfheinsch/vvvv-plugin-template.git

        Write-Output "rename folder"
        Rename-Item .\vvvv-plugin-template -NewName $name

        Write-Output "rename solution & csproj"
        $sln = ".sln"
        $csproj = ".csproj"
        $cs = ".cs"
        $soultion = $name+$sln
        $project = $name+$csproj 
        $class = $name+$cs
        Rename-Item .\$name\vvvv-plugin-template.sln -NewName $soultion
        Rename-Item .\$name\vvvv-plugin-template.csproj -NewName $project
      #  Rename-Item .\$name\Class1.cs -NewName $class
        Set-Location .\$name

        Write-Output "install latest paket"
        .paket\paket.bootstrapper.exe

        Write-Output "run paket install"
        .paket\paket.exe init
        .paket\paket.exe install

        #update build batch
        Write-Output "update build batch"
        (Get-Content .\build.bat).replace('vvvv-plugin-template.csproj', $project) | Set-Content .\build.bat
        
    }
    
}

#teleport
set-alias teleport -value tp
$targets = @{}
$targets.Add("hm", $HOME)
$targets.Add("ad", $HOME + "\AppData\Roaming\")
$targets.Add("dl", $HOME + "\Downloads\")
$targets.Add("sys", "c:\nsynk-system\")
$targets.Add("pl", "c:\nsynk-system\vvvv-packs\nodes\plugins\")
$targets.Add("mod", "c:\nsynk-system\vvvv-packs\nodes\modules\")
$targets.Add("vv", "c:\vvvv\")
$targets.Add("scr", "c:\nsynk-system\scripts\")
$targets.Add("cfg", "c:\nsynk-system\scripts\config\")
$targets.Add("tl", "c:\nsynk-system\tools\")
$targets.Add("choc", "c:\programdata\chocolatey\bin\")

#read additional targets from file
$targetfile = $HOME + "\targets.tp"
if (test-path $targetfile)
{
	#$filetarget = (get-content $targetfile) | convertfrom-stringdata
	#if($filetarget -ne $Null) {$targets +=  $filetarget}

    write-output "Load teleport targets from: " $targetfile
	foreach ($tg in (get-content -raw $targetfile))
	{
        # write-output $tg
		$targets += ($tg | convertfrom-stringdata)
	}
}
else
{
	write-output "no local teleport target file found."
}

#add new targets to file
function addPersistantTarget ($id)
{
	if (!(test-path $targetfile)){ touch $targetfile}

		$currentTargets = @{}
		if ($filetarget -ne $Null){$currentTargets += $filetarget}
		$currentTargets.Add($id, $targets.Item($id))
	
		#$currentTargets | export-csv c:\temp\csv.test
		
		foreach($t in $currentTargets)
		{
			foreach($k in $t.keys){
				   foreach($v in $t.values){
				   	      $entry = ($k + " = " + $v) -join " "
					      add-content $targetfile $entry
					      		  }
					      }
		}
		write-output "target added."
	   
}

function tp ($action, $id)
{
    if ($action -eq $Null -and $id -eq $Null)
    {
         Write-Output "Weclome to Teleport!"
         Write-Output "Teleport let you create warppoints to your favourite locations."
         Write-Output "try: tp help"
         break
    }
    if ($action -eq "help")
    {
        Write-Output "usage: tp [action] [target]"
        Write-Output "actions: -list, add, remove, goto"
        break
    }
    if ($action -eq "add")
    {
        if($targets.ContainsKey($id)) {
            Write-Output "target:$id already exist. add '-o' option to overwrite."
           # $targets.Set_Item($id, $PWD)    
        }
        else {
            $targets.Add($id, $PWD)
	    addPersistantTarget($id)
        }
        break
    }
    if ($action -eq "remove") {
        $targets.Remove($id)
        break
    }
    if ($action -eq "list") {
        Write-Output Teleport-Warppoints
        $targets
        break
    }
    if ($action -eq "goto")
    {
         if ($targets.ContainsKey($id)){
            set-location $targets.$id
            break
        }
    else {
            Write-Output "target not found"
        break
        }
    }
    if ($targets.ContainsKey($action)){
       set-location $targets.$action
    }
    else {
        Write-Output "target not found"
    }
}

## THE PROMPT

function Test-Administrator {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function prompt {
    $realLASTEXITCODE = $LASTEXITCODE

    Write-Host

    # Reset color, which can be messed up by Enable-GitColors
 #   $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor

    if (Test-Administrator) {  # Use different username if elevated
        Write-Host "(Elevated) " -NoNewline -ForegroundColor White
    }

    Write-Host "$ENV:USERNAME@" -NoNewline -ForegroundColor DarkYellow
    Write-Host "$ENV:COMPUTERNAME" -NoNewline -ForegroundColor Magenta

    if ($s -ne $null) {  # color for PSSessions
        Write-Host " (`$s: " -NoNewline -ForegroundColor DarkGray
        Write-Host "$($s.Name)" -NoNewline -ForegroundColor Yellow
        Write-Host ") " -NoNewline -ForegroundColor DarkGray
    }

    Write-Host " : " -NoNewline -ForegroundColor DarkGray
    Write-Host $($(Get-Location) -replace ($env:USERPROFILE).Replace('\','\\'), "~") -NoNewline -ForegroundColor Blue
    Write-Host " : " -NoNewline -ForegroundColor DarkGray
  #  Write-Host (Get-Date -Format G) -NoNewline -ForegroundColor DarkMagenta
   # Write-Host " : " -NoNewline -ForegroundColor DarkGray

    $global:LASTEXITCODE = $realLASTEXITCODE

    Write-VcsStatus

    Write-Host ""

    return "> "
}
# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
