enum ImasparqlOutputFormat {
    json ; xml ; csv ; text 
}

# 結果のキャッシュ
[hashtable]$cache = @{
    [ImasparqlOutputFormat]::json = New-Object -TypeName 'Collections.Generic.Dictionary[string,psobject[]]'
    [ImasparqlOutputFormat]::xml  = New-Object -TypeName 'Collections.Generic.Dictionary[string,xml]'
    [ImasparqlOutputFormat]::csv  = New-Object -TypeName 'Collections.Generic.Dictionary[string,psobject[]]'
    [ImasparqlOutputFormat]::text = New-Object -TypeName 'Collections.Generic.Dictionary[string,string[]]'
}

function Request-Imasparql {
    [CmdletBinding()]Param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Query,
        [ImasparqlOutputFormat]$OutputFormat = [ImasparqlOutputFormat]::json,
        [switch]$Force
    )
    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'

    # キャッシュにあれば情報取得＆リターン
    [psobject]$dataFromCache = $null
    if ( $cache[$OutputFormat].TryGetValue( $Query , [ref]$dataFromCache ) ) {
        Write-Information 'use cache'
        Write-Information ('output = ' + $OutputFormat)
        Write-Information ('query = ' + $Query)
        return $dataFromCache
    }
    
    
    Write-Information 'access'
    [Net.WebClient]$wc = 
        New-Object -TypeName Net.WebClient -Property @{
            BaseAddress = 'https://sparql.crssnky.xyz/spql/imas/query'
            Encoding    = [Text.UTF8Encoding]$false
        }

    # クエリの設定
    [string]$escapedQuery = [uri]::EscapeDataString( $Query )

    $wc.QueryString.Set( 'output', $OutputFormat.ToString() ) # 出力形式
    $wc.QueryString.Set( 'query' , $escapedQuery )

    Write-Information ('output = ' + $OutputFormat)
    Write-Information ('escaped query = ' + $escapedQuery)
    
    [string]$dlTxt = $wc.DownloadString( [string]::Empty )
    
    [psobject]$result = switch ( $OutputFormat ) {
        json { (ConvertFrom-Json -InputObject $dlTxt).results.bindings }
        xml  { [xml]$dlTxt }
        csv  { ConvertFrom-Csv -InputObject $dlTxt }
        text { $dlTxt -split "`n" }
    }
    
    $cache[$OutputFormat].Add( $Query , $result )
    return $result
}

Export-ModuleMember -Function Request-Imasparql