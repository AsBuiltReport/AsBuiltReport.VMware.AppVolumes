function Get-AbrAppVolSetting {
    <#
    .SYNOPSIS
        Used by As Built Report to retrieve VMware APPVolume Settings information.
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
        Write-PScriboMessage "Settings InfoLevel set at $($InfoLevel.AppVolumes.Settings)."
        Write-PscriboMessage "Collecting Active Directory Domain information."
    }

    process {
        if ($InfoLevel.AppVolumes.Settings -ge 1) {
            try {
                if ($PSVersionTable.PSEdition -eq 'Core') {
                    $Settings = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/settings"
                    $Datastores = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/datastores"

                } else {
                    $Settings = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/settings"
                    $Datastores = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/datastores"
                }


                if ($Settings) {
                    section -Style Heading3 "Settings" {
                        Paragraph "The following section details app volumes settings for $($AppVolServer.split('.')[0])."
                        BlankLine

                        $OutObj = @()
                        try {
                            foreach($Setting in $Settings.data.setting){
                                if($Setting.key -eq "ui_session_timeout"){
                                    $UISessionTimeout = $Setting.value
                                }
                                #Regular Backups
                                if($Setting.key -eq "enable_data_disk_recurrent_backup"){
                                    $RegularBackups = $Setting.value
                                }
                                #Regular Backups Days
                                if($Setting.key -eq "data_disk_backup_recurrent_interval"){
                                    $RegularBackupsInterval = $Setting.value
                                }
                                # Backup Storage Location
                                if($Setting.key -eq "data_disk_backup_recurrent_datastore"){
                                    $StorageLocation = $Setting.value
                                }
                                # Backup Storage Path
                                if($Setting.key -eq "data_disk_backup_recurrent_path"){
                                    $StoragePath = $Setting.value
                                }
                                # Backup Storage Path
                                if($Setting.key -eq "manage_sec"){
                                    $NonDomainEntities = $Setting.value
                                }
                            }

                            foreach ($Datastore in $Datastores.datastores){
                                if($Datastore.uniq_string -eq $StorageLocation){
                                    $DatastoreBackupName = $Datastore.name
                                }
                            }

                            foreach($Setting in $Settings.data.advanced_setting){
                                # Disable Volume Cache
                                if($Setting.key -eq "DISABLE_SNAPVOL_CACHE"){
                                    $DisableSnapVolumeCache = $Setting.value
                                }
                                # Disable Token AD Query
                                if($Setting.key -eq "DISABLE_TOKEN_AD_QUERY"){
                                    $DisableTokenADQuery = $Setting.value
                                }
                                if($Setting.key -eq "JOIN_CEIP"){
                                    $DisableJOINCEIP = $Setting.value
                                }
                                if($Setting.key -eq "ENABLE_ALLOW_PACKAGE_DELIVERY_TO_ANY_OS"){
                                    $DisableDELIVERYTOANYOS = $Setting.value
                                }
                                if($Setting.key -eq "ENABLE_2X_VOLUMES"){
                                    $Disable2XVolumes = $Setting.value
                                }
                                if($Setting.key -eq "disable_agent_session_cookie"){
                                    $DisableAgentSessionCookie = $Setting.value
                                }
                                if($Setting.key -eq "ENABLE_PARTIAL_RECONFIG"){
                                    $VMDKPackageResiliency = $Setting.value
                                }
                            }

                            $inObj = [ordered] @{
                                'UI Session Timeout' = $UISessionTimeout
                                'Non-Domain Entities' = $NonDomainEntities
                                'Writeable Volumes Regular Backups' = $RegularBackups
                                'Writeable Volumes Regular Backups Interval' = "$($RegularBackupsInterval) - days"
                                'Writeable Volumes Storage Location' = $DatastoreBackupName
                                'Writeable Volumes Storage Path' = $StoragePath
                                'Disable Agent Session Cookie' = $DisableAgentSessionCookie
                                'Disable Volume Cache' = $DisableSnapVolumeCache
                                'Disable Token AD Query' = $DisableTokenADQuery
                                'Enable Volumes (2.x)' = $Disable2XVolumes
                                'Allow package delivery to any operating system' = $DisableDELIVERYTOANYOS
                                'VMDK Package Resiliency' = $VMDKPackageResiliency
                                'Join the VMware CEIP' = $DisableJOINCEIP
                            }
                            $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)

                            $TableParams = @{
                                Name = "Settings - $($AppVolServer)"
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
            catch {
                Write-PscriboMessage -IsWarning $_.Exception.Message
            }
        }
    }
    end {}
}