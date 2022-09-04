function Get-AbrAPPVolGeneral {
    <#
    .SYNOPSIS
        Used by As Built Report to retrieve VMware APPVolume General information.
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
        Write-PScriboMessage "General InfoLevel set at $($InfoLevel.AppVolumes.General)."
        Write-PscriboMessage "Collecting General APPVolume information."
    }

    process {
        if ($InfoLevel.AppVolumes.General -ge 1) {
            try {
                $GeneralAppInfo = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/version"
                if ($GeneralAppInfo) {
                    $OutObj = @()
                    section -Style Heading2 "General Information" {
                        $inObj = [ordered] @{
                            'Name' = $AppVolServer
                            'Version' = $GeneralAppInfo.version
                            'Configured' = ConvertTo-TextYN $GeneralAppInfo.configured
                            'Uptime' = $GeneralAppInfo.uptime
                        }
                        $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)

                        $TableParams = @{
                            Name = "General Information - $($AppVolServer)"
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
            catch {
                Write-PscriboMessage -IsWarning $_.Exception.Message
            }
        }
    }
    end {}
}