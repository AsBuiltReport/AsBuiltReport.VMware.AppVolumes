function Get-AbrAppVolMachineManager {
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
        Write-PScriboMessage "MachineManagers InfoLevel set at $($InfoLevel.AppVolumes.MachineManagers)."
        Write-PscriboMessage "Collecting Machine Managers information."
    }

    process {
        if ($InfoLevel.AppVolumes.MachineManagers -ge 1) {
            try {
                $MachineManagers = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/machine_managers"
                if ($MachineManagers) {
                    section -Style Heading3 "Machine Manager" {
                        $OutObj = @()
                        foreach ($MachineManager in $MachineManagers.machine_managers | Sort-Object -Property Host) {
                            section -Style Heading3 $MachineManager.host {
                                $MachineManagerDetail = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/machine_managers/$($MachineManager.id)"
                                try {
                                    $inObj = [ordered] @{
                                        'Username' = $MachineManager.Username
                                        "Host Username" = $MachineManagerDetail.machine_manager.host_username
                                        'Type' = $MachineManager.type
                                        'Supports Multi' = $MachineManager.supports_multi
                                        "Is Connected" = $MachineManagerDetail.machine_manager.is_connected
                                        "SSL Validation Enabled" = $MachineManagerDetail.machine_manager.ssl_validation_enabled
                                        "Mount On Host" = $MachineManagerDetail.machine_manager.settings.mount_on_host
                                        "Mount Queues" = $MachineManagerDetail.machine_manager.settings.use_reconfig_queues
                                        "Mount Async" = $MachineManagerDetail.machine_manager.settings.use_async
                                        "Mount Throttle" = $MachineManagerDetail.machine_manager.settings.concurrent_reconfigs
                                        "Description" = $MachineManagerDetail.machine_manager.description
                                    }
                                    $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)
                                }
                                catch {
                                    Write-PscriboMessage -IsWarning $_.Exception.Message
                                }

                                $TableParams = @{
                                    Name = "Machine Manager - $($MachineManager.host)"
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
                }
            }
            catch {
                Write-PscriboMessage -IsWarning $_.Exception.Message
            }
        }
    }
    end {}
}