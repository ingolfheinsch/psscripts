
$ProfileRoot = (Split-Path -Parent $MyInvocation.MyCommand.Path)
$env:path += ";$ProfileRoot"


#aliases
set-alias subl 'C:\Program Files\Sublime Text 3\sublime_text.exe'
#functions
function mkdir { New-Item -ItemType directory -Path $args}