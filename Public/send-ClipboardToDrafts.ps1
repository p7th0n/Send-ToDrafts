<#
.SYNOPSIS
   Send clipboard to Drafts app. 
.DESCRIPTION
    Long description
.EXAMPLE
    Copy text to clipboard & run Send-ClipboardToDrafts 
.INPUTS
    Clipboard text. 
.OUTPUTS
    Creates a randomly named text file in the designated DropBox folder -- ~\Dropbox\drafts by default.
.NOTES
    General notes
.COMPONENT
     Send-ToDrafts
#>
function Send-ClipboardToDrafts {
    [CmdletBinding(DefaultParameterSetName = 'Parameter Set 1',
        SupportsShouldProcess = $true,
        PositionalBinding = $false,
        HelpUri = 'http://www.microsoft.com/',
        ConfirmImpact = 'Medium')]
    [Alias()]
    [OutputType([String])]
    Param (
        # Param1 help description
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromRemainingArguments = $false, 
            ParameterSetName = 'Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateCount(0, 5)]
        [ValidateSet("sun", "moon", "earth")]
        [Alias("p1")] 
        $Param1
    )
    
    begin {
    }
    
    process {
        if ($pscmdlet.ShouldProcess("Target", "Operation")) {
            $randomFilename = [System.IO.Path]::GetRandomFileName()
            $draftFile = "~\Dropbox\drafts\" + $randomFilename
            $d2u = "dos2unix " + $draftFile
            # $cmd = $Args -join " "

            Write-Host '# clipboard:`n ' Get-Clipboard "`n"
            Get-Clipboard *> $draftFile
            Invoke-Expression $d2u           
        }
    }
    
    end {
    }
}
