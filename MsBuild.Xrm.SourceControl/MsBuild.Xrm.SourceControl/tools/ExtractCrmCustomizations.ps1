#
# ExtractCrmCustomizations.ps1
#

[CmdletBinding()] 
param(
[parameter(Mandatory=$true)]
[string]$solutionPackager, #The full path to the solutionpackager.exe
[parameter(Mandatory=$true)]
[string]$solutionFilesFolder, #The folder to extract the CRM solution
[parameter(Mandatory=$true)]
[string]$solutionName, #The unique CRM solution name
[parameter(Mandatory=$true)]
[string]$environmentVariable, #Environment variable to the ConnectionString for Extract,
[parameter(Mandatory=$false)]
[Bool]$exportAutoNumberingSettings = $false,
[parameter(Mandatory=$false)]
[Bool]$exportCalendarSettings = $false
)

$ErrorActionPreference = "Stop"
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; 

$connectionString = [System.Environment]::GetEnvironmentVariable($environmentVariable) + ";Timeout=00:10:00;"

Write-Output "Solution Packager: $solutionPackager"
Write-Output "Solution Files Folder: $solutionFilesFolder"
Write-Output "Solution Name: $solutionName"
Write-Output "ConnectionString: $connectionString"

Set-ExecutionPolicy –ExecutionPolicy RemoteSigned –Scope CurrentUser


$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

$moduleName = $scriptPath + "\Microsoft.Xrm.Data.PowerShell.psm1"           
Write-Output "Importing: $moduleName" 
Import-Module -Name $moduleName              #-Verbose

$moduleName = $scriptPath + "\Microsoft.Xrm.Tooling.Connector.dll"        
Write-Output "Importing: $moduleName" 
Import-Module -Name $moduleName              #-Verbose

if ($exportAutoNumberingSettings -eq $true)
{
   Write-Output "Exporting AutoNumbering config"
}

if ($exportCalendarSettings -eq $true)
{
   Write-Output "Exporting Callendar config"
}

if( -Not (Test-Path -Path $solutionFilesFolder ) )
{
    New-Item -ItemType directory -Path $solutionFilesFolder
}

#Files Before Extract
[string[]]$beforeFiles = [System.IO.Directory]::GetFileSystemEntries($solutionFilesFolder, "*", [IO.SearchOption]::AllDirectories)
Write-Output "Before Files: " $beforeFiles

Write-Output "Removing solutions folder: " $solutionFilesFolder

[string] $delPath = "$solutionFilesFolder\*"
Remove-Item -Recurse -Force $delPath


#Export Solutions
Write-Output "Exporting Solutions to: " $env:TEMP

$unmanagedSolution = $solutionName + ".zip"
$unmanagedSolution = Export-CrmSolution -conn $connectionString -SolutionName $solutionName -SolutionFilePath $env:TEMP -SolutionZipFileName $unmanagedSolution -ExportAutoNumberingSettings:$exportAutoNumberingSettings -ExportCalendarSettings:$exportCalendarSettings

Write-Output "Exported Solution: $unmanagedSolution.SolutionPath"

$managedSolution = $solutionName + "_managed.zip"
$managedSolution = Export-CrmSolution -conn $connectionString -SolutionName $solutionName -SolutionFilePath $env:TEMP -SolutionZipFileName $managedSolution  -Managed -ExportAutoNumberingSettings:$exportAutoNumberingSettings -ExportCalendarSettings:$exportCalendarSettings

[string]$SolutionPath = $unmanagedSolution.SolutionPath
$extractOuput = & "$solutionPackager" /action:Extract /zipfile:"$SolutionPath" /folder:"$solutionFilesFolder" /packagetype:Both /errorlevel:Verbose /allowWrite:Yes /allowDelete:Yes

Write-Output $extractOuput
if ($lastexitcode -ne 0)
{
	throw "Solution Extract operation failed with exit code: $lastexitcode"
}
else
{
	if (($extractOuput -ne $null) -and ($extractOuput -like "*warnings encountered*"))
	{
		Write-Warning "Solution Packager encountered warnings. Check the output."
	}
}

#Files After Extract
[string[]]$afterFiles = [System.IO.Directory]::GetFileSystemEntries($solutionFilesFolder, "*", [IO.SearchOption]::AllDirectories)

#Get the difference
$deletedFiles = $beforeFiles | where {$afterFiles -notcontains $_}
$addedFiles = $afterFiles | where {$beforeFiles -notcontains $_}
if ($deletedFiles.Length -gt 0)
{
	Write-Output "Deleted Files:" $deletedFiles
	
	$_files = [System.String]::Join(""" """, $deletedFiles)
}
if ($addedFiles.Length -gt 0)
{
	Write-Output "Added Files:" $addedFiles
	$_files = [System.String]::Join(""" """, $addedFiles)
}

# End of script
