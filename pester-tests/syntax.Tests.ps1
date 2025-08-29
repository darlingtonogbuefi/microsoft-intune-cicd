<#
    .SYNOPSIS
        Pester tests to validate PowerShell scripts located in folder defined by pipeline variables.
#>

param ()

BeforeDiscovery {
    # Use pipeline variables from environment
    $scriptRoot = Join-Path -Path $env:System_DefaultWorkingDirectory -ChildPath $env:SCRIPT_FOLDER
    $testRoot = Join-Path -Path $env:System_DefaultWorkingDirectory -ChildPath $env:TEST_FOLDER

    # Get all .ps1 scripts in script folder (excluding *Tests.ps1)
    $Scripts = Get-ChildItem -Path $scriptRoot -Recurse -Filter '*.ps1' -File |
               Where-Object { $_.Name -notlike '*Tests.ps1' }

    # Prepare hashtables for TestCases
    $TestCases = $Scripts | ForEach-Object { @{ file = $_ } }
}

Describe "General project validation" {

    It "Script <file.Name> should exist" -TestCases $TestCases {
        param ($file)
        $file.FullName | Should -Exist
    }

    It "Script <file.Name> should be valid PowerShell" -TestCases $TestCases {
        param ($file)
        $contents = Get-Content -Path $file.FullName -ErrorAction Stop
        $errors = $null
        $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
        $errors.Count | Should -Be 0
    }
}
