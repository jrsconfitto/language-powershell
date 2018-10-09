# Example from docs: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/where-object?view=powershell-6#examples
# Ref: https://github.com/jrsconfitto/language-powershell/issues/64
Get-Service | Where-Object {$_.Status -eq "Stopped"}
