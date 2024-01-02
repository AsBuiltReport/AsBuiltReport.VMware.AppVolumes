function Get-AbrAppVolADUser {
    <#
    .SYNOPSIS
        Used by As Built Report to retrieve VMware APPVolume Active Directory users information.
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
        Write-PScriboMessage "ADUsers InfoLevel set at $($InfoLevel.AppVolumes.ADUsers)."
        Write-PscriboMessage "Collecting Active Directory User information."
    }

    process {
        if ($InfoLevel.AppVolumes.ADUsers -ge 1) {
            try {
                if ($PSVersionTable.PSEdition -eq 'Core') {
                    $ActiveDirectoryUsers = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/users"
                } else {$ActiveDirectoryUsers = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/users"}

                if ($ActiveDirectoryUsers) {
                    section -Style Heading3 "Managed Users" {
                        Paragraph "The following section provide a summary of Users who have logged-in to a managed computer or have assignments on $($AppVolServer.split('.')[0])."
                        Blankline
                        $OutObj = @()
                        foreach ($ActiveDirectoryUser in $ActiveDirectoryUsers) {
                            if ($ActiveDirectoryUser) {
                                if($ActiveDirectoryUser.last_login_human){
                                    $LastLogonUser = $ActiveDirectoryUser.last_login_human.split()[0,1,2] -join ' '
                                }else{
                                    $LastLogonUser = "Never"
                                }
                                try {
                                    $inObj = [ordered] @{
                                        'Name' = $ActiveDirectoryUser.upn
                                        'Writable' = $ActiveDirectoryUser.writables
                                        'Assignments' = $ActiveDirectoryUser.application_assignment_count
                                        'Attachments' = $ActiveDirectoryUser.attachments
                                        'Login' = $ActiveDirectoryUser.logins
                                        'Last Logon' = $LastLogonUser
                                        'Status' = $ActiveDirectoryUser.status
                                    }
                                    $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                                }
                                catch {
                                    Write-PscriboMessage -IsWarning $_.Exception.Message
                                }
                            }
                        }

                        $TableParams = @{
                            Name = "Managed Users - $($AppVolServer)"
                            List = $false
                            ColumnWidths = 26, 12, 14, 14, 10, 14, 10
                        }
                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $OutObj| Sort-Object -Property upn | Table @TableParams
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