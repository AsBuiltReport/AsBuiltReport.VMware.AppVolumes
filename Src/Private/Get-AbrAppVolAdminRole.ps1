function Get-AbrAppVolAdminRole {
    <#
    .SYNOPSIS
        Used by As Built Report to retrieve VMware APPVolume Administrator Roles information.
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
        Write-PScriboMessage "AdminGroups InfoLevel set at $($InfoLevel.AppVolumes.AdminGroups)."
        Write-PscriboMessage "Collecting Administrator Roles information."
    }

    process {
        if ($InfoLevel.AppVolumes.AdminGroups -ge 1) {
            try {
                $AdminGroups = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/group_permissions"
                if ($AdminGroups) {
                    section -Style Heading2 "Administrator Roles" {
                        $OutObj = @()
                        foreach ($AdminGroup in $AdminGroups.group_permissions) {
                            try {
                                $inObj = [ordered] @{
                                    'Group UPN' = $AdminGroup.assignee_upn
                                    'Role' = $AdminGroup.Role
                                    'Type' = $AdminGroup.assignee_type
                                    'Created at' = ([DateTime]$AdminGroup.created_at).ToShortDateString()
                                }
                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                            }
                            catch {
                                Write-PscriboMessage -IsWarning $_.Exception.Message
                            }
                        }

                        $TableParams = @{
                            Name = "Administrators Roles - $($AppVolServer)"
                            List = $false
                            ColumnWidths = 40, 30, 15, 15
                        }
                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $OutObj | Table @TableParams
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