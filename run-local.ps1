# run-local.ps1
# Usage: copy .env.example -> .env and fill values
# Then run: .\run-local.ps1

# Load .env if exists
$envFile = Join-Path (Get-Location) '.env'
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        $_ = $_.Trim()
        if ([string]::IsNullOrWhiteSpace($_) -or $_.StartsWith('#')) { return }
        $parts = $_ -split '=', 2
        if ($parts.Length -eq 2) {
            $name = $parts[0].Trim()
            $value = $parts[1].Trim()
            Set-Item -Path Env:$name -Value $value
        }
    }
    Write-Host ".env carregado"
} else {
    Write-Host "Nenhum arquivo .env encontrado. Você pode setar variáveis manualmente ou criar um .env a partir de .env.example"
}

# If DATABASE_PUBLIC_URL is present but JDBC not, try to parse it
if (-not $env:JDBC_DATABASE_URL -and $env:DATABASE_PUBLIC_URL) {
    $db = $env:DATABASE_PUBLIC_URL
    $pattern = '^postgresql://(?<user>[^:]+):(?<pass>[^@]+)@(?<host>[^:]+):(?<port>\d+)/(?<db>.+)$'
    if ($db -match $pattern) {
        $user = $Matches['user']
        $pass = $Matches['pass']
        $host = $Matches['host']
        $port = $Matches['port']
        $dbname = $Matches['db']
        $env:JDBC_DATABASE_URL = "jdbc:postgresql://$($host):$($port)/$($dbname)"
        $env:JDBC_DATABASE_USERNAME = $user
        $env:JDBC_DATABASE_PASSWORD = $pass
        Write-Host "Parsed DATABASE_PUBLIC_URL -> JDBC_DATABASE_URL set to $env:JDBC_DATABASE_URL"
    } else {
        Write-Host "DATABASE_PUBLIC_URL no formato esperado. Deve ser: postgresql://user:pass@host:port/db"
    }
}

# If JDBC vars still missing, warn
if (-not $env:JDBC_DATABASE_URL) { Write-Warning "JDBC_DATABASE_URL não definido. App usará H2 se perfil prod não for set." }
if (-not $env:JDBC_DATABASE_USERNAME) { Write-Warning "JDBC_DATABASE_USERNAME não definido." }
if (-not $env:JDBC_DATABASE_PASSWORD) { Write-Warning "JDBC_DATABASE_PASSWORD não definido." }

# Default profile to prod if JDBC is present, else dev
if ($env:JDBC_DATABASE_URL) {
    $profile = $env:SPRING_PROFILES_ACTIVE
    if (-not $profile) { $profile = 'prod' }
} else {
    $profile = 'default'
}

Write-Host "Iniciando aplicação com profile: $profile"

# Run via maven wrapper if present, else try java -jar
if (Test-Path '.\mvnw.cmd') {
    $mvnw = Join-Path (Get-Location) 'mvnw.cmd'
    if ($profile -eq 'prod') {
        $args = "-Dspring-boot.run.profiles=prod spring-boot:run"
    } else {
        $args = "spring-boot:run"
    }
    Write-Host "Executando: cmd.exe /c $mvnw $args"
    # Use cmd.exe to avoid PowerShell argument parsing issues with -D properties
    $proc = Start-Process -FilePath 'cmd.exe' -ArgumentList '/c', "$mvnw $args" -NoNewWindow -Wait -PassThru
    if ($proc.ExitCode -ne 0) { Write-Error "mvnw retornou exit code $($proc.ExitCode)" }
} else {
    if (Test-Path 'target\\EncurtaAI-0.0.1-SNAPSHOT.jar') {
        if ($profile -eq 'prod') { java -jar target\\EncurtaAI-0.0.1-SNAPSHOT.jar --spring.profiles.active=prod }
        else { java -jar target\\EncurtaAI-0.0.1-SNAPSHOT.jar }
    } else {
        Write-Error "Não encontrou mvnw.cmd nem o jar. Rode 'mvnw.cmd -DskipTests package' primeiro."
    }
}
