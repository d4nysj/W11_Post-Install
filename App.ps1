# Comprobación de permisos de Administrador
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Warning "El script requiere permisos de Administrador. Reiniciando..."
    Start-Sleep -Seconds 2
    Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Función para pausar y volver al menú
function Pause-Script {
    Write-Host ""
    Write-Host "Presiona cualquier tecla para volver al menú principal..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Bucle principal del menú
while ($true) {
    Clear-Host
    Write-Host "=======================================================" -ForegroundColor Cyan
    Write-Host "      HERRAMIENTA DE POST-INSTALACIÓN WINDOWS 11       " -ForegroundColor White
    Write-Host "=======================================================" -ForegroundColor Cyan
    Write-Host "1. Arreglar búsqueda de W11 (Desactivar Bing web)"
    Write-Host "2. Menú contextual clásico (Quitar el de W11)"
    Write-Host "3. Menú contextual W11 (Restaurar original)"
    Write-Host "4. Ocultar barra de tareas"
    Write-Host "5. Mostrar barra de tareas"
    Write-Host "6. Privacidad y Optimización (Telemetría, Hibernación)"
    Write-Host "7. Ajustes del Explorador (Extensiones y Archivos ocultos)"
    Write-Host "8. Instalar herramientas de sistema y desarrollo (Git, Docker, OpenSSH)"
    Write-Host "0. Salir"
    Write-Host "=======================================================" -ForegroundColor Cyan
    
    $opcion = Read-Host "Selecciona una opción (0-8)"

    switch ($opcion) {
        '1' {
            Write-Host "[*] Desactivando sugerencias web de Bing..." -ForegroundColor Green
            New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Force | Out-Null
            New-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Value 1 -PropertyType DWORD -Force | Out-Null
            Stop-Process -Name explorer -Force
            Write-Host "Completado. Explorador reiniciado." -ForegroundColor Green
            Pause-Script
        }
        '2' {
            Write-Host "[*] Restaurando menú contextual clásico..." -ForegroundColor Green
            New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Value "" -Force | Out-Null
            Stop-Process -Name explorer -Force
            Write-Host "Completado. Explorador reiniciado." -ForegroundColor Green
            Pause-Script
        }
        '3' {
            Write-Host "[*] Restaurando menú contextual por defecto de Windows 11..." -ForegroundColor Green
            Remove-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -Recurse -ErrorAction SilentlyContinue
            Stop-Process -Name explorer -Force
            Write-Host "Completado. Explorador reiniciado." -ForegroundColor Green
            Pause-Script
        }
        '4' {
            Write-Host "[*] Ocultando barra de tareas..." -ForegroundColor Green
            $p = 'HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3'
            $v = (Get-ItemProperty -Path $p).Settings
            $v[8] = 3
            Set-ItemProperty -Path $p -Name Settings -Value $v
            Stop-Process -f -ProcessName explorer
            Write-Host "Completado. Barra de tareas oculta." -ForegroundColor Green
            Pause-Script
        }
        '5' {
            Write-Host "[*] Mostrando barra de tareas..." -ForegroundColor Green
            $p = 'HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3'
            $v = (Get-ItemProperty -Path $p).Settings
            $v[8] = 2
            Set-ItemProperty -Path $p -Name Settings -Value $v
            Stop-Process -f -ProcessName explorer
            Write-Host "Completado. Barra de tareas visible." -ForegroundColor Green
            Pause-Script
        }
        '6' {
            Write-Host "[*] Aplicando ajustes de Privacidad y Optimización..." -ForegroundColor Green
            # Telemetría
            New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -PropertyType DWORD -Force | Out-Null
            # ID de Publicidad
            New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Value 0 -PropertyType DWORD -Force | Out-Null
            # Hibernación
            powercfg.exe /hibernate off
            # Delivery Optimization
            New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" -Name "DODownloadMode" -Value 0 -PropertyType DWORD -Force | Out-Null
            Write-Host "Completado. Se ha liberado espacio y restringido el rastreo." -ForegroundColor Green
            Pause-Script
        }
        '7' {
            Write-Host "[*] Configurando Explorador de Windows..." -ForegroundColor Green
            # Extensiones
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0
            # Archivos ocultos
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1
            # Saltar pantalla de bloqueo
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" -Force | Out-Null
            New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" -Name "NoLockScreen" -Value 1 -PropertyType DWORD -Force | Out-Null
            Stop-Process -Name explorer -Force
            Write-Host "Completado. Explorador configurado." -ForegroundColor Green
            Pause-Script
        }
        '8' {
            Write-Host "[*] Preparando entorno de desarrollo y sistemas..." -ForegroundColor Green
            Write-Host "Instalando Cliente OpenSSH..." -ForegroundColor Cyan
            Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
            
            Write-Host "Habilitando ejecución de scripts locales..." -ForegroundColor Cyan
            Set-ExecutionPolicy RemoteSigned -Force
            
            Write-Host "Instalando utilidades base con Winget (Git, Docker Desktop)..." -ForegroundColor Cyan
            winget install --id=Git.Git -e --accept-source-agreements --accept-package-agreements
            winget install --id=Docker.DockerDesktop -e --accept-source-agreements --accept-package-agreements
            
            Write-Host "Completado. Entorno listo para trabajar." -ForegroundColor Green
            Pause-Script
        }
        '0' {
            Write-Host "Saliendo del script..." -ForegroundColor Yellow
            Start-Sleep -Seconds 1
            exit
        }
        default {
            Write-Warning "Opción no válida. Por favor, selecciona un número del 0 al 8."
            Start-Sleep -Seconds 1
        }
    }
}
