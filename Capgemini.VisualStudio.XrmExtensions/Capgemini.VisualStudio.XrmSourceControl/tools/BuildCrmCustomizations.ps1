#
# BuildCrmCustomizations.ps1
#

param([string]$solutionPackager, #The full path to the solutionpackager.exe
[string]$solutionFilesFolder, #The folder with extracted CRM solution
[string]$solutionFilePath, #The output solution file path
[string]$mappingFilePath, #The mapping file Path
[string]$solutionType #The type of solution Managed or UnManaged
)

$ErrorActionPreference = "Stop"
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; 

$mapperResult = & "$solutionPackager" /a:Pack /p:$solutionType /z:"$solutionFilePath" /f:"$solutionFilesFolder" /m:"$mappingFilePath" 
  
Write-Output $mapperResult

if($mapperResult -Match "Pack operation is aborted.")
{
   Write-Error "File not found in either CRM or Extracted customisations."
}

