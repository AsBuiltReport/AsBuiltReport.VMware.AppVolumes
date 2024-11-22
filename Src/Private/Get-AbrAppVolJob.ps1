function Get-AbrAppVolJob {
    <#
    .SYNOPSIS
        Used by As Built Report to retrieve VMware APPVolume Active Directory OU information.
    .DESCRIPTION
        Documents the configuration of VMware APPVolume in Word/HTML/Text formats using PScribo.
    .NOTES
        Version:        1.2.0
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
        Write-PScriboMessage "Jobs InfoLevel set at $($InfoLevel.AppVolumes.Jobs)."
        Write-PScriboMessage "Collecting Job information."
    }

    process {
        if ($InfoLevel.AppVolumes.Jobs -ge 1) {
            try {
                if ($PSVersionTable.PSEdition -eq 'Core') {
                    $Jobs = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/jobs"
                } else { $Jobs = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/jobs" }

                if ($Jobs) {
                    Section -Style Heading3 "Scheduled Jobs" {
                        Paragraph "The following section provide a summary of scheduled jobs for $($AppVolServer.split('.')[0])."
                        BlankLine
                        $OutObj = @()
                        foreach ($Job in $Jobs.jobs) {
                            try {
                                $inObj = [ordered] @{
                                    'Name' = $Job.name
                                    'Status' = $job.status
                                    'Interval' = $Job.interval_in_words
                                    'Last Run At' = $Job.last_run_at
                                }
                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                            } catch {
                                Write-PScriboMessage -IsWarning $_.Exception.Message
                            }
                        }

                        $TableParams = @{
                            Name = "Scheduled Jobs - $($AppVolServer)"
                            List = $false
                            ColumnWidths = 30, 20, 30, 20
                        }
                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $OutObj | Sort-Object -Property Name | Table @TableParams
                    }
                }
            } catch {
                Write-PScriboMessage -IsWarning $_.Exception.Message
            }
        }
    }
    end {}
}