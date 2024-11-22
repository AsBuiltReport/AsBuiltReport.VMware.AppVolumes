function Get-AbrAppVolDatastore {
    <#
    .SYNOPSIS
        Used by As Built Report to retrieve VMware APPVolume Datastore information.
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
        Write-PScriboMessage "Storage InfoLevel set at $($InfoLevel.AppVolumes.Storage)."
        Write-PScriboMessage "Collecting Active Directory Datastore information."
    }

    process {
        if ($InfoLevel.AppVolumes.Storage -ge 1) {
            try {
                if ($PSVersionTable.PSEdition -eq 'Core') {
                    $Datastores = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/datastores"
                } else { $Datastores = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/datastores" }

                if ($Datastores) {
                    Section -Style Heading3 "Storage Overview" {
                        Paragraph "The following section details off location of templates for $($AppVolServer.split('.')[0])."
                        BlankLine
                        foreach ($DatastoreD in $Datastores.datastores) {
                            try {
                                if ($DatastoreD.uniq_string -eq $Datastores.data_disk_storage) {
                                    $DatastoreWritableStorage = $DatastoreD.name
                                }
                                if ($DatastoreD.uniq_string -eq $Datastores.package_storage) {
                                    $DatastoreAppStorage = $DatastoreD.name
                                }
                                if ($DatastoreD.uniq_string -eq $Datastores.data_disk_backup_recurrent_path) {
                                    $DatastoreAWriteableBackupRecurrentDatastore = $DatastoreD.name
                                }
                            } catch {
                                Write-PScriboMessage -IsWarning $_.Exception.Message
                            }
                        }
                        try {
                            Section -Style Heading4 "Storage Overview Packages" {
                                $OutObj = @()
                                $inObj = [ordered] @{
                                    'Default Storage Location' = "[$($Datastores.Datacenter)] $DatastoreAppStorage"
                                    'Default Storage Path' = $Datastores.package_path
                                    'Default Template Path' = $Datastores.package_template_path
                                }
                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)

                                $TableParams = @{
                                    Name = "Packages - $($AppVolServer)"
                                    List = $true
                                    ColumnWidths = 50, 50
                                }
                                if ($Report.ShowTableCaptions) {
                                    $TableParams['Caption'] = "- $($TableParams.Name)"
                                }
                                $OutObj | Table @TableParams
                            }
                        } catch {
                            Write-PScriboMessage -IsWarning $_.Exception.Message
                        }
                        try {
                            Section -Style Heading4 "Storage Overview Writable Volumes" {
                                $OutObj = @()
                                $inObj = [ordered] @{
                                    'Default Storage Location' = "[$($Datastores.Datacenter)] $DatastoreWritableStorage"
                                    'Default Storage Path' = $Datastores.data_disk_path
                                    'Default Archive Path' = $Datastores.data_disk_archive_path
                                    'Default Backup Path' = $Datastores.data_disk_backup_recurrent_path
                                    'Template Path' = $Datastores.data_disk_template_path
                                }
                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)

                                $TableParams = @{
                                    Name = "Packages - $($AppVolServer)"
                                    List = $true
                                    ColumnWidths = 50, 50
                                }
                                if ($Report.ShowTableCaptions) {
                                    $TableParams['Caption'] = "- $($TableParams.Name)"
                                }
                                $OutObj | Table @TableParams
                            }
                        } catch {
                            Write-PScriboMessage -IsWarning $_.Exception.Message
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