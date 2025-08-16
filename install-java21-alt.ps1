# Alternative Java 21 Installation Script using Microsoft OpenJDK
Write-Host "Installing Java 21 (Microsoft OpenJDK)..." -ForegroundColor Green

# Create downloads directory if it doesn't exist
$downloadDir = "$env:USERPROFILE\Downloads\Java21"
if (!(Test-Path $downloadDir)) {
    New-Item -ItemType Directory -Path $downloadDir -Force
}

# Download Microsoft OpenJDK 21
$java21Url = "https://aka.ms/download-jdk/microsoft-jdk-21.0.2-windows-x64.zip"
$java21Zip = "$downloadDir\microsoft-jdk-21.0.2-windows-x64.zip"

Write-Host "Downloading Microsoft OpenJDK 21..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $java21Url -OutFile $java21Zip -UseBasicParsing
    Write-Host "Download completed!" -ForegroundColor Green
} catch {
    Write-Host "Download failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Trying alternative download method..." -ForegroundColor Yellow
    
    # Alternative: Use winget to install Java 21
    Write-Host "Attempting to install Java 21 using winget..." -ForegroundColor Yellow
    try {
        winget install Microsoft.OpenJDK.21
        Write-Host "Java 21 installed successfully via winget!" -ForegroundColor Green
        exit 0
    } catch {
        Write-Host "winget installation failed. Please install Java 21 manually." -ForegroundColor Red
        Write-Host "Visit: https://adoptium.net/temurin/releases/?version=21" -ForegroundColor Cyan
        exit 1
    }
}

# Extract Java 21
Write-Host "Extracting Java 21..." -ForegroundColor Yellow
try {
    Expand-Archive -Path $java21Zip -DestinationPath $downloadDir -Force
    Write-Host "Extraction completed!" -ForegroundColor Green
} catch {
    Write-Host "Extraction failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Find the extracted directory
$java21Dir = Get-ChildItem -Path $downloadDir -Directory | Where-Object { $_.Name -like "*jdk*" -or $_.Name -like "*java*" } | Select-Object -First 1
if (!$java21Dir) {
    Write-Host "Could not find Java directory in extracted files" -ForegroundColor Red
    exit 1
}

$javaHome = $java21Dir.FullName

# Set JAVA_HOME environment variable
Write-Host "Setting JAVA_HOME environment variable..." -ForegroundColor Yellow
[Environment]::SetEnvironmentVariable("JAVA_HOME", $javaHome, "User")

# Add Java to PATH
Write-Host "Adding Java to PATH..." -ForegroundColor Yellow
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($currentPath -notlike "*$javaHome\bin*") {
    $newPath = "$currentPath;$javaHome\bin"
    [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
}

Write-Host "Java 21 installation completed!" -ForegroundColor Green
Write-Host "JAVA_HOME set to: $javaHome" -ForegroundColor Cyan
Write-Host "Please restart your terminal/PowerShell to use Java 21" -ForegroundColor Yellow 