$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$baseHref = '/v2/site/'
$siteUrl = 'https://costeira.app.br/v2/site'

Set-Location $root

Write-Host 'Limpando build anterior...'
& flutter clean
if ($LASTEXITCODE -ne 0) {
  throw 'flutter clean falhou.'
}

Write-Host 'Atualizando dependencias...'
& flutter pub get
if ($LASTEXITCODE -ne 0) {
  throw 'flutter pub get falhou.'
}

Write-Host "Gerando build web release com base href $baseHref..."
& flutter build web --release --base-href $baseHref
if ($LASTEXITCODE -ne 0) {
  throw 'flutter build web falhou.'
}

$builtIndexPath = Join-Path $root 'build/web/index.html'
if (-not (Test-Path -LiteralPath $builtIndexPath)) {
  throw 'Build gerado sem build/web/index.html.'
}
if ((Get-Item -LiteralPath $builtIndexPath).Length -eq 0) {
  throw 'Build gerado com build/web/index.html vazio.'
}

$builtIndex = Get-Content -Raw -LiteralPath $builtIndexPath
if ($builtIndex -notmatch [regex]::Escape("<base href=`"$baseHref`">")) {
  throw "Build gerado sem <base href=`"$baseHref`">. Verifique o --base-href."
}

# O Flutter nem sempre copia arquivos ocultos. Gera o .htaccess diretamente
# no pacote final com as rotas da SPA alinhadas ao endereco de publicacao.
$htaccessPath = Join-Path $root 'build/web/.htaccess'
$htaccessContent = @"
DirectoryIndex index.html

<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase $baseHref

  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteCond %{REQUEST_URI} !\.(js|mjs|css|json|map|png|jpg|jpeg|gif|svg|ico|webp|wasm|bin|ttf|otf|woff|woff2)$ [NC]
  RewriteRule . /v2/site/index.html [L]
</IfModule>
"@
[System.IO.File]::WriteAllText(
  $htaccessPath,
  ($htaccessContent.TrimEnd() + [Environment]::NewLine),
  [System.Text.UTF8Encoding]::new($false)
)

if (-not (Test-Path -LiteralPath $htaccessPath)) {
  throw 'Falha ao gerar build/web/.htaccess.'
}

# Evita publicar arquivos locais que servidores Apache costumam bloquear.
Get-ChildItem -Path (Join-Path $root 'build/web') -Recurse -Filter '.env' -Force -ErrorAction SilentlyContinue |
  ForEach-Object {
    Write-Host "Removendo asset $($_.FullName)..."
    Remove-Item -LiteralPath $_.FullName -Force
  }

$buildPath = Join-Path $root 'build/web'
$criticalFiles = @(
  'index.html',
  'flutter_bootstrap.js',
  'main.dart.js',
  'manifest.json',
  'version.json',
  'assets/AssetManifest.bin.json',
  'assets/icon/noti.svg',
  '.htaccess'
)

foreach ($relativePath in $criticalFiles) {
  $criticalPath = Join-Path $buildPath $relativePath
  if (-not (Test-Path -LiteralPath $criticalPath)) {
    throw "Build incompleto: arquivo ausente: $relativePath"
  }
  if ((Get-Item -LiteralPath $criticalPath).Length -eq 0) {
    throw "Build incompleto: arquivo vazio: $relativePath"
  }
}

$archivePath = Join-Path $root 'build/costeira-web.zip'
if (Test-Path -LiteralPath $archivePath) {
  Remove-Item -LiteralPath $archivePath -Force
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory(
  $buildPath,
  $archivePath,
  [System.IO.Compression.CompressionLevel]::Optimal,
  $false
)

$archive = [System.IO.Compression.ZipFile]::OpenRead($archivePath)
try {
  foreach ($relativePath in @('index.html', '.htaccess')) {
    $entry = $archive.Entries | Where-Object { $_.FullName -eq $relativePath }
    if ($null -eq $entry -or $entry.Length -eq 0) {
      throw "Pacote ZIP invalido: $relativePath ausente ou vazio."
    }
  }
}
finally {
  $archive.Dispose()
}

Write-Host "Build web gerado em build/web."
Write-Host "Pacote para upload gerado em build/costeira-web.zip."
Write-Host "Extraia o ZIP diretamente na pasta publicada em $siteUrl."
