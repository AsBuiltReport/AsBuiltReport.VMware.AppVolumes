function Get-AbrAPPVolManager {
    <#
    .SYNOPSIS
        Used by As Built Report to retrieve VMware APPVolume Appstack information.
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
        Write-PScriboMessage "Manager InfoLevel set at $($InfoLevel.AppVolumes.Managers)."
        Write-PscriboMessage "Collecting Manager information."
    }

    process {
        if ($InfoLevel.AppVolumes.Managers -ge 1) {
            try {
                $Managers = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/manager_services"
                if ($Managers) {
                    $OutObj = @()
                    section -Style Heading2 "Manager Servers" {
                        foreach($Manager in $Managers.services) {
                            try {
                                $inObj = [ordered] @{
                                    'Name' = $Manager.name
                                    'Internal Version' = $Manager.internal_version
                                    'Product Version' = $Manager.product_version
                                    'Domain Name' = $Manager.domain_name
                                    'Computer Name' = $Manager.computer_name
                                    'Computer FQDN' = $Manager.fqdn
                                    'Registered' = ConvertTo-TextYN $Manager.registered
                                    'Secure' = ConvertTo-TextYN $Manager.secure
                                    'Status' = $Manager.status
                                    'First Seen At' = $Manager.first_seen_at_human
                                    'Last Seen At' = $Manager.last_seen_at_human
                                }
                                $OutObj = [pscustomobject]$inobj

                                $TableParams = @{
                                    Name = "Manager Server - $($Manager.name)"
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