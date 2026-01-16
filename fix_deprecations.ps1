# Fix withOpacity and surfaceVariant deprecations in all Dart files
$files = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart"

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $modified = $false
    
    if ($content -match '\.withOpacity\(') {
        $content = $content -replace '\.withOpacity\(', '.withValues(alpha: '
        $modified = $true
    }
    
    if ($content -match 'colorScheme\.surfaceVariant') {
        $content = $content -replace 'colorScheme\.surfaceVariant', 'colorScheme.surfaceContainerHighest'
        $modified = $true
    }
    
    if ($modified) {
        Set-Content -Path $file.FullName -Value $content -NoNewline
        Write-Host "Fixed: $($file.Name)"
    }
}

Write-Host "Done!"