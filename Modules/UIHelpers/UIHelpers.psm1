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
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8" >
    <title>PSScriptAnalyzer</title>
    <link rel="stylesheet" data-name="vs/editor/editor.main" href="https://cdnjs.cloudflare.com/ajax/libs/monaco-editor/0.17.0/min/vs/editor/editor.main.css">
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

function Get-Monaco {
    @'
    <h2>Monaco Editor Sync Loading Sample</h2>
    <div id="container" style="width:800px;height:600px;border:1px solid grey"></div>
    
    <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/monaco-editor/0.17.0/min/vs/loader.js"></script>
    <script>
  require.config({ paths: { 'vs': 'https://cdnjs.cloudflare.com/ajax/libs/monaco-editor/0.17.0/min/vs' }});

  // Before loading vs/editor/editor.main, define a global MonacoEnvironment that overwrites
  // the default worker url location (used when creating WebWorkers). The problem here is that
  // HTML5 does not allow cross-domain web workers, so we need to proxy the instantiation of
  // a web worker through a same-domain script
  window.MonacoEnvironment = {
    getWorkerUrl: function(workerId, label) {
      return `data:text/javascript;charset=utf-8,${encodeURIComponent(`
        self.MonacoEnvironment = {
          baseUrl: 'https://cdnjs.cloudflare.com/ajax/libs/monaco-editor/0.17.0/min/'
        };
        importScripts('https://cdnjs.cloudflare.com/ajax/libs/monaco-editor/0.17.0/min/vs/base/worker/workerMain.js');`
      )}`;
    }
  };

  require(["vs/editor/editor.main"], function () {
    var editor = monaco.editor.create(document.getElementById('container'), {
		value: [
			'function x() {',
			'\tconsole.log("Hello world!");',
			'}'
		].join('\n'),
		language: 'javascript'
	});
  });
  </script>
'@
}

Export-ModuleMember Get-ScriptForm, Build-Html, Get-DiagnosticDisplay, Get-Monaco
