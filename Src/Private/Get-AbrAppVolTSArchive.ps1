function Get-AbrAppVolTSArchive {
    <#
    .SYNOPSIS
        Used by As Built Report to retrieve VMware APPVolume Active Directory OU information.
    .DESCRIPTION
        Documents the configuration of VMware APPVolume in Word/HTML/Text formats using PScribo.
    .NOTES
        Version:        1.1.0
        Author:         Chris Hildebrandt, @childebrandt42
        Editor:         Jonathan Colon, @jcolonfzenpr
        Twitter:        @asbuiltreport
        Github:         AsBuiltReport
        Credits:        Iain Brighton (@iainbrighton) - PScribo module


    .LINK
        https://github.com/AsBuiltReport/AsBuiltReport.VMware.AppVolumes
    #>

    [CmdletBinding()]
    param (
    )

    begin {
        Write-PScriboMessage "Troubleshooting Archive InfoLevel set at $($InfoLevel.AppVolumes.Troubleshooting)."
        Write-PscriboMessage "Troubleshooting Archive information."
    }

    process {
        if ($InfoLevel.AppVolumes.Troubleshooting -ge 1) {
            try {
                if ($PSVersionTable.PSEdition -eq 'Core') {
                    $TSAs = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/troubleshooting_archive?"
                } else {$TSAs = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/troubleshooting_archive?"}

                if ($TSAs.trblarchive.data) {
                    section -Style Heading3 "Troubleshooting Archives" {
                        Paragraph "The following section provide a summary of troubleshooting archives for $($AppVolServer.split('.')[0])."
                        BlankLine
                        $OutObj = @()
                        foreach ($TSA in $TSAs.trblarchive.data) {
                            try {
                                $inObj = [ordered] @{
                                    'File Name' = $TSA.filename
                                    'Status' = $TSA.Status
                                    'Size' = $TSA.Size
                                }
                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                            }
                            catch {
                                Write-PscriboMessage -IsWarning $_.Exception.Message
                            }
                        }

                        $TableParams = @{
                            Name = "Troubleshooting Archives - $($AppVolServer)"
                            List = $false
                            ColumnWidths = 70, 15, 15
                        }
                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $OutObj| Sort-Object -Property Name | Table @TableParams
                    }
                }
            }
            catch {
                Write-PscriboMessage -IsWarning $_.Exception.Message
            }
        }
    }
    end {}
}