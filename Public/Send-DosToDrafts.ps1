<#
.SYNOPSIS
    Wrap output from CMD or PowerShell on Windows and send to Drafts app.
.DESCRIPTION
    Long description
.EXAMPLE
    Send-DosToDrafts tasklist
.EXAMPLE
    Send-DosToDrafts Get-ChildItem | Sort-Object -Property LastWriteTime
.INPUTS
    CMD or PowerShell commands.
.OUTPUTS
   Creates a randomly named text file in the designated DropBox folder -- ~\Dropbox\drafts by default. 
.NOTES
    General notes
.COMPONENT
    Send-ToDrafts 
#>
function Send-DosToDrafts {
    [CmdletBinding(DefaultParameterSetName = 'Parameter Set 1',
        SupportsShouldProcess = $true,
        PositionalBinding = $false,
        HelpUri = 'http://www.microsoft.com/',
        ConfirmImpact = 'Medium')]
    [Alias()]
    [OutputType([String])]
    Param (
        # Valid CMD or PowerShell commands
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $false,
            ValueFromPipelineByPropertyName = $false,
            ValueFromRemainingArguments = $false, 
            ParameterSetName = 'Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $Param1
    )
    
    begin {
    }
    
    process {
        if ($pscmdlet.ShouldProcess("Target", "Operation")) {
            $randomFilename = [System.IO.Path]::GetRandomFileName()
            $draftFile = "~\Dropbox\drafts\" + $randomFilename
            # $Args combine to make the command to be wrapped and executed
            $cmd = $Args -join " "
            $d2u = "dos2unix " + $draftFile

            Write-Host '# command: ' $cmd "`n"
            Write-Host '# command: ' $cmd "`n" *> $draftFile
            Invoke-Expression $cmd
            Invoke-Expression $cmd *>> $draftFile
            do {
                try {
                    Invoke-Expression $d2u
                }
                catch {
                    # error
                } 
            } until ($error.Count -eq 0)           
        }
    }
    
    end {
    }
}
