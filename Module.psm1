$Public_Folder = 'Public'
$Private_Folder = 'Private'

foreach ($Function_Folder in @($Public_Folder,$Private_Folder)) {
    $Functions_To_Import = @( Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath $Function_Folder) -Filter '*.ps1' -ErrorAction SilentlyContinue )
    if ($Functions_To_Import) {
        if ($Function_Folder -eq $Public_Folder) { $Public_Functions = $Functions_To_Import.BaseName }
        foreach ($Function in $Functions_To_Import) {
            try {
                Write-Verbose ('Importing {0} function "{1}"' -f $Function_Folder,$Function.BaseName)
                . $Function.FullName
            }
            catch {
                Write-Error ('Error importing function "{0}": {1}' -f $Function.FullName,$_.Error.Message)
            }
        }
    }
}

# Export only the public functions
Export-ModuleMember -Function $Public_Functions