function Get-AbrAppVolADOU {
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
        Write-PScriboMessage "ADOus InfoLevel set at $($InfoLevel.AppVolumes.ADOus)."
        Write-PScriboMessage "Collecting Active Directory OU information."
    }

    process {
        if ($InfoLevel.AppVolumes.ADOUs -ge 1) {
            try {
                if ($PSVersionTable.PSEdition -eq 'Core') {
                    $ActiveDirectoryOUs = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/org_units"
                } else { $ActiveDirectoryOUs = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/org_units" }

                if ($ActiveDirectoryOUs) {
                    Section -Style Heading3 "Managed OU's" {
                        Paragraph "The following section provide a summary of Organizational Units (OUs) that have assignments on $($AppVolServer.split('.')[0])."
                        BlankLine
                        $OutObj = @()
                        foreach ($ActiveDirectoryOU in $ActiveDirectoryOUs.org_units) {
                            try {
                                $inObj = [ordered] @{
                                    'Name' = $ActiveDirectoryOU.Name
                                    'Last Logon' = $ActiveDirectoryOU.last_login_human.split()[0, 1, 2] -join ' '
                                    'Status' = $ActiveDirectoryOU.status
                                    'Writable' = $ActiveDirectoryOU.writables
                                    'Assignments' = $ActiveDirectoryOU.application_assignment_count
                                }
                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                            } catch {
                                Write-PScriboMessage -IsWarning $_.Exception.Message
                            }
                        }

                        $TableParams = @{
                            Name = "Managed OU's - $($AppVolServer)"
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