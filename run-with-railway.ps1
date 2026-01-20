# run-with-railway.ps1 - helper to parse Railway DATABASE_URL and run app
# Usage: set DATABASE_URL env var (or paste when prompted) and run this script.

if (-not $env:DATABASE_URL -or $env:DATABASE_URL -eq "") {
    $DATABASE_URL = Read-Host "Cole aqui a DATABASE_URL do Railway (ex: postgres://user:pass@host:port/dbname)"
} else {
    $DATABASE_URL = $env:DATABASE_URL
}

$pattern = '^postgres://(?<user>[^:]+):(?<pass>[^@]+)@(?<host>[^:/]+)(:(?<port>\d+))?/(?<db>.+)$'
if ($DATABASE_URL -notmatch $pattern) {
    Write-Error "Formato inesperado. Deve ter a forma: postgres://user:pass@host:port/dbname"
    exit 1
}

$user = $Matches['user']
$pass = $Matches['pass']
$host = $Matches['host']
$port = $Matches['port']
if (-not $port) { $port = '5432' }
$dbname = $Matches['db']

$env:JDBC_DATABASE_URL = "jdbc:postgresql://$($host):$($port)/$($dbname)"
$env:JDBC_DATABASE_USERNAME = $user
$env:JDBC_DATABASE_PASSWORD = $pass

Write-Host "Host detectado: $($host):$($port)  DB: $dbname"
Write-Host "JDBC_DATABASE_URL set to: $env:JDBC_DATABASE_URL"

# Test DNS/TCP
Write-Host '--- Teste DNS ---'
nslookup $host
Write-Host '--- Teste TCP (porta) ---'
Test-NetConnection -ComputerName $host -Port $port -InformationLevel Detailed

# Run mvnw via cmd.exe to avoid PowerShell parsing of -D properties
$mvnw = Join-Path (Get-Location) 'mvnw.cmd'
if (Test-Path $mvnw) {
    Write-Host "Iniciando app via mvnw (profile=prod)..."
    $args = "$mvnw -Dspring-boot.run.profiles=prod spring-boot:run"
    Write-Host "Executando: cmd.exe /c $args"
    Start-Process -FilePath 'cmd.exe' -ArgumentList '/c', $args -NoNewWindow -Wait
} else {
    Write-Host "mvnw.cmd não encontrado, tentando executar jar..."
    if (Test-Path 'target\EncurtaAI-0.0.1-SNAPSHOT.jar') {
        & java -jar target\EncurtaAI-0.0.1-SNAPSHOT.jar --spring.profiles.active=prod
    } else {
        Write-Error "Nenhum mvnw.cmd nem jar encontrado. Rode 'mvnw.cmd -DskipTests package' primeiro."
    }
}
