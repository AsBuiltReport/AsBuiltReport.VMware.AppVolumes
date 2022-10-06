function Get-AbrAppVolDatastore {
    <#
    .SYNOPSIS
        Used by As Built Report to retrieve VMware APPVolume Datastore information.
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
        Write-PScriboMessage "StorageLocations InfoLevel set at $($InfoLevel.AppVolumes.StorageLocations)."
        Write-PscriboMessage "Collecting Active Directory Datastore information."
    }

    process {
        if ($InfoLevel.AppVolumes.StorageLocations -ge 1) {
            try {
                $Datastores = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/datastores"
                if ($Datastores) {
                    section -Style Heading2 "Datastore Overview" {
                        $OutObj = @()
                        foreach ($DatastoreD in $Datastores.datastores) {
                            try {
                                if($DatastoreD.uniq_string -eq $Datastores.writable_storage){
                                    $DatastoreWritableStorage = $DatastoreD.name
                                } #Close out if($DatastoreD.uniq_string -eq $Datastores.writable_storage)
                                if($DatastoreD.uniq_string -eq $Datastores.appstack_storage){
                                    $DatastoreAppStorage = $DatastoreD.name
                                } #Close out if($DatastoreD.uniq_string -eq $Datastores.appstack_storage)
                                if($DatastoreD.uniq_string -eq $Datastores.writable_backup_recurrent_datastore){
                                    $DatastoreAWriteableBackupRecurrentDatastore = $DatastoreD.name
                                }
                            }
                            catch {
                                Write-PscriboMessage -IsWarning $_.Exception.Message
                            }
                        }

                        $inObj = [ordered] @{
                            'Datacenter' = $Datastores.Datacenter
                            'Writable Storage Location' = $DatastoreWritableStorage
                            'AppStack Storage Location' = $DatastoreAppStorage
                            'Writeable Backup Location' = $DatastoreAWriteableBackupRecurrentDatastore
                            'AppStack Path' = $Datastores.appstack_path
                            'Writeable Path' = $Datastores.writable_path
                            'Writeable Archive Path' = $Datastore.writable_archive_path
                            'Writeable Backup Recurrent Path' = $Datastores.writable_backup_recurrent_path
                            'AppStack Template Path' = $Datastores.appstack_template_path
                            'Writeable Template Path' = $Datastores.writable_template_path
                        }
                        $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)

                        $TableParams = @{
                            Name = "Datastores Summary - $($AppVolServer)"
                            List = $true
                            ColumnWidths = 50, 50
                        }
                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $OutObj | Table @TableParams
                        $OutObj = @()
                        section -Style Heading2 "Datastores Details" {
                            foreach ($Datastore in $Datastores.datastores) {
                                section -Style Heading3 "$($DataStore.name)" {
                                    try {
                                        $inObj = [ordered] @{
                                            'Name' = $DataStore.name
                                            'Display Name' = $DataStore.display_Name
                                            'Category' = $DataStore.Catagory
                                            'Datacenter ' = $DataStore.datacenter
                                            'Notes' = $DataStore.note
                                            'Description' = $DataStore.description
                                            'Accessible' = $DataStore.accessible
                                            'Host' = $DataStore.host
                                            'Template Storage' = $DataStore.template_storage
                                            'Host Username' = $DataStore.host_username
                                            'Free Space' = ConvertTo-FileSizeString $DataStore.free_space
                                            'Capacity' = ConvertTo-FileSizeString $DataStore.capacity
                                        }
                                        $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)


                                        $TableParams = @{
                                            Name = "Datastore Details - $($DataStore.name)"
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