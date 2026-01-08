# Script to add comprehensive prompts to all on-demand process files
# Based on ON-DEMAND_PROMPT_TEMPLATE.md

Write-Output "Adding comprehensive prompts to on-demand process files..."
Write-Output ""

$processTypes = @{
    "test-implementation" = @{
        "type" = "multi-phase"
        "whenToUse" = "When establishing testing infrastructure"
    }
    "ci-cd-github-actions" = @{
        "type" = "multi-phase"
        "whenToUse" = "When setting up CI/CD pipeline with GitHub Actions"
    }
    "code-coverage" = @{
        "type" = "simple"
        "whenToUse" = "When configuring code coverage tracking"
    }
    "docker-containerization" = @{
        "type" = "multi-phase"
        "whenToUse" = "When containerizing application with Docker"
    }
    "logging-observability" = @{
        "type" = "multi-phase"
        "whenToUse" = "When setting up logging and monitoring infrastructure"
    }
    "linting-formatting" = @{
        "type" = "simple"
        "whenToUse" = "When setting up code linting and formatting tools"
    }
    "security-scanning" = @{
        "type" = "simple"
        "whenToUse" = "When setting up security vulnerability scanning"
    }
    "api-documentation-openapi" = @{
        "type" = "simple"
        "whenToUse" = "When setting up OpenAPI/Swagger documentation"
    }
    "authentication-jwt-oauth" = @{
        "type" = "multi-phase"
        "whenToUse" = "When implementing authentication system"
    }
}

$count = 0
$skipped = 0

# Find all on-demand process files
$files = Get-ChildItem -Path ".ai-iap/processes/_ondemand" -Recurse -File -Filter "*.md"

foreach ($file in $files) {
    $processName = $file.BaseName
    $language = $file.Directory.Name
    
    # Check if this file already has comprehensive prompt
    $content = Get-Content $file.FullName -Raw
    if ($content -match "## Usage - Copy This Complete Prompt") {
        Write-Output "  ✅ SKIP: $language/$($file.Name) (already has comprehensive prompt)"
        $skipped++
        continue
    }
    
    # Check if file has Usage section to replace
    if ($content -match "## Usage\s*\r?\n") {
        Write-Output "  🔄 UPDATE: $language/$($file.Name)"
        # Note: Actual content update would require language-specific details
        # This script documents what needs to be done
        $count++
    } else {
        Write-Output "  ➕ ADD: $language/$($file.Name) (needs Usage section added)"
        $count++
    }
}

Write-Output ""
Write-Output "======================================================";
Write-Output "SUMMARY"
Write-Output "======================================================";
Write-Output "  Files with prompts: $skipped"
Write-Output "  Files needing update: $count"
Write-Output ""
Write-Output "NOTE: This script identifies files to update."
Write-Output "Actual updates require language-specific content."
Write-Output "See ON-DEMAND_PROMPT_TEMPLATE.md for guidelines."
