# Import module
[string]$repositoryRoot = 
    [IO.Path]::GetDirectoryName(
        [IO.Path]::GetDirectoryName( $MyInvocation.MyCommand.Definition )
    )
[string]$moduleRelPath = [IO.Path]::Combine('Modules' , 'Request-Imasparql.psm1')
[string]$moduleAbsPath = [IO.Path]::Combine($repositoryRoot, $moduleRelPath)

#if remove
#Remove-Module -Name Request-Imasparql
Import-Module -Name $moduleAbsPath

# Sample
Push-Location -LiteralPath $repositoryRoot

# define query
[string]$query = 
    Get-Content -LiteralPath ./Sample/Query/getChihayaScriptText.rq -Raw -Encoding UTF8

# get data
[psobject[]]$result = 
    Request-Imasparql -Query $query -OutputFormat csv -InformationAction Continue

# format and print
$result |
    select -Property name, text |
    Write-Output

Pop-Location