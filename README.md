# Capgemini.VisualStudio.XrmSourceControl

## Introduction
Capgemini Visual Studio Extensions to provide easy source control for Dynamics CRM customisations. The extensions use powershell scripts that can seamlessly extract customisations from a Dynamics CRM instance and rebuild into a Solution file.  

The scripts use the *SolutionPackager.exe* tool provided by the Dynamics SDK. Supports file mappings, Managed and Unmanaged solutions, and the export of Autonumber and Calendar settings.

It extends the msbuild process for Clean and Afterbuild targets:
1. **Clean** - Executes a custom powershell script to export Managed and Unmanaged solution file from Dynamics and unpack them with *SolutionPackager.exe* to the "Src" folder.
2. **AfterBuild** - Executes a custom powershell script to pack the "Src" folder into Managed (for Release configuration) and Unmanaged (for Release and Debug configuration) Dynamics solution files using *SolutionPackager.exe*.

## Dependencies
- **Microsoft.Xrm.Data.PowerShell** - [Microsoft.Xrm.Data.PowerShell GitHub project](https://github.com/seanmcne/Microsoft.Xrm.Data.PowerShell) - PowerShell wrapper for CRM SDK  [CrmServiceClient](https://msdn.microsoft.com/en-us/library/microsoft.xrm.tooling.connector.crmserviceclient_methods(v=crm.6).aspx) class.
- **Microsoft.CrmSdk.CoreTools** - [Microsoft.CrmSdk.CoreTools Nuget package](https://www.nuget.org/packages/Microsoft.CrmSdk.CoreTools/) - Offical Microsoft CRM SDK core tools
- **CreateNewNuGetPackageFromProjectAfterEachBuild** - [CreateNewNuGetPackageFromProjectAfterEachBuild Nuget package](https://www.nuget.org/packages/CreateNewNuGetPackageFromProjectAfterEachBuild/) - helper package to build nuget packages