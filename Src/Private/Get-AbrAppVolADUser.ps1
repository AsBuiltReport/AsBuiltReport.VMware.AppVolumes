function Get-AbrAppVolADUser {
    <#
    .SYNOPSIS
        Used by As Built Report to retrieve VMware APPVolume Active Directory users information.
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
        Write-PScriboMessage "ADUsers InfoLevel set at $($InfoLevel.AppVolumes.ADUsers)."
        Write-PscriboMessage "Collecting Active Directory User information."
    }

    process {
        if ($InfoLevel.AppVolumes.ADUsers -ge 1) {
            try {
                $ActiveDirectoryUsers = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/users"
                if ($ActiveDirectoryUsers) {
                    section -Style Heading2 "Managed Users" {
                        $OutObj = @()
                        foreach ($ActiveDirectoryUser in $ActiveDirectoryUsers) {
                            try {
                                $inObj = [ordered] @{
                                    'Name' = $ActiveDirectoryUser.upn
                                    'Last Logon' = $ActiveDirectoryUser.last_login_human.split()[0,1,2] -join ' '
                                    'Status' = $ActiveDirectoryUser.status
                                    'Writable' = $ActiveDirectoryUser.writables
                                    'AppStack' = $ActiveDirectoryUser.appstacks
                                    'Assignments' = $ActiveDirectoryUser.application_assignment_count
                                    'Login' = $ActiveDirectoryUser.logins
                                }
                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                            }
                            catch {
                                Write-PscriboMessage -IsWarning $_.Exception.Message
                            }
                        }

                        $TableParams = @{
                            Name = "Managed Users - $($AppVolServer)"
                            List = $false
                            ColumnWidths = 24, 14, 13, 12, 12, 14, 11
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