$moduleRoot = Resolve-Path "$PSScriptRoot\.."
$moduleName = Split-Path $moduleRoot -Leaf

# TODO: test the $draftsFolder variable -- does the folder exist?

Describe "General project validation: $moduleName" {

    $scripts = Get-ChildItem $moduleRoot -Include *.ps1, *.psm1, *.psd1 -Recurse

    # TestCases are splatted to the script so we need hashtables
    $testCase = $scripts | Foreach-Object {@{file = $_}}         
    It "Script <file> should be valid powershell" -TestCases $testCase {
        param($file)

        $file.fullname | Should Exist

        $contents = Get-Content -Path $file.fullname -ErrorAction Stop
        $errors = $null
        $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
        $errors.Count | Should Be 0
    }

    It "Module '$moduleName' can import cleanly" {
        {Import-Module (Join-Path $moduleRoot "$moduleName.psm1") -force } | Should Not Throw
    }
}

Describe "$draftsFolder folder tests" {
    It "$draftsFolder folder should exist" {
        Import-Module $moduleRoot -Force

        $errors = $null
        Test-Path $draftsFolder | should be $true
        $errors.Count | Should Be 0
    }

    It "Should have read/write access to $draftsFolder" {
        Import-Module $moduleRoot -Force

        $errors = $null
        $testFile = "$draftsFolder\Send-ToDrafts_test.txt"
        $content = "Hello Test!"
        Set-Content -Path $testFile -Value $content

        Test-Path $testFile | should be $true
        Get-Content $testFile | should match $content 

        Remove-Item -Path $testFile
        Test-Path $testFile | should be $false

        $errors.Count | Should Be 0
    }
}

Describe "Send-DosToDrafts.ps1 tests" {
    Import-Module $moduleRoot -Force

    # With command line Args
    $cmd = "Send-DosToDrafts Get-ChildItem"

    It "Script <$cmd> with Args should create a file in $draftsFolder folder" {
        $beforeCount = (Get-ChildItem $draftsFolder | Measure-Object).Count

        Invoke-Expression $cmd *> $null

        $afterCount = (Get-ChildItem $draftsFolder | Measure-Object).Count
        $afterCount - ($beforeCount + 1) | Should Be 0
        $errors.Count | Should Be 0
    }

    It "Script <$cmd> with Args should remove <CR> characters in $draftsFolder files" {
        $crCount = 0
        Get-ChildItem -Path $draftsFolder/*.* | ForEach-Object {
            $content = [System.IO.File]::ReadAllText($_.FullName)
            if ($content -match "`r") {
                $crCount += 1
            }
        }
        $crCount | Should Be 0
        $errors.Count | Should Be 0
    }

    # With piped Args
    $cmd = "Get-ChildItem | Send-DosToDrafts"

    It "Script <$cmd> with piped Args should create a file in $draftsFolder folder" {
        $beforeCount = (Get-ChildItem $draftsFolder | Measure-Object).Count

        Invoke-Expression $cmd *> $null

        $afterCount = (Get-ChildItem $draftsFolder | Measure-Object).Count
        $afterCount - ($beforeCount + 1) | Should Be 0
        $errors.Count | Should Be 0
    }

    It "Script <$cmd> with piped Args should remove <CR> characters in $draftsFolder files" {
        $crCount = 0

        Get-ChildItem -Path $draftsFolder/*.* | ForEach-Object {
            $content = [System.IO.File]::ReadAllText($_.FullName)
            if ($content -match "`r") {
                $crCount += 1
            }
        }
        $crCount | Should Be 0
        $errors.Count | Should Be 0
    }
}

Describe "Send-ClipboardToDrafts.ps1 tests" {
    Import-Module $moduleRoot -Force

    Set-Clipboard -Value "Hello World. `nTest!"
    $cmd = "Send-ClipboardToDrafts"

    It "Script <$cmd> should create a file in $draftsFolder folder" {
        $beforeCount = (Get-ChildItem $draftsFolder | Measure-Object).Count

        Invoke-Expression $cmd *> $null

        $afterCount = (Get-ChildItem $draftsFolder | Measure-Object).Count
        $afterCount - ($beforeCount + 1) | Should Be 0
        $errors.Count | Should Be 0
    }

    It "Script <$cmd> should remove <CR> characters in $draftsFolder files" {
        $crCount = 0

        Get-ChildItem -Path $draftsFolder/*.* | ForEach-Object {
            $content = [System.IO.File]::ReadAllText($_.FullName)
            if ($content -match "`r") {
                $crCount += 1
            }
        }
        $crCount | Should Be 0
        $errors.Count | Should Be 0
    }
}