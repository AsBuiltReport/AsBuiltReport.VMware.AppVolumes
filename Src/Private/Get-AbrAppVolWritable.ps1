function Get-AbrAppVolWritable {
    <#
    .SYNOPSIS
        Used by As Built Report to retrieve VMware APPVolume Writables information.
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
        Write-PScriboMessage "Writables InfoLevel set at $($InfoLevel.AppVolumes.Writables)."
        Write-PscriboMessage "Collecting Writables information."
    }

    process {
        if ($InfoLevel.AppVolumes.Writables -ge 1) {
            try {
                $Writables = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/app_volumes/writables"
                if ($Writables) {
                    $OutObj = @()
                    section -Style Heading2 "Writable AppStack" {
                        foreach ($Writable in $Writables.data) {
                            try {
                                $inObj = [ordered] @{
                                    'Name' = $Writable.Name
                                    'Owner' = $Writable.Owner_name
                                    'Owner Type' = $Writable.Owner_Type
                                    'Created Date' = $Writable.created_at_Human
                                    'Last Updated Date' = $Writable.updated_At_human
                                    'Last Mounted Date' = $Writable.mounted_At_Human
                                    'Attachment State' = $Writable.attached
                                    'Status' = $Writable.Status
                                    'Size In MB' = $Writable.Size_mb
                                    'Number of Times Mounted' = $Writable.Mount_Count
                                    'Free Space In MB' = $Writable.free_mb
                                    'Total Size In MB' = $Writable.total_mb
                                    'Percent Space Available' = $Writable.percent_available
                                    'Template Version' = $Writable.template_version
                                    'Version Count' = $Writable.version_count
                                    'Type' = $Writable.Display_Type
                                    'Error Action' = $Writable.error_action
                                    'Busy State' = $Writable.busy
                                    'File Name' = $Writable.filename
                                    'Path' = $Writable.path
                                    'Datastore Name' = $Writable.Datastore_Name
                                    'Datastore Protected' = $WritablesIDSource.protected
                                    'Datastore Can Expand' = $WritablesIDSource.can_expand
                                    'OS Version' = $WritablesIDSource.primordial_os_name
                                }
                                $OutObj = [pscustomobject]$inobj

                                $TableParams = @{
                                    Name = "Writable AppStack - $($AppVolServer)"
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
            catch {
                Write-PscriboMessage -IsWarning $_.Exception.Message
            }
        }
    }
    end {}
}