function Get-ScriptForm {
    param (
        $Script = '$a = 1'
    )
@"
<form action="ProcessScript" method="post">
    <textarea name="script" id="script" cols="30" rows="10">$Script</textarea>
    <button type="submit">Run PSScriptAnalyzer</button>
</form>
"@
}

function Build-Html {
    param (
        [string[]]
        $Content
    )
@"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>PSScriptAnalyzer</title>
</head>
<body>
$($Content -join "`n")
</body>
</html>
"@
}

function Get-DiagnosticDisplay {
    param (
        [Parameter()]
        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]]
        $DiagnosticRecord
    )

    $html = "<ul>"
    foreach ($dr in $DiagnosticRecord) {
        $html += "<li>$($dr.RuleName) (L$($dr.Line) C$($dr.Column)): $($dr.Message)</li>"
    }
    $html += "</ul>"
    $html
}

Export-ModuleMember Get-ScriptForm, Build-Html, Get-DiagnosticDisplay
