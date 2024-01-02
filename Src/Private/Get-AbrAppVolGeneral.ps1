function Get-AbrAPPVolGeneral {
    <#
    .SYNOPSIS
        Used by As Built Report to retrieve VMware APPVolume General information.
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
        Write-PScriboMessage "General InfoLevel set at $($InfoLevel.AppVolumes.General)."
        Write-PscriboMessage "Collecting General APPVolume information."
    }

    process {
        if ($InfoLevel.AppVolumes.General -ge 1) {
            try {
                if ($PSVersionTable.PSEdition -eq 'Core') {
                    $GeneralAppInfo = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/version"
                } else {$GeneralAppInfo = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/version"}
                if ($PSVersionTable.PSEdition -eq 'Core') {
                    $LDAPDomains = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/ldap_domains"
                } else {$LDAPDomains = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/ldap_domains"}
                if ($PSVersionTable.PSEdition -eq 'Core') {
                    $Managers = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/manager_services"
                } else {$Managers = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/manager_services"}
                if ($PSVersionTable.PSEdition -eq 'Core') {
                    $MachineManagers = Invoke-RestMethod -SkipCertificateCheck -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/machine_managers"
                } else {$MachineManagers = Invoke-RestMethod -WebSession $SourceServerSession -Method Get -Uri "https://$AppVolServer/cv_api/machine_managers"}

                if ($GeneralAppInfo -and $LDAPDomains -and $Managers) {
                    $OutObj = @()
                    section -Style Heading2 "General Information" {
                        Paragraph "The following section provide a summary of common information on $($AppVolServer.split('.')[0])."
                        Blankline
                        $inObj = [ordered] @{
                            'Name' = $AppVolServer
                            'Version' = $GeneralAppInfo.version
                            'Configured' = ConvertTo-TextYN $GeneralAppInfo.configured
                            'Uptime' = $GeneralAppInfo.uptime
                            'Number of Domains' = ($LDAPDomains.ldap_domains).count
                            'Number of App Volumes Managers' = ($Managers.services).count
                            'Number of vCenters' = ($MachineManagers.machine_managers).Count
                        }
                        $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)

                        $TableParams = @{
                            Name = "General Information - $($AppVolServer)"
                            List = $true
                            ColumnWidths = 40, 60
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