$ModulePath = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$BuildData = Import-LocalizedData -BaseDirectory $ModulePath -FileName build.psd1

Push-Location -Path $ModulePath -StackName 'DevModuleLoader'
$Scripts = Get-ChildItem -Path $BuildData.SourceDirectories -File -Filter *.ps1 | Select-Object -ExpandProperty FullName
if (-not [string]::IsNullOrWhiteSpace($BuildData.Prefix) -and (Test-Path -Path $BuildData.Prefix)) {
    # The ScriptBlock::Create method needs a fully-qualified path, so resolve the path if it's invoked from a relative path name
    $BuildData_Prefix_Path = (Resolve-Path -Path $BuildData.Prefix).Path
    . ([ScriptBlock]::Create([System.IO.File]::ReadAllText($BuildData_Prefix_Path)))
}
foreach ($Script in $Scripts) {
    . ([ScriptBlock]::Create([System.IO.File]::ReadAllText($Script)))
}
if (-not [string]::IsNullOrWhiteSpace($BuildData.Suffix) -and (Test-Path -Path $BuildData.Suffix)) {
    $BuildData_Suffix_Path = (Resolve-Path -Path $BuildData.Suffix).Path
    . ([ScriptBlock]::Create([System.IO.File]::ReadAllText($BuildData_Suffix_Path)))
}
$SearchRecursive = $true
$SearchRootOnly = $false
$PublicScriptBlock = [ScriptBlock]::Create('{0}' -f (Get-ChildItem -Path $BuildData.PublicFilter -ErrorAction SilentlyContinue | Get-Content -Raw | Out-String))
$PublicFunctions = $PublicScriptBlock.Ast.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $SearchRootOnly).Name
$PublicAlias = $PublicScriptBlock.Ast.FindAll({ $args[0] -is [System.Management.Automation.Language.ParamBlockAst] }, $SearchRecursive).Where{$_.TypeName.FullName -eq 'alias'}.PositionalArguments.Value

$ExportParam = @{}
if ($PublicFunctions) {
    $ExportParam.Add('Function', $PublicFunctions)
}
if ($PublicAlias) {
    $ExportParam.Add('Alias', $PublicAlias)
}
if ($ExportParam.Keys.Count -gt 0) {
    Export-ModuleMember @ExportParam
}

Pop-Location -StackName 'DevModuleLoader'
