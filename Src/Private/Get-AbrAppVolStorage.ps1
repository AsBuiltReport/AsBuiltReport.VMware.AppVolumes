function Get-AbrAppVolStorage {
    <#
    .SYNOPSIS
        Used by As Built Report to retrieve VMware APPVolume Storage information.
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
        Write-PScriboMessage "Storage Locations InfoLevel set at $($InfoLevel.AppVolumes.StorageLocations)."
        Write-PscriboMessage "Collecting storage location information."
    }

    process {
        if ($InfoLevel.AppVolumes.StorageLocations -ge 1) {
            try {
                if ($PSVersionTable.PSEdition -eq 'Core') {
                    $Storages = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/storages"
                } else {$Storages = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/storages"}

                if ($Storages) {
                    section -Style Heading3 "Managed Storage Locations" {
                        Paragraph "The following section details configured storage options for Packages, Writable Volumes, and AppStacks on $($AppVolServer.split('.')[0])."
                        BlankLine
                        $OutObj = @()
                        foreach ($Storage in $Storages.Storages) {
                            try {
                                $inObj = [ordered] @{
                                    'Name' = $Storage.Name
                                    'Host' = $Storage.host.split(".")[0]
                                    'AppStacks' = $Storage.num_appstacks
                                    'Writables' = $Storage.num_writables
                                    'Attachable' = $Storage.attachable
                                    'Status' = $Storage.status
                                }
                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)

                            }
                            catch {
                                Write-PscriboMessage -IsWarning $_.Exception.Message
                            }
                        }

                        $TableParams = @{
                            Name = "Storages - $($AppVolServer)"
                            List = $false
                            ColumnWidths = 30, 14, 14, 14, 14, 14
                        }
                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $OutObj | Sort-Object -Property Name |  Table @TableParams
                        if ($InfoLevel.AppVolumes.StorageLocations -ge 2) {
                            if ($PSVersionTable.PSEdition -eq 'Core') {
                                $Datastores = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/datastores"
                            } else {$Datastores = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/datastores"}

                            if ($Datastores) {
                                #section -Style Heading4 "Storage Details" {
                                    $OutObj = @()
                                    foreach ($Datastore in $Datastores.datastores | Sort-Object -Property Name) {
                                        section -ExcludeFromTOC -Style NOTOCHeading5 "Storage Details - $($DataStore.name)" {
                                            try {
                                                $inObj = [ordered] @{
                                                    'Display Name' = $DataStore.display_Name
                                                    'Machine Manager' = $DataStore.Host
                                                    'Category' = $DataStore.Catagory
                                                    'Datacenter ' = $DataStore.datacenter
                                                    'Notes' = $DataStore.note
                                                    'Description' = $DataStore.description
                                                    'Accessible' = $DataStore.accessible
                                                    'Template Storage' = $DataStore.template_storage
                                                    'Host Username' = $DataStore.host_username
                                                    'Free Space' = ConvertTo-FileSizeString $DataStore.free_space
                                                    'Capacity' = ConvertTo-FileSizeString $DataStore.capacity
                                                }
                                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)


                                                $TableParams = @{
                                                    Name = "Storage Details - $($DataStore.name)"
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
                                #}
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