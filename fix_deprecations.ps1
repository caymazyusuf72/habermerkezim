# Add flutter/foundation.dart import to files that use debugPrint
$files = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart"

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    
    # Check if file uses debugPrint but doesn't have foundation import
    if ($content -match 'debugPrint\(' -and $content -notmatch "import 'package:flutter/foundation.dart'") {
        # Check if it already has any flutter import
        if ($content -match "import 'package:flutter/") {
            # Add foundation import after the last flutter import
            $content = $content -replace "(import 'package:flutter/[^']+';)", "`$1`nimport 'package:flutter/foundation.dart';"
        } else {
            # Add at the beginning after any existing imports
            if ($content -match "^(import [^;]+;\s*)+") {
                $content = $content -replace "^(import [^;]+;\s*)+", "`$0import 'package:flutter/foundation.dart';`n"
            } else {
                # No imports, add at the very beginning
                $content = "import 'package:flutter/foundation.dart';`n" + $content
            }
        }
        Set-Content -Path $file.FullName -Value $content -NoNewline
        Write-Host "Added foundation import: $($file.Name)"
    }
}

Write-Host "Done!"