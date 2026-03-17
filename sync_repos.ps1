# Пути к репозиториям
$SourceRepo = Join-Path $env:USERPROFILE "mfua_git"
$TargetRepo = Join-Path $env:USERPROFILE "obs_working_elenen"
$LogFile = Join-Path $PSScriptRoot "repo_sync.log"

# Функция для записи логов
function Write-Log {
    param ([string]$Message)
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content $LogFile "$time  $Message"
    Write-Output "$time  $Message"
}

# Проверка интернета
function Test-Internet {
    try { return Test-Connection -ComputerName gitflic.ru -Count 1 -Quiet -ErrorAction Stop }
    catch { return $false }
}

Write-Log "=== Запуск синхронизации ==="

if (-not (Test-Internet)) {
    Write-Log "Нет доступа к gitflic.ru — пропуск"
    exit
}
Write-Log "Интернет доступен"

# Проверка исходного репозитория
if (!(Test-Path $SourceRepo)) {
    Write-Log "Исходный репозиторий не найден: $SourceRepo"
    exit
}

# ===== Обновление исходного репозитория =====
Set-Location $SourceRepo

git pull 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Log "Ошибка при git pull"
    exit
}

Write-Log "mfua_git обновлён"

# ===== Копирование файлов (без .git) =====
Write-Log "Копирование файлов в obs_working_elenen"

if (!(Test-Path $TargetRepo)) {
    New-Item -ItemType Directory -Path $TargetRepo | Out-Null
}

Get-ChildItem -Path $SourceRepo -Recurse -Force |
Where-Object { $_.FullName -notmatch "\\.git" } |
ForEach-Object {
    $relativePath = $_.FullName.Substring($SourceRepo.Length).TrimStart("\")
    $destination = Join-Path $TargetRepo $relativePath

    if ($_.PSIsContainer) {
        if (!(Test-Path $destination)) { New-Item -ItemType Directory -Path $destination | Out-Null }
    } else {
        Copy-Item -Path $_.FullName -Destination $destination -Force
    }
}

Write-Log "Файлы скопированы"

# ===== Commit и push если есть изменения =====
Set-Location $TargetRepo
$changes = git status --porcelain

if ($changes) {
    git add . 2>&1 | Out-Null
    git commit -m "Авто-синхронизация" 2>&1 | Out-Null
    git push origin master 2>&1 | Out-Null   # <- пуш в master
    if ($LASTEXITCODE -eq 0) { Write-Log "Изменения отправлены в удалённый репозиторий" }
    else { Write-Log "Ошибка при git push" }
} else {
    Write-Log "Изменений нет"
}

Write-Log "=== Синхронизация завершена ==="