function Get-AbrAppVolMachineManager {
    <#
    .SYNOPSIS
        Used by As Built Report to retrieve VMware APPVolume Administrator Roles information.
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
        Write-PScriboMessage "MachineManagers InfoLevel set at $($InfoLevel.AppVolumes.MachineManagers)."
        Write-PscriboMessage "Collecting Machine Managers information."
    }

    process {
        if ($InfoLevel.AppVolumes.MachineManagers -ge 1) {
            try {
                if ($PSVersionTable.PSEdition -eq 'Core') {
                    $MachineManagers = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/machine_managers"
                } else {$MachineManagers = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/machine_managers"}

                if ($MachineManagers) {
                    section -Style Heading3 "Machine Managers" {
                        Paragraph "The following section provide a summary of machine managers for $($AppVolServer.split('.')[0])."
                        BlankLine
                        $OutObj = @()
                        foreach ($MachineManager in $MachineManagers.machine_managers | Sort-Object -Property Host) {
                            section -Style Heading4 "Machine Manager Summary" {
                                $OutObj = @()
                                foreach ($MachineManager in $MachineManagers.machine_managers | Sort-Object -Property Host) {
                                    try {
                                        $inObj = [ordered] @{
                                            'Host' = $MachineManager.host
                                            "Username" = $MachineManager.username
                                            'Type' = $MachineManager.type
                                        }
                                        $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                                    }
                                    catch {
                                        Write-PscriboMessage -IsWarning $_.Exception.Message
                                    }
                                }

                                $TableParams = @{
                                    Name = "Machine Managers - $($AppVolServer)"
                                    List = $false
                                    ColumnWidths = 40, 40, 20
                                }
                                if ($Report.ShowTableCaptions) {
                                    $TableParams['Caption'] = "- $($TableParams.Name)"
                                }
                                $OutObj | Table @TableParams
                            }
                        }

                        if ($InfoLevel.AppVolumes.MachineManagers -ge 2) {
                            $OutObj = @()
                            foreach ($MachineManager in $MachineManagers.machine_managers | Sort-Object -Property Host) {
                                section -ExcludeFromTOC -Style NOTOCHeading5 "Machine Manager Details - $($MachineManager.host)" {

                                    if ($PSVersionTable.PSEdition -eq 'Core') {
                                        $MachineManagerDetail = (Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/machine_managers/$($MachineManager.id)").machine_manager
                                    } else {$MachineManagerDetail = (Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/machine_managers/$($MachineManager.id)").machine_manager}
                                        try {
                                        $inObj = [ordered] @{
                                            'Type' = $MachineManagerDetail.type
                                            'Host Name' = $MachineManagerDetail.host
                                            'Username' = $MachineManagerDetail.host_username
                                            'Fast Attach' = $MachineManagerDetail.settings.fast_attach
                                            'Mount ESXi' = $MachineManagerDetail.settings.mount_on_host
                                            'ESXi Username' = $MachineManagerDetail.host_username
                                            'Use Local Volumes' = $MachineManagerDetail.settings.use_local_volumes
                                            'Use Reconfigure Queues' = $MachineManagerDetail.settings.use_async
                                            'Use Async' = $MachineManagerDetail.settings.fast_attach
                                            'Concurrent Mount Operations' = $MachineManagerDetail.settings.concurrent_reconfigs
                                            'SSL Validation' = $MachineManagerDetail.ssl_validation_enabled
                                            'SSL Fingerprint' = $MachineManagerDetail.ssl_fingerprint
                                        }
                                        $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)


                                        $TableParams = @{
                                            Name = "Machine Manager Details - $($MachineManager.host)"
                                            List = $true
                                            ColumnWidths = 50, 50
                                        }
                                        if ($Report.ShowTableCaptions) {
                                            $TableParams['Caption'] = "- $($TableParams.Name)"
                                        }
                                        $OutObj | Table @TableParams
                                    }
                                    catch {
                                        Write-PscriboMessage -IsWarning $_.Exception.Message
                                    }
                                }
                            }
                        }
                        <#
                        if ($InfoLevel.AppVolumes.MachineManagers -ge 2) {
                            $OutObj = @()
                            foreach ($MachineManager in $MachineManagers.machine_managers | Sort-Object -Property Host) {
                                section -ExcludeFromTOC -Style NOTOCHeading5 "Machine Manager Certficate Details - $($MachineManager.host)" {

                                    if ($PSVersionTable.PSEdition -eq 'Core') {
                                        $MachineManagerDetail = (Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/machine_managers/$($MachineManager.id)").machine_manager
                                    } else {$MachineManagerDetail = (Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/machine_managers/$($MachineManager.id)").machine_manager}
                                        try {
                                        $inObj = [ordered] @{
                                            'Type' = $MachineManagerDetail.type
                                            'Host Name' = $MachineManagerDetail.host
                                            'Username' = $MachineManagerDetail.host_username
                                            'Fast Attach' = $MachineManagerDetail.settings.fast_attach
                                            'Mount ESXi' = $MachineManagerDetail.settings.mount_on_host
                                            'ESXi Username' = $MachineManagerDetail.host_username
                                            'Use Local Volumes' = $MachineManagerDetail.settings.use_local_volumes
                                            'Use Reconfigure Queues' = $MachineManagerDetail.settings.use_async
                                            'Use Async' = $MachineManagerDetail.settings.fast_attach
                                            'Concurrent Mount Opperations' = $MachineManagerDetail.settings.concurrent_reconfigs
                                        }
                                        $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)


                                        $TableParams = @{
                                            Name = "Machine Manager Certficate Details - $($MachineManager.host)"
                                            List = $true
                                            ColumnWidths = 50, 50
                                        }
                                        if ($Report.ShowTableCaptions) {
                                            $TableParams['Caption'] = "- $($TableParams.Name)"
                                        }
                                        $OutObj | Table @TableParams
                                    }
                                    catch {
                                        Write-PscriboMessage -IsWarning $_.Exception.Message
                                    }
                                }
                            }
                        }
                        #>

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