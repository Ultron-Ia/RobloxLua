@echo off
setlocal
:: Check for Administrator privileges
net session >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] Running as Administrator.
) else (
    echo [!] ERROR: Please run this batch file as Administrator.
    pause
    exit /b
)

set SERVICE_NAME=EternalKernel
set REG_PATH=\Registry\Machine\System\CurrentControlSet\Services\%SERVICE_NAME%

echo [1/3] Unloading driver via Native API (NtUnloadDriver)...
powershell -Command "$sig = '[DllImport(\"ntdll.dll\")] public static extern uint NtUnloadDriver(ref UNICODE_STRING serviceName); [StructLayout(LayoutKind.Sequential)] public struct UNICODE_STRING { public ushort Length; public ushort MaximumLength; public IntPtr Buffer; }'; $type = Add-Type -MemberDefinition $sig -Name 'NativeMethods' -Namespace 'Kernel' -PassThru; $us = New-Object Kernel.UNICODE_STRING; $bytes = [System.Text.Encoding]::Unicode.GetBytes('%REG_PATH%'); $buf = [Runtime.InteropServices.Marshal]::AllocHGlobal($bytes.Length + 2); [Runtime.InteropServices.Marshal]::Copy($bytes, 0, $buf, $bytes.Length); [Runtime.InteropServices.Marshal]::WriteInt16($buf, $bytes.Length, 0); $us.Length = $bytes.Length; $us.MaximumLength = $bytes.Length + 2; $us.Buffer = $buf; $status = $type::NtUnloadDriver([ref]$us); [Runtime.InteropServices.Marshal]::FreeHGlobal($buf); if ($status -eq 0) { Write-Host '[OK] Driver unloaded successfully.' -ForegroundColor Green } else { Write-Host ('[!] NtUnloadDriver failed with status: 0x' + $status.ToString('X')) -ForegroundColor Yellow }"

echo [2/3] Cleaning up registry...
reg delete "HKLM\System\CurrentControlSet\Services\%SERVICE_NAME%" /f >nul 2>&1

echo [3/3] Deleting driver file...
:: Give the OS a moment to release the file handle
timeout /t 2 /nobreak >nul
del /f /q "%TEMP%\%SERVICE_NAME%.sys"

if exist "%TEMP%\%SERVICE_NAME%.sys" (
    echo [!] File still exists. You might need to RESTART your computer if the unload failed.
) else (
    echo [OK] Driver completely removed.
)

echo.
pause
