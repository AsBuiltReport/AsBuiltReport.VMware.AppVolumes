function Get-AbrAppVolADOU {
    <#
    .SYNOPSIS
        Used by As Built Report to retrieve VMware APPVolume Active Directory OU information.
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
        Write-PScriboMessage "ADOus InfoLevel set at $($InfoLevel.AppVolumes.ADOus)."
        Write-PscriboMessage "Collecting Active Directory OU information."
    }

    process {
        if ($InfoLevel.AppVolumes.ADOus -ge 1) {
            try {
                if ($PSVersionTable.PSEdition -eq 'Core') {
                    $ActiveDirectoryOUs = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/org_units"
                } else {$ActiveDirectoryOUs = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/org_units"}

                if ($ActiveDirectoryOUs) {
                    section -Style Heading3 "Managed OUs" {
                        Paragraph "The following section provide a summary of Organizational Units (OUs) that have assignments on $($AppVolServer.split('.')[0])."
                        BlankLine
                        $OutObj = @()
                        foreach ($ActiveDirectoryOU in $ActiveDirectoryOUs.org_units) {
                            try {
                                $inObj = [ordered] @{
                                    'Name' = $ActiveDirectoryOU.Name
                                    'Last Logon' = $ActiveDirectoryOU.last_login_human.split()[0,1,2] -join ' '
                                    'Status' = $ActiveDirectoryOU.status
                                    'Writable' = $ActiveDirectoryOU.writables
                                    'AppStack' = $ActiveDirectoryOU.appstacks
                                    'Assignments' = $ActiveDirectoryOU.application_assignment_count
                                }
                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                            }
                            catch {
                                Write-PscriboMessage -IsWarning $_.Exception.Message
                            }
                        }

                        $TableParams = @{
                            Name = "Managed Ous - $($AppVolServer)"
                            List = $false
                            ColumnWidths = 30, 16, 16, 12, 12, 14
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