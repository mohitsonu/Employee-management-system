# Java 21 Installation Script
Write-Host "Installing Java 21..." -ForegroundColor Green

# Create downloads directory if it doesn't exist
$downloadDir = "$env:USERPROFILE\Downloads\Java21"
if (!(Test-Path $downloadDir)) {
    New-Item -ItemType Directory -Path $downloadDir -Force
}

# Download Java 21 (OpenJDK)
$java21Url = "https://download.java.net/java/GA/jdk21.0.2/13d5b2a4be90462f896e6f96bcf36db2/13/GPL/openjdk-21.0.2_windows-x64_bin.zip"
$java21Zip = "$downloadDir\openjdk-21.0.2_windows-x64_bin.zip"
$java21Dir = "$downloadDir\jdk-21.0.2"

Write-Host "Downloading Java 21..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $java21Url -OutFile $java21Zip -UseBasicParsing
    Write-Host "Download completed!" -ForegroundColor Green
} catch {
    Write-Host "Download failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
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

# Set JAVA_HOME environment variable
Write-Host "Setting JAVA_HOME environment variable..." -ForegroundColor Yellow
$javaHome = "$java21Dir\jdk-21.0.2"
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