function Get-AbrAPPVolManager {
    <#
    .SYNOPSIS
        Used by As Built Report to retrieve VMware APPVolume Appstack information.
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
        Write-PScriboMessage "Manager InfoLevel set at $($InfoLevel.AppVolumes.Managers)."
        Write-PScriboMessage "Collecting Manager information."
    }

    process {
        if ($InfoLevel.AppVolumes.Managers -ge 1) {
            try {
                if ($PSVersionTable.PSEdition -eq 'Core') {
                    $Managers = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/manager_services"
                } else { $Managers = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/manager_services" }

                if ($Managers) {
                    $OutObj = @()
                    Section -Style Heading3 "App Volumes Manager Servers" {
                        Paragraph "The following section details all the App Volumes manager servers on $($AppVolServer.split('.')[0])."
                        BlankLine
                        foreach ($Manager in $Managers.services | Sort-Object -Property Name) {
                            Section -Style Heading4 "App Volumes Manager Server Details - $($AppVolServer.split('.')[0])" {
                                try {
                                    $inObj = [ordered] @{
                                        'Manager Name' = $Manager.name
                                        'Version' = $Manager.internal_version
                                        'Status' = $Manager.status
                                        'First Seen' = $Manager.first_seen_at_human
                                        'Last Seen' = $Manager.last_seen_at_human
                                    }
                                    $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                                } catch {
                                    Write-PScriboMessage -IsWarning $_.Exception.Message
                                }

                                $TableParams = @{
                                    Name = "App Volumes Manager Server Details - $($AppVolServer.split('.')[0])"
                                    List = $false
                                    ColumnWidths = 30, 36, 10, 12, 12
                                }
                                if ($Report.ShowTableCaptions) {
                                    $TableParams['Caption'] = "- $($TableParams.Name)"
                                }
                                $OutObj | Table @TableParams

                            }
                        }
                        if ($InfoLevel.AppVolumes.Managers -ge 2) {
                            $OutObj = @()
                            foreach ($Manager in $Managers.services | Sort-Object -Property Name) {
                                Section -ExcludeFromTOC -Style NOTOCHeading5 "Manager Servers Details - $($Manager.name)" {
                                    try {
                                        $inObj = [ordered] @{
                                            'Product Version' = $Manager.product_version
                                            'Internal Version' = $Manager.internal_version
                                            'Domain Name' = $Manager.domain_name
                                            'Computer Name' = $Manager.computer_name
                                            'Computer FQDN' = $Manager.fqdn
                                            'Registered' = ConvertTo-TextYN $Manager.registered
                                            'Secure' = ConvertTo-TextYN $Manager.secure
                                            'Status' = $Manager.status
                                            'First Seen At' = $Manager.first_seen_at_human
                                            'Last Seen At' = $Manager.last_seen_at_human
                                        }
                                        $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)

                                        $TableParams = @{
                                            Name = "Manager Servers Details - $($Manager.name)"
                                            List = $true
                                            ColumnWidths = 50, 50
                                        }
                                        if ($Report.ShowTableCaptions) {
                                            $TableParams['Caption'] = "- $($TableParams.Name)"
                                        }
                                        $OutObj | Table @TableParams
                                    } catch {
                                        Write-PScriboMessage -IsWarning $_.Exception.Message
                                    }
                                }
                            }


                        }

                    }
                }
            } catch {
                Write-PScriboMessage -IsWarning $_.Exception.Message
            }
        }
    }
    end {}
}