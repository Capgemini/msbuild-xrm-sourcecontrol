# Capgemini.VisualStudio.XrmSourceControl

Capgemini Visual Studio Extensions to provide an easy source control for Dynamics CRM - contains extract customisations and build scripts based on solutionpackager.exe SDK tool. Supports mapping file, managed and unmanaged solutions, export autonumber and callendar settings

It extends msbuild process for Clean and Afterbuild targets:
1. Clean - executes a custom powershell script to export managed and unmanaged solution and unpack them with CRM solutionpackager.exe SDK tool to the Src folder.
2. AfterBuild - executes a custom powershell script to pack the Src folder into managed (for Release configuration) and unmanged (for Release and Debug configuration) CRM solution using CRM solutionpackager.exe SDK tool.

# Dependencies
1. Microsoft.Xrm.Data.PowerShell - [Microsoft.Xrm.Data.PowerShell GitHub project](https://github.com/seanmcne/Microsoft.Xrm.Data.PowerShell) - PowerShell wrapper for CRM SDK  [CrmServiceClient](https://msdn.microsoft.com/en-us/library/microsoft.xrm.tooling.connector.crmserviceclient_methods(v=crm.6).aspx) class.
2. Microsoft.CrmSdk.CoreTools - [Microsoft.CrmSdk.CoreTools Nuget package](https://www.nuget.org/packages/Microsoft.CrmSdk.CoreTools/) - Offical Microsoft CRM SDK core tools
3. CreateNewNuGetPackageFromProjectAfterEachBuild - [CreateNewNuGetPackageFromProjectAfterEachBuild Nuget package](https://www.nuget.org/packages/CreateNewNuGetPackageFromProjectAfterEachBuild/) - helper package to build nuget packages

###Example Usage

Below shows the basic configurations to extract the customisations into source control

### Configuration

When the Nuget package is first installed, two configuration files will be added into the project.

#### CrmConfiguration.props

##### Default Values

```xml
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup> 
    <CrmSolutionName>NOT_DEFINED</CrmSolutionName> 
    <CrmConnectionString>Url=url; Username=user; Password=password; AuthType=Office365;</CrmConnectionString>
    <ExportAutoNumberSettings>0</ExportAutoNumberSettings>
    <ExportCallendarSettings>0</ExportCallendarSettings>
</PropertyGroup> 
</Project>
```

The first step is to populate the values for each of the elements:

**CrmSolutionName**: The Name of the Dynamics Solution
**CrmConnectionString**: The connection string that will be used to connect to the Dynamics instance, for more information, see [here](https://msdn.microsoft.com/en-gb/library/mt608573.aspx?f=255&MSPPError=-2147217396)
**ExportAutoNumberSettings**: Option for whether to Export the AutoNumber Settings for the Solution, 0 for No, 1 for Yes
**ExportCallendarSettings**: Option for whether to Export the Callendar Settings for the Solution, 0 for No, 1 for Yes

The last two option are the equivalent of ticking the first two options on this page of the Dynamics Solution Export dialog:

[SolutionExport.png](attachments/SolutionExport.png =500x)

#### MappingFile.xml

##### Default Values

```xml
<?xml version="1.0" encoding="utf-8"?>
<Mapping>
  
</Mapping>
```

The Mapping configuration is used when the Solution file is being rebuilt from the extracted files. The mapping file can define mappings between a file that is contained in the solution, to a file that is in Source Control, the primary use for this is Web Resources, but it can also be used for compiled solution components such as Plugin dll files. When the solution is being built, the mapped files will be used instead of the ones already in the solution. This is to try to make sure that the latest version of the files are used.

##### Example

```xml
<?xml version="1.0" encoding="utf-8"?>
<Mapping>
  <FileToPath map="WebResources\*.*" to="..\..\Capgemini.Base.CrmPackage\WebResources\**" />
  <FileToPath map="WebResources\**\*.*" to="..\..\Capgemini.Base.CrmPackage\WebResources\**" />
  <FileToFile map="CapgeminiBaseWorkflows.dll" to="..\..\Capgemini.Base.Workflows\bin\**\Capgemini.Base.Workflows.dll" />
  <FileToFile map="CapgeminiBasePlugins.dll" to="..\..\Capgemini.Base.Plugins\bin\**\Capgemini.Base.Plugins.dll" />
</Mapping>
```

You can either use the FileToPath or FileToFile to map a collection of files or just a single file.

### Solution Extraction

The installation of the Nuget package will modify the .csproj file to add tasks into the project build process. When the "Clean" command is run on the project, the `ExtractCrmCustomizations.ps1` powershell script will be executed using the configuration files that we've previously mentioned to connect to Dynamics and extract the solution into the "Src" folder of the project. The "Src" folder and it's contents should be included in the Source Control if it isn't automatically. Every time the "Clean" is run and the changes are synced, a history will be built in Source Control giving the team more visibility of changes.

### Solution Rebuild

When the "Build" command is run on the project, the `BuildCrmCustomizations.ps1` powershell script will be executed using the configuration files that we've previously mentioned and build the solution files in the "Src" folder into a Dynamics Solution file. As you are probably aware, there are two different types of Dynamics solution, Managed or Unmanaged. If you're in the Debug build configuration, only the Unmanaged version of the Dynamics Solution will be built, if you're in Release, both a Managed and Unmanaged version will be built. The built solution files will be outputted to the "Bin" folder. Ready to be manually taken or used in an Automated build process.
