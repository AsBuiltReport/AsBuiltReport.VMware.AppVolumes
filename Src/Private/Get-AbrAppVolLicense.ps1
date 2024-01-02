function Get-AbrAPPVolLicense {
    <#
    .SYNOPSIS
        Used by As Built Report to retrieve VMware APPVolume License information.
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
        Write-PScriboMessage "License InfoLevel set at $($InfoLevel.AppVolumes.License)."
        Write-PscriboMessage "Collecting License information."
    }

    process {
        if ($InfoLevel.AppVolumes.License -ge 1) {
            try {
                if ($PSVersionTable.PSEdition -eq 'Core') {
                    $License = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/license"
                } else {$License = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/license"}

                if ($License) {
                    $OutObj = @()
                    section -Style Heading3 "License Information" {
                        Paragraph "The following section details license information for $($AppVolServer.split('.')[0])."
                        BlankLine

                        Switch ($License.license.invalid)
                        {
                            'True' {$LicenseInvalid = 'False' }
                            'False' {$LicenseInvalid = 'True' }
                        }
                        $inObj = [ordered] @{
                            'Key Create Date' = $License.license.Keycreate
                            'Key Valid' = ConvertTo-TextYN $LicenseInvalid
                            'Limit Users' = $License.license.details.users
                            'Usage Users' = $License.license.usage.Users
                            'Limit Desktops' = $License.license.details.Desktops
                            'Usage Desktops' = $License.license.usage.Desktops
                            'Limit Servers' = $License.license.details.Servers
                            'Usage Server' = $License.license.usage.Servers
                            'Limit Concurrent Users' = $License.license.details.'Concurrent Users'
                            'Usage Concurrent Users' = $License.license.usage.'Concurrent Users'
                            'Limit Concurrent Desktops' = $License.license.details.'Concurrent Desktops'
                            'Usage Concurrent Desktops' = $License.license.usage.'Concurrent Desktops'
                            'Limit Concurrent Servers' = $License.license.details.'Concurrent Servers'
                            'Usage Concurrent Servers' = $License.license.usage.'Concurrent Servers'
                            'Limit Terminal Users' = $License.license.details.'Terminal Users'
                            'Usage Terminal Users' = $License.license.usage.'Terminal Users'
                            'Limit Concurrent Terminal Users' = $License.license.details.'Concurrent Terminal Users'
                            'Usage Concurrent Terminal Users' = $License.license.usage.'Concurrent Terminal Users'
                            'Limit Max Attachments Per User' = $License.license.details.'Max Attachments Per User'
                            'Limit Writable Volumes' = $License.license.details.'Writable Volumes'
                            'Limit License Mode' = $License.license.details.'License Mode'
                            'Limit Attach User Volumes' = $License.license.details.'Attach User Volumes'
                            'Issued Date' = $License.license.details.Issued
                            'Valid After Date' = $License.license.details.'Valid After'
                            'Valid Until Date' = $License.license.details.'Valid Until'
                            'Options' = $License.license.details.Options
                        }
                        $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)

                        $TableParams = @{
                            Name = "License - $($AppVolServer)"
                            List = $true
                            ColumnWidths = 50, 50
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