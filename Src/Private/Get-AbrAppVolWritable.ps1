function Get-AbrAppVolWritable {
    <#
    .SYNOPSIS
        Used by As Built Report to retrieve VMware APPVolume Writables information.
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
        Write-PScriboMessage "Writables InfoLevel set at $($InfoLevel.AppVolumes.Writables)."
        Write-PScriboMessage "Collecting Writables information."
    }

    process {
        if ($InfoLevel.AppVolumes.Writables -ge 1) {
            try {
                if ($PSVersionTable.PSEdition -eq 'Core') {
                    $Writables = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/writables"
                } else { $Writables = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/writables" }

                if ($Writables) {
                    Section -Style Heading3 "Writable Volumes" {
                        Paragraph "The following section provide a summary of writable volumes on $($AppVolServer.split('.')[0])."
                        BlankLine
                        $OutObj = @()
                        foreach ($Writable in $Writables.data) {
                            try {
                                $inObj = [ordered] @{
                                    'Owner' = $Writable.name
                                    'Storage' = $Writable.Datastore_Name
                                    'Status' = $Writable.Status
                                    'Created' = $Writable.created_at_Human
                                    'State' = $Writable.attached
                                }
                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                            } catch {
                                Write-PScriboMessage -IsWarning $_.Exception.Message
                            }
                        }

                        $TableParams = @{
                            Name = "Writable Volumes - $($AppVolServer)"
                            List = $false
                            ColumnWidths = 25, 20, 15, 15, 25
                        }
                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $OutObj | Sort-Object -Property Name | Table @TableParams
                        if ($InfoLevel.AppVolumes.Writables -ge 2) {
                            Section -Style Heading4 "Writable Volume Details" {
                                foreach ($Writable in $Writables.data | Sort-Object -Property Name) {
                                    try {
                                        Section -ExcludeFromTOC -Style NOTOCHeading5 "Writable Volume Details for - $($Writable.Name)" {
                                            $inObj = [ordered] @{
                                                'Owner' = $Writable.name
                                                'Owner Type' = $Writable.Owner_Type
                                                'Created Date' = $Writable.created_at_Human
                                                'Last Updated Date' = $Writable.updated_At_human
                                                'Last Mounted Date' = $Writable.mounted_At_Human
                                                'Attachment State' = $Writable.attached
                                                'Status' = $Writable.Status
                                                'Size' = "$([math]::Round($Writable.Size_mb / 1024))GB"
                                                'Number of Times Mounted' = $Writable.Mount_Count
                                                'Free Space' = "$([math]::Round($Writable.free_mb / 1024))GB"
                                                'Total Size' = "$([math]::Round($Writable.total_mb / 1024))GB"
                                                'Percent Space Available' = "$($Writable.percent_available)%"
                                                'Template Version' = $Writable.template_version
                                                'Version Count' = $Writable.version_count
                                                'Type' = $Writable.Display_Type
                                                'Error Action' = $Writable.error_action
                                                'Busy State' = $Writable.busy
                                                'File Name' = $Writable.filename
                                                'Path' = $Writable.path
                                                'Datastore Name' = $Writable.Datastore_Name
                                                'Datastore Protected' = $Writable.datastore_host.protected
                                                'Datastore Can Expand' = $Writable.can_expand
                                                'OS Version' = $Writable.datastore_host.primordial_os_name
                                            }
                                            $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)

                                            $TableParams = @{
                                                Name = "Writable volumes details - $($Writable.Name)"
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