# xrm-visualstudio-extensions

Capgemini Visual Studio Extensions to provide an easy source control for Dynamics CRM - contains extract customisations and build scripts based on solutionpackager.exe SDK tool. Supports mapping file, managed and unmanaged solutions, export autonumber and callendar settings

It extends msbuild process for Clean and Afterbuild targets:
1. Clean - executes a custom powershell script to export managed and unmanaged solution and unpack them with CRM solutionpackager.exe SDK tool to the Src folder.
2. AfterBuild - executes a custom powershell script to pack the Src folder into managed (for Release configuration) and unmanged (for Release and Debug configuration) CRM solution using CRM solutionpackager.exe SDK tool.

# Dependencies
1. Microsoft.Xrm.Data.PowerShell - [Microsoft.Xrm.Data.PowerShell GitHub project](https://github.com/seanmcne/Microsoft.Xrm.Data.PowerShell) - PowerShell wrapper for CRM SDK  [CrmServiceClient](https://msdn.microsoft.com/en-us/library/microsoft.xrm.tooling.connector.crmserviceclient_methods(v=crm.6).aspx) class.