function Get-AbrAppVolStorageGroup {
    <#
    .SYNOPSIS
        Used by As Built Report to retrieve VMware APPVolume Storage Group information.
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
        Write-PScriboMessage "StorageGroups InfoLevel set at $($InfoLevel.AppVolumes.StorageGroups)."
        Write-PscriboMessage "Collecting App Volumes Datastore information."
    }

    process {
        if ($InfoLevel.AppVolumes.StorageGroups -ge 1) {
            try {
                $StorageGroups = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/storage_groups"
                if ($StorageGroups) {
                    section -Style Heading2 "Storage Groups" {
                        $OutObj = @()
                        foreach ($StorageGroup in $StorageGroups.storage_groups) {
                            section -Style Heading3 $StorageGroup.name {
                                try {
                                    $inObj = [ordered] @{
                                        'Distribution Strategy' = $StorageGroup.strategy
                                        'Template Storage' = $StorageGroup.template_storage
                                        'Members Count' = $StorageGroup.members
                                        'Member Name Prefix' = $StorageGroup.member_prefix
                                        'Space Used' = $StorageGroup.space_used
                                        'Total Space' = $StorageGroup.space_total
                                        'Creation Date' = $StorageGroup.created_at_human
                                        'Auto Import' = $StorageGroup.auto_import
                                        'Auto Replicate' = $StorageGroup.auto_replicate
                                        'Last Replicated Date' = $StorageGroup.replicated_at_human
                                        'Last Imported Date' = $StorageGroup.imported_at_human
                                        'Last Curated Date' = $StorageGroup.curated_at_human
                                    }
                                    $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)

                                    $TableParams = @{
                                        Name = "Storage Group - $($StorageGroup.name)"
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
            catch {
                Write-PscriboMessage -IsWarning $_.Exception.Message
            }
        }
    }
    end {}
}