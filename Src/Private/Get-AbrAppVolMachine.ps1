function Get-AbrAppVolMachine {
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
        Write-PScriboMessage "Managed Machines InfoLevel set at $($InfoLevel.AppVolumes.Machines)."
        Write-PScriboMessage "Collecting Managed Machines information."
    }

    process {
        if ($InfoLevel.AppVolumes.Machines -ge 1) {
            try {
                if ($PSVersionTable.PSEdition -eq 'Core') {
                    $Machines = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/machines"
                } else { $Machines = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/machines" }

                if ($Machines) {
                    Section -Style Heading3 "Managed Machines Summary" {
                        Paragraph "The following section provide a summary of managed machines on $($AppVolServer.split('.')[0])."
                        BlankLine
                        $OutObj = @()
                        foreach ($Machines in ($Machines.machines | Where-Object { $_.Status -notlike 'Absent' })) {
                            try {
                                $inObj = [ordered] @{
                                    'Name' = $Machines.name
                                    'Host' = $Machines.Host
                                    'Source' = $Machines.Source
                                    'Created' = $Machines.Created_at_human
                                    'Status' = $Machines.Status
                                }
                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                            } catch {
                                Write-PScriboMessage -IsWarning $_.Exception.Message
                            }
                        }

                        $TableParams = @{
                            Name = "Managed Machines Summary - $($AppVolServer)"
                            List = $false
                            ColumnWidths = 34, 24, 16, 12, 14
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