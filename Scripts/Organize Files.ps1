<#
-> Running this script with admin rights
#>
<#
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{   
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    Break
}
#>
$scriptLocationOnThisPC = split-path -parent $MyInvocation.MyCommand.Definition
$configFilesLocationOnThisPC = "$scriptLocationOnThisPC\Config files"

<#
-> Reading the txt files for configurations
#>

$option = Get-Content -Path "$configFilesLocationOnThisPC\Option.txt"
$path = Get-Content -Path "$configFilesLocationOnThisPC\Path.txt"

if($path -eq 'Desktop') {
    $path = [Environment]::GetFolderPath("Desktop")
}
if($path -eq 'My Documents') {
    $path = [Environment]::GetFolderPath("MyDocuments")
}
if($path -eq 'My Pictures') {
    $path = [Environment]::GetFolderPath("MyPictures")
}
if($path -eq 'My Music') {
    $path = [Environment]::GetFolderPath("MyMusic")
}
if($path -eq 'My Videos') {
    $path = [Environment]::GetFolderPath("MyVideos")
}



<#
-> Defining functions
#>
function groupFilesByYear { # this function is grouping files in folders by the year of file creation (Ex: 2016, 2017, 2018, 2019)
    Get-ChildItem -Path $path | ForEach-Object {
        $pathFolder = $path
        $pathFolder += "\~_"
        $pathFolder += $_.CreationTime.toString("yyyy")
        $pathFolder +="_~"
        New-Item -ItemType "directory" -Path $pathFolder -ErrorAction SilentlyContinue
        if(($_.Name.Substring(0,2) -ne '~_') -or ($_.Name.Substring($_.Name.Length-2,2) -ne '_~')) {
            $num=1
            $nextName = Join-Path -Path $pathFolder -ChildPath $_.name
            while(Test-Path -Path $nextName)
            {
                $nextName = Join-Path $pathFolder ($_.BaseName + " ($num)" + $_.Extension)    
                $num+=1   
            }
            Move-Item -LiteralPath $_.PSPath -Destination $nextName
        }
    } 
}

function groupFilesByMonth { # this function is grouping files in folders by the month of file creation (Ex: may, june, july, august)
    Get-ChildItem -Path $path | ForEach-Object {
        $pathFolder = $path
        $pathFolder += "\~_"
        $pathFolder += (Get-Culture).DateTimeFormat.GetMonthName($_.CreationTime.Month)
        $pathFolder +="_~"
        New-Item -ItemType "directory" -Path $pathFolder -ErrorAction SilentlyContinue
        if(($_.Name.Substring(0,2) -ne '~_') -or ($_.Name.Substring($_.Name.Length-2,2) -ne '_~')) {
            $num=1
            $nextName = Join-Path -Path $pathFolder -ChildPath $_.name
            while(Test-Path -Path $nextName)
            {
                $nextName = Join-Path $pathFolder ($_.BaseName + " ($num)" + $_.Extension)    
                $num+=1   
            }
            Move-Item -LiteralPath $_.PSPath -Destination $nextName
        }
    } 
}

function bringFilesBack { # this function is bringing files to the original state, the way were before grouping them by year or month
    Get-ChildItem -Path $path | ForEach-Object {
            if(($_.Name.Substring(0,2) -eq '~_') -and ($_.Name.Substring($_.Name.Length-2,2) -eq '_~')) {
                Get-ChildItem -Path $_.PSPath | ForEach-Object {
                    if(($_.Name.Substring(0,2) -ne '~_') -or ($_.Name.Substring($_.Name.Length-2,2) -ne '_~')) {
                        $num=1
                        $nextName = Join-Path -Path $path -ChildPath $_.name
                        while(Test-Path -Path $nextName)
                        {
                            $nextName = Join-Path $path ($_.BaseName + " ($num)" + $_.Extension)    
                            $num+=1   
                        }
                        Move-Item -LiteralPath $_.PSPath -Destination $nextName
                    }
                    else {
                        Get-ChildItem -Path $_.PSPath | ForEach-Object {
                        $num=1
                        $nextName = Join-Path -Path $path -ChildPath $_.name
                        while(Test-Path -Path $nextName)
                        {
                            $nextName = Join-Path $path ($_.BaseName + " ($num)" + $_.Extension)    
                            $num+=1   
                        }
                        Move-Item -LiteralPath $_.PSPath -Destination $nextName
                        }
                    }
                }
            }
        } 
}

function deleteEmptyFolders { 
# This function is removing empty folders that may remain after reorganizing of files (Only folders with the name of year or month that may remain empty)
    Get-ChildItem -Path $path -Directory | ForEach-Object {
        Get-ChildItem -Path $_.PSPath -Directory | 
        Where-Object { ($($_ | Get-ChildItem -Force | Select-Object -First 1).Count -eq 0) -and ($_.Name.Substring(0,2) -eq '~_') -and ($_.Name.Substring($_.Name.Length-2,2) -eq '_~')} |
        Remove-Item -Verbose
    } 
    Get-ChildItem -Path $path -Directory | 
    Where-Object { ($($_ | Get-ChildItem -Force | Select-Object -First 1).Count -eq 0) -and ($_.Name.Substring(0,2) -eq '~_') -and ($_.Name.Substring($_.Name.Length-2,2) -eq '_~')} |
    Remove-Item -Verbose              
}



<#
-> Calling functions according to the options selected by user
#>
if ($option -eq '1') {
    bringFilesBack
    groupFilesByYear
    deleteEmptyFolders
}
elseif ($option -eq '2') {
    bringFilesBack
    groupFilesByMonth
    deleteEmptyFolders
}
elseif ($option -eq '3') {
    bringFilesBack
    groupFilesByYear
    $parentPath = $path
    Get-ChildItem -Path $parentPath | ForEach-Object {
        $path = $_.PSPath
        groupFilesByMonth
    }
    $path = $parentPath
    deleteEmptyFolders
}
elseif ($option -eq '4') {
    bringFilesBack
    deleteEmptyFolders
}



<#
-> Messages shown after this script finished the file organizing
#>
Write-Host '
Script run successfully!
'
