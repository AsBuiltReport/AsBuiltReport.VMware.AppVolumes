function Get-AbrAppVolStorage {
    <#
    .SYNOPSIS
        Used by As Built Report to retrieve VMware APPVolume Storage information.
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
        Write-PScriboMessage "Storage InfoLevel set at $($InfoLevel.AppVolumes.Storage)."
        Write-PscriboMessage "Collecting Active Directory Domain information."
    }

    process {
        if ($InfoLevel.AppVolumes.Storage -ge 1) {
            try {
                $Storages = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/storages"
                if ($Storages) {
                    section -Style Heading2 "Storage" {
                        $OutObj = @()
                        foreach ($Storage in $Storages.Storages) {
                            section -Style Heading3 $Storage.Name {
                                try {
                                    $inObj = [ordered] @{
                                        'Host' = $Storage.host
                                        'Space Users' = $Storage.space_used
                                        'Space Total' = $Storage.space_total
                                        "Number of AppStack's" = $Storage.num_appstacks
                                        "Number of Writable's" = $Storage.num_writables
                                        'Storage Attachable' = $Storage.attachable
                                        'Storage Created Date' = $Storage.created_at_human
                                        'Storage Status' = $Storage.status
                                    }
                                    $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)

                                    $TableParams = @{
                                        Name = "Storage - $($Storage.Name)"
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