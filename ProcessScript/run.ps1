using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

$settings = if($Request.Body.Settings) {
    $Request.Body.Settings
} else {
    "PSGallery"
}

# Interact with query parameters or the body of the request.
if($Request.Body.script) {
    Write-Verbose "Script specified." -Verbose
    try {
        $results = @(Invoke-ScriptAnalyzer -ScriptDefinition $Request.Body.script -Settings $settings)
        $status = [HttpStatusCode]::OK
    } catch {
        $status = [HttpStatusCode]::BadRequest
        $results = $_
    }
} elseif($Request.Body.ModuleName) {
    Write-Verbose "Module name specified." -Verbose
    $tmpDir = [System.IO.Path]::GetTempPath()
    $modulePath = Join-Path $tmpDir $Request.Body.ModuleName

    try {
        Write-Verbose "Attempting to save module..." -Verbose
        Save-Module $Request.Body.ModuleName -Path $tmpDir -ErrorAction Stop
        Write-Verbose "Saved module..." -Verbose
        
        Write-Verbose "Attempting to invoke PSScriptAnalyzer..." -Verbose
        $results = @(Invoke-ScriptAnalyzer -Path $modulePath -Recurse -Settings $settings)
        Write-Verbose "Invoked PSScriptAnalyzer..." -Verbose

        $status = [HttpStatusCode]::OK
    } catch {
        $status = [HttpStatusCode]::BadRequest
        $results = $_
    } finally {
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $modulePath
    }

} else {
    $status = [HttpStatusCode]::BadRequest
    $results = "No script specified in the body."
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = $status
    ContentType = "application/json"
    Body = $results
})
