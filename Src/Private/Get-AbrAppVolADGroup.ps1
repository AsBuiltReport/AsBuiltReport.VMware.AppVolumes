function Get-AbrAppVolADGroup {
    <#
    .SYNOPSIS
        Used by As Built Report to retrieve VMware APPVolume Active Directory groups information.
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
        Write-PScriboMessage "ADGroups InfoLevel set at $($InfoLevel.AppVolumes.ADGroups)."
        Write-PScriboMessage "Collecting Active Directory Group information."
    }

    process {
        if ($InfoLevel.AppVolumes.ADGroups -ge 1) {
            try {
                if ($PSVersionTable.PSEdition -eq 'Core') {
                    $ActiveDirectoryGroups = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/groups"
                } else { $ActiveDirectoryGroups = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/groups" }
                if ($ActiveDirectoryGroups) {
                    Section -Style Heading3 "Managed Groups" {
                        Paragraph "The following section provide a summary of Groups that have assignments on $($AppVolServer.split('.')[0])."
                        BlankLine
                        $OutObj = @()
                        foreach ($ActiveDirectoryGroup in $ActiveDirectoryGroups.groups) {
                            try {
                                $inObj = [ordered] @{
                                    'Group Name' = $ActiveDirectoryGroup.Name
                                    'Writable' = $ActiveDirectoryGroup.writables
                                    'Assignments' = $ActiveDirectoryGroup.application_assignment_count
                                    'Last Logon' = $ActiveDirectoryGroup.last_login_human.split()[0, 1, 2] -join ' '
                                    'Status' = $ActiveDirectoryGroup.status
                                }
                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                            } catch {
                                Write-PScriboMessage -IsWarning $_.Exception.Message
                            }
                        }

                        $TableParams = @{
                            Name = "Managed Groups - $($AppVolServer)"
                            List = $false
                            ColumnWidths = 30, 15, 15, 25, 15
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