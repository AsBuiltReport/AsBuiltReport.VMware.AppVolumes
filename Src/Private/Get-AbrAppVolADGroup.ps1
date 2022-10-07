function Get-AbrAppVolADGroup {
    <#
    .SYNOPSIS
        Used by As Built Report to retrieve VMware APPVolume Active Directory groups information.
    .DESCRIPTION
        Documents the configuration of VMware APPVolume in Word/HTML/Text formats using PScribo.
    .NOTES
        Version:        0.2.0
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
        Write-PscriboMessage "Collecting Active Directory Group information."
    }

    process {
        if ($InfoLevel.AppVolumes.ADGroups -ge 1) {
            try {
                 $ActiveDirectoryGroups = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/groups"
                if ($ActiveDirectoryGroups) {
                    section -Style Heading3 "Managed Groups" {
                        Paragraph "The following section provide a summary of Groups that have assignments on $($AppVolServer.split('.')[0])."
                        BlankLine
                        $OutObj = @()
                        foreach ($ActiveDirectoryGroup in $ActiveDirectoryGroups.groups) {
                            try {
                                $inObj = [ordered] @{
                                    'Name' = $ActiveDirectoryGroup.Name
                                    'Last Logon' = $ActiveDirectoryGroup.last_login_human.split()[0,1,2] -join ' '
                                    'Status' = $ActiveDirectoryGroup.status
                                    'Writable' = $ActiveDirectoryGroup.writables
                                    'AppStack' = $ActiveDirectoryGroup.appstacks
                                    'Assignments' = $ActiveDirectoryGroup.application_assignment_count
                                }
                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                            }
                            catch {
                                Write-PscriboMessage -IsWarning $_.Exception.Message
                            }
                        }

                        $TableParams = @{
                            Name = "Managed Groups - $($AppVolServer)"
                            List = $false
                            ColumnWidths = 30, 16, 16, 12, 12, 14
                        }
                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $OutObj | Sort-Object -Property Name | Table @TableParams
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