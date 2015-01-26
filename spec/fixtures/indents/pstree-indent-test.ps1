$ProcessesById = @{}
foreach ($Process in (Get-WMIObject -Class Win32_Process)) {
  $ProcessesById[$Process.ProcessId] = $Process
}

$ProcessesWithoutParents = @()
$ProcessesByParent = @{}
foreach ($Pair in $ProcessesById.GetEnumerator()) {
  $Process = $Pair.Value

  if (($Process.ParentProcessId -eq 0) -or !$ProcessesById.ContainsKey($Process.ParentProcessId)) {
    $ProcessesWithoutParents += $Process
    continue
  }

  if (!$ProcessesByParent.ContainsKey($Process.ParentProcessId)) {
    $ProcessesByParent[$Process.ParentProcessId] = @()
  }
  $Siblings = $ProcessesByParent[$Process.ParentProcessId]
  $Siblings += $Process
  $ProcessesByParent[$Process.ParentProcessId] = $Siblings
}

function Show-ProcessTree([UInt32]$ProcessId, $IndentLevel) {
  $Process = $ProcessesById[$ProcessId]
  $Indent = " " * $IndentLevel
  if ($Process.CommandLine) {
    $Description = $Process.CommandLine
  } else {
    $Description = $Process.Caption
  }

  Write-Output ("{0,6}{1} {2}" -f $Process.ProcessId, $Indent, $Description)
  foreach ($Child in ($ProcessesByParent[$ProcessId] | Sort-Object CreationDate)) {
    Show-ProcessTree $Child.ProcessId ($IndentLevel + 4)
  }
}

Write-Output ("{0,6} {1}" -f "PID", "Command Line")
Write-Output ("{0,6} {1}" -f "---", "------------")

foreach ($Process in ($ProcessesWithoutParents | Sort-Object CreationDate)) {
  Show-ProcessTree $Process.ProcessId 0
}
