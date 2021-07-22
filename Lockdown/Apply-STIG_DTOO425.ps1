Write-Output "Remediating STIG DTOO425"
reg load "HKU\TEMP" "$env:SystemDrive\Users\Default\NTUSER.DAT"
reg add "HKU\TEMP\SOFTWARE\Policies\Microsoft\Office\14.0\outlook\options\autoformat" /v pgrfafo_25_1 /t REG_DWORD /d 0 /f
reg unload "HKU\TEMP"
reg add "HKCU\SOFTWARE\Policies\Microsoft\Office\14.0\outlook\options\autoformat" /v pgrfafo_25_1 /t REG_DWORD /d 0 /f
Write-Output "Remediation for STIG DTOO425 Completed"