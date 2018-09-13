A simple plaster template to create modules. Mostly for my own use.

Designed to be run from inside the new module folder:

```
$PlasterParams = @{
    'TemplatePath'      = '..\PlasterTemplate'
    'DestinationPath'   = '.'
    'AuthorName'        = 'Sean Quinlan'
    'AuthorEmail'       = 'sean@yster.org'
    'ModuleName'        = Split-Path -Path $pwd.Path -Leaf
    'ModuleDescription' = 'Description of module'
    'ModuleVersion'     = '0.1'
}
Invoke-Plaster @PlasterParams
```