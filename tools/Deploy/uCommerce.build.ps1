properties {
    $configuration = 'Debug'
    $src = "."
    $zipFileName = "uCommerce-Sitecore-Demo-Store-{0}-{1}.zip"
    $zipDestinationFolder = "C:\tmp"
    $solution_file = "uCommerce.DemoStore.sln"
    $working_dir = $null
    $version = $null
    $base_dir = $null
    $updatePackageVersion = $false
    $script:hash = @{}
    $target="none"
    $CreatePackage = $True
}
. .\Deploy.Common.ps1
. .\Validation.ps1
. .\Compile.ps1
. .\uCommerce.Sitecore.ps1

task default -depends Compile

task UpdateAssemblyInfo -description "Updates the AssemblyInfo.cs file if there is a valid version string supplied" -precondition { return IsVersionNumber $version } {
    Push-Location $src
    
    $assemblyVersionPattern = 'AssemblyVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)'
    $fileVersionPattern = 'AssemblyFileVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)'
    $assemblyVersion = 'AssemblyVersion("' + $script:version + '")';
    $fileVersion = 'AssemblyFileVersion("' + $script:version + '")';
    
    Get-ChildItem -r -filter AssemblyInfo.cs | ForEach-Object {
        $filename = $_.Directory.ToString() + '\' + $_.Name
        $filename + ' -> ' + $script:version
        
        # If you are using a source control that requires to check-out files before 
        # modifying them, make sure to check-out the file here.
        # For example, TFS will require the following command:
        # tf checkout $filename
        (Get-Content $filename) | ForEach-Object {
            % {$_ -replace $assemblyVersionPattern, $assemblyVersion } |
            % {$_ -replace $fileVersionPattern, $fileVersion }
        } | Set-Content $filename
    }

    Pop-Location
}