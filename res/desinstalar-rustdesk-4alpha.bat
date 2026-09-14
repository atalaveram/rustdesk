@echo off
:: Auto-elevate si no hay permisos de administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

setlocal EnableDelayedExpansion
set APP_NAME=rustdesk-4alpha

echo ============================================================
echo  Desinstalador de %APP_NAME%
echo ============================================================
echo.

echo [1/5] Buscando servicios de Windows...
sc query "%APP_NAME%" >nul 2>&1
if %errorLevel% equ 0 (
    sc stop "%APP_NAME%" >nul 2>&1
    timeout /t 2 /nobreak >nul
    sc delete "%APP_NAME%" >nul 2>&1
    echo       Servicio %APP_NAME% eliminado.
) else (
    echo       Servicio %APP_NAME% no encontrado.
)
sc query "RustDesk" >nul 2>&1
if %errorLevel% equ 0 (
    sc stop "RustDesk" >nul 2>&1
    timeout /t 2 /nobreak >nul
    sc delete "RustDesk" >nul 2>&1
    echo       Servicio RustDesk eliminado.
)

echo.
echo [2/5] Eliminando reglas de Firewall...
netsh advfirewall firewall delete rule name="%APP_NAME% Service" >nul 2>&1
netsh advfirewall firewall delete rule name="%APP_NAME%" >nul 2>&1
netsh advfirewall firewall delete rule name="RustDesk Service" >nul 2>&1
netsh advfirewall firewall delete rule name="RustDesk" >nul 2>&1
echo       Reglas de firewall eliminadas.

echo.
echo [3/5] Cerrando procesos activos...
tasklist /FI "IMAGENAME eq rustdesk.exe" 2>nul | find /I "rustdesk.exe" >nul
if %errorLevel% equ 0 (
    taskkill /F /IM rustdesk.exe >nul 2>&1
    echo       Proceso rustdesk.exe cerrado.
) else (
    echo       No hay procesos activos.
)

echo.
echo [4/5] Eliminando carpetas de datos...
if exist "%APPDATA%\%APP_NAME%" (
    rd /s /q "%APPDATA%\%APP_NAME%"
    echo       Eliminada: %APPDATA%\%APP_NAME%
)
if exist "%APPDATA%\RustDesk" (
    rd /s /q "%APPDATA%\RustDesk"
    echo       Eliminada: %APPDATA%\RustDesk
)
if exist "%LOCALAPPDATA%\%APP_NAME%" (
    rd /s /q "%LOCALAPPDATA%\%APP_NAME%"
    echo       Eliminada: %LOCALAPPDATA%\%APP_NAME%
)
if exist "%ProgramData%\%APP_NAME%" (
    rd /s /q "%ProgramData%\%APP_NAME%"
    echo       Eliminada: %ProgramData%\%APP_NAME%
)

echo.
echo [5/5] Limpiando registro de Windows...
reg delete "HKCU\Software\%APP_NAME%" /f >nul 2>&1
reg delete "HKLM\Software\%APP_NAME%" /f >nul 2>&1
reg delete "HKCU\Software\RustDesk" /f >nul 2>&1
reg delete "HKLM\Software\RustDesk" /f >nul 2>&1
echo       Registro limpiado.

echo.
echo ============================================================
echo  Desinstalacion completada correctamente.
echo  Puedes eliminar este archivo .bat manualmente.
echo ============================================================
echo.
pause