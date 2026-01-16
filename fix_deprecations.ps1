# Fix print -> debugPrint in all Dart files
$files = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart"

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $modified = $false
    
    # Fix print( -> debugPrint( (only standalone print, not debugPrint, blueprint, etc.)
    # Use word boundary to match only 'print(' not 'debugPrint(' or 'blueprint'
    if ($content -match '(?<![a-zA-Z])print\(') {
        $content = $content -replace '(?<![a-zA-Z])print\(', 'debugPrint('
        $modified = $true
    }
    
    if ($modified) {
        Set-Content -Path $file.FullName -Value $content -NoNewline
        Write-Host "Fixed: $($file.Name)"
    }
}

Write-Host "Done!"