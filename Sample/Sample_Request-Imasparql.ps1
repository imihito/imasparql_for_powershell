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

# define query
# https://sparql.crssnky.xyz/imas/ 内の「千早のセリフテキストを取得」のクエリ
[string]$query = @'
PREFIX schema: <http://schema.org/>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX imas: <https://sparql.crssnky.xyz/imasrdf/URIs/imas-schema.ttl#>

SELECT *
WHERE {
  ?s rdf:type imas:ScriptText;
     imas:Source ?source;
     schema:text ?text.
  ?source schema:name ?name;
     filter(contains(str(?name),"千早")) #コメント
} #order by ?text
'@

# get data
[psobject[]]$result = 
    Request-Imasparql -Query $query -OutputFormat csv -InformationAction Continue

# format and print
$result |
    select -Property name,text |
    Write-Output